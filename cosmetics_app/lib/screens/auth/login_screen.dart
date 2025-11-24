import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../home/home_screen.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  final auth = AuthService();
  bool isLoading = false; // To show loading spinner

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Using SingleChildScrollView prevents pixel overflow errors on small screens
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 1. Logo or Image Section
              Icon(Icons.brush, size: 80, color: Theme.of(context).primaryColor),
              const SizedBox(height: 10),
              const Text(
                "GLOW COSMETICS",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 10),
              const Text("Welcome back!", style: TextStyle(color: Colors.grey)),
              
              const SizedBox(height: 40),

              // 2. Input Fields
              TextField(
                controller: emailCtrl,
                decoration: const InputDecoration(
                  labelText: "Email",
                  prefixIcon: Icon(Icons.email_outlined),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: passCtrl,
                decoration: const InputDecoration(
                  labelText: "Password",
                  prefixIcon: Icon(Icons.lock_outline),
                ),
                obscureText: true,
              ),

              const SizedBox(height: 30),

              // 3. Login Button with Loading State
              SizedBox(
                width: double.infinity,
                child: isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ElevatedButton(
                        child: const Text("LOGIN"),
                        onPressed: () async {
                          setState(() => isLoading = true);
                          
                          final user = await auth.login(
                            emailCtrl.text.trim(),
                            passCtrl.text.trim(),
                          );

                          setState(() => isLoading = false);

                          if (user != null) {
                            // Use pushReplacement so user can't go back to login
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (_) => const HomeScreen()),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Invalid email or password"),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        },
                      ),
              ),

              const SizedBox(height: 20),

              // 4. Create Account Link
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Don't have an account?"),
                  TextButton(
                    child: const Text("Sign Up", style: TextStyle(fontWeight: FontWeight.bold)),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const RegisterScreen()),
                      );
                    },
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}