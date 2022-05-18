import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'dashboard.dart';

main() {
  runApp(
    const MaterialApp(
      home: LoginPage(),
    ),
  );
}

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  var usernameController = TextEditingController();
  var passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SizedBox(
          width: MediaQuery.of(context).size.width * 0.8,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.network(
                  'https://www.blueinnotechnology.com/wp-content/uploads/2022/03/Blueinno_logo_2020_v2.png'),
              TextField(
                controller: usernameController,
                decoration: const InputDecoration(labelText: 'Username'),
              ),
              TextField(
                controller: passwordController,
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => signInUp(endpoint: 'create_user'),
                    child: const Text('Sign up'),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: () => signInUp(endpoint: 'login'),
                    child: const Text('Sign in'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  signInUp({required String endpoint}) {
    var bytes = utf8.encode(passwordController.text);
    var digest = sha256.convert(bytes);

    var url = Uri.parse('https://Blockchain.felixwong6.repl.co/$endpoint');
    var headers = {'Content-Type': 'application/json'};
    var body = jsonEncode(
        {'username': usernameController.text, 'password': digest.toString()});

    http.post(url, headers: headers, body: body).then((response) {
      if (response.statusCode == 200) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const DashBoard()),
        );
      } else {
        showDialog(
            context: context,
            builder: (context) => AlertDialog(
                title: Text(response.statusCode.toString()),
                content: Text(response.body)));
      }
    });
  }
}
