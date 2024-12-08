import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:calm_path/common/widgets/app_bar/app_bar.dart';
import 'package:calm_path/common/widgets/button/basic_app_button.dart';
import 'package:calm_path/core/configs/assets/app_vectors.dart';
import 'package:calm_path/core/configs/assets/app_images.dart';
import 'signin.dart';

class Signup extends StatefulWidget {
  const Signup({Key? key}) : super(key: key);

  @override
  _SignupState createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isLoading = false;
  bool _isResendLoading = false;

  Future<void> _registerUser() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Create user
      final UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      final user = userCredential.user;

      // Update the displayName with the full name (username)
      if (user != null) {
        await user.updateDisplayName(_fullNameController.text.trim());
        await user.reload(); // Reload user to ensure updates reflect
      }

      // Send email verification
      if (user != null && !user.emailVerified) {
        await user.sendEmailVerification();
        _showVerificationDialog(user);
        _monitorEmailVerification(user);
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Sign up failed: $error"),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showVerificationDialog(User user) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text("Verify Your Email"),
              content: const Text(
                "A verification email has been sent to your email address. Please verify your email to proceed.",
              ),
              actions: [
                if (_isResendLoading)
                  const Center(child: CircularProgressIndicator())
                else
                  TextButton(
                    onPressed: () async {
                      setState(() => _isResendLoading = true);

                      try {
                        await user.sendEmailVerification();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Verification email resent!"),
                            backgroundColor: Colors.green,
                          ),
                        );
                      } catch (error) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("Resend failed: $error"),
                            backgroundColor: Colors.red,
                          ),
                        );
                      } finally {
                        setState(() => _isResendLoading = false);
                      }
                    },
                    child: const Text(
                      "Resend Verification Email",
                      style: TextStyle(color: Colors.blue),
                    ),
                  ),
              ],
            );
          },
        );
      },
    );
  }

  void _monitorEmailVerification(User user) async {
    while (!user.emailVerified) {
      await Future.delayed(const Duration(seconds: 3));
      await user.reload();
      user = _auth.currentUser!;
    }

    Navigator.pop(context); // Close the dialog
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => Signin()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: _signInText(context),
      appBar: BasicAppBar(
        title: Image.asset(
          AppVectors.logoH,
          height: 100,
          width: 100,
        ),
      ),
      body: Stack(
        children: [
          const Align(
            alignment: Alignment.bottomRight,
            child: Image(
              image: AssetImage(AppImages.signup),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _registerText(),
                  Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(height: 20),
                        _buildTextField(
                          controller: _fullNameController,
                          hintText: 'Full Name',
                          icon: Icons.person,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your full name';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 10),
                        _buildTextField(
                          controller: _emailController,
                          hintText: 'Email',
                          icon: Icons.email,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your email';
                            } else if (!RegExp(r'\S+@\S+\.\S+').hasMatch(value)) {
                              return 'Please enter a valid email address';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 10),
                        _buildTextField(
                          controller: _passwordController,
                          hintText: 'Password',
                          icon: Icons.lock,
                          obscureText: true,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your password';
                            } else if (value.length < 6) {
                              return 'Password must be at least 6 characters long';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 15),
                        _isLoading
                            ? const CircularProgressIndicator()
                            : BasicButton(
                                onPressed: _registerUser,
                                title: 'Create Account',
                              ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _registerText() {
    return const Text(
      'Register',
      style: TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 25,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _signInText(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 30),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Do you have an account?',
            style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
          ),
          TextButton(
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => Signin(),
                ),
              );
            },
            child: const Text(
              'Sign In',
              style: TextStyle(
                color: Color.fromRGBO(66, 200, 60, 1),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    bool obscureText = false,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        prefixIcon: Icon(icon),
        hintText: hintText,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      validator: validator,
    );
  }
}
