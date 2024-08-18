import 'package:flutter/material.dart';
import 'package:sqlitestaplication/database.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'SQL Injection Demo',
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  List<Map<String, dynamic>> _users = [];

  void _insertUser() async {
    final email = _emailController.text;
    final password = _passwordController.text;

    if (email.isNotEmpty && password.isNotEmpty) {
      await _dbHelper.insertUser(email, password);
      _fetchUsers(_emailController.text, _passwordController.text);
    } else {
      setState(() {
        _users = [{
          'email': 'N/A',
          'password': 'Please enter both email and password'
        }];
      });
    }
  }

 void _fetchUsers(String email, String password) async {
  final db = await _dbHelper.database;

  List<Map<String, dynamic>> users = [];

  // Check if email contains SQL injection patterns
  if (email.endsWith("OR 1 = 1")||email.endsWith("OR 1=1") && password.endsWith("OR 1 = 1") ||password.endsWith("OR 1=1")) {
    // Fetch all users if SQL injection pattern is detected
    users = await db.rawQuery('SELECT * FROM users');
  } else if (email.isNotEmpty && password.isNotEmpty) {
    // Use parameterized query to avoid SQL injection
    users = await db.rawQuery(
      'SELECT * FROM users WHERE email = ? AND password = ?',
      [email, password],
    );

    if (users.isEmpty) {
      // If no matching users found
      users.add({
        'email': 'N/A',
        'password': 'No matching records found'
      });
    }
  } else {
    // Provide a message if email or password is not provided
    users.add({
      'email': 'N/A',
      'password': 'Please enter both email and password'
    });
  }

  setState(() {
    _users = users;
  });
}



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SQL Injection Demo'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'Password'),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: _insertUser,
                  child: const Text('Insert'),
                ),
                ElevatedButton(
                  onPressed: () {
                    _fetchUsers(_emailController.text, _passwordController.text);
                  },
                  child: const Text('Fetch'),
                ),
              ],
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _users.length,
                itemBuilder: (context, index) {
                  final user = _users[index];
                  return ListTile(
                    title: Text('Email: ${user['email']}'),
                    subtitle: Text('Password: ${user['password']}'),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
