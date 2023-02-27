import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text("Hi, Welcome Back!",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  )),
              const Text("Hello again, you've been missed!",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black,
                  )),
              Padding(
                padding: const EdgeInsets.all(45),
                child:
                    Image.asset('images/logo.png', width: 200.0, height: 200.0),
                
              ),
            ],
          ),
        ),
      ),
    );
  }
}
