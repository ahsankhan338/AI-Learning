import 'package:aieducator/api/auth_api.dart';
import 'package:aieducator/components/spinner.dart';
import 'package:aieducator/constants/colors.dart';
import 'package:aieducator/provider/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isLoading = false;
  bool rememberMe = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.backgroundGradient,
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextFormField(
                    controller: emailController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email';
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.email, color: Colors.white),
                      hintText: 'Email',
                      hintStyle: const TextStyle(color: Colors.white70),
                      filled: true,
                      fillColor: Colors.transparent,
                      enabledBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.white70),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.white),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    style: const TextStyle(color: Colors.white),
                  ),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: passwordController,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return "Password is Required";
                      }
                    },
                    obscureText: true,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.lock, color: Colors.white),
                      hintText: 'Password',
                      hintStyle: const TextStyle(color: Colors.white70),
                      filled: true,
                      fillColor: Colors.transparent,
                      enabledBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.white70),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.white),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    style: const TextStyle(color: Colors.white),
                  ),
                  const SizedBox(height: 10),

                  // Remember Me Toggle
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Text('Remember me',
                              style: TextStyle(color: Colors.white)),
                          Transform.scale(
                            scale: 0.6,
                            child: Switch(
                                value: rememberMe,
                                materialTapTargetSize:
                                    MaterialTapTargetSize.shrinkWrap,
                                activeTrackColor: Colors.grey,
                                activeColor: Colors.white,
                                thumbColor:
                                    WidgetStateProperty.all(Colors.white),
                                trackOutlineColor:
                                    WidgetStateProperty.all(Colors.transparent),
                                onChanged: (value) {
                                  setState(() {
                                    rememberMe = value;
                                  });
                                }),
                          ),
                        ],
                      ),
                      const Text('Forgot password?',
                          style: TextStyle(color: Colors.white70)),
                    ],
                  ),
                  const SizedBox(height: 25),

                  isLoading
                      ? const SpinLoader()
                      : ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(double.infinity, 50),
                            backgroundColor: Colors.grey,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 40, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onPressed: () async {
                            if (_formKey.currentState!.validate()) {
                              setState(() {
                                isLoading = true;
                              });
                              final Authentication authentication =
                                  Authentication();

                              await authentication
                                  .logIn(
                                      email: emailController.text,
                                      password: passwordController.text)
                                  .then((onValue) => {
                                        Provider.of<AuthProvider>(
                                                listen: false, context)
                                            .login(token: "token")
                                      })
                                  .catchError((onError) => {print(onError)})
                                  .whenComplete(() => {
                                        setState(() {
                                          isLoading = false;
                                        })
                                      });
                            }
                          },
                          child: const Text('Log in',
                              style: TextStyle(color: Colors.black)),
                        ),

                  const SizedBox(height: 45),
                  const Row(
                    children: [
                      Expanded(child: Divider(color: Colors.white70)),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8.0),
                        child:
                            Text('or', style: TextStyle(color: Colors.white70)),
                      ),
                      Expanded(child: Divider(color: Colors.white70)),
                    ],
                  ),
                  const SizedBox(height: 45),

                  // Google Sign In Button
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size(double.infinity, 50),
                      backgroundColor: Colors.grey,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    icon: const FaIcon(FontAwesomeIcons.google,
                        color: Colors.white),
                    label: const Text('Log In with Google',
                        style: TextStyle(color: Colors.black)),
                    onPressed: () {},
                  ),
                  const SizedBox(height: 16),

                  // Register Link
                  const Text.rich(
                    TextSpan(
                      text: "Don't have an account? ",
                      style: TextStyle(color: Colors.white70),
                      children: [
                        TextSpan(
                          text: "register here",
                          style: TextStyle(
                              color: Colors.blueAccent,
                              fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
