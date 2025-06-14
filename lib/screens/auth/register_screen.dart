import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:metatrader_clone/screens/auth/login_screen.dart';
import 'package:metatrader_clone/screens/home/home_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(
        0xFF3D6BA1,
      ), // Darker blue background from image
      appBar: AppBar(
        backgroundColor: Colors.transparent, // Transparent app bar
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const HomeScreen(initialIndex: 4),
              ), // Navigate to HomeScreen with Messages tab selected
            );
          },
        ),
        title: const Text(
          'Account registration',
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 40),
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: 'MQL',
                      style: GoogleFonts.robotoMono(
                        color: Colors.white,
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextSpan(
                      text: '5',
                      style: GoogleFonts.robotoMono(
                        color: const Color(
                          0xFFFFD700,
                        ), // Gold/Yellow color for '5'
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                "Join trader's community",
                style: TextStyle(color: Colors.white, fontSize: 20),
              ),
              const Text(
                "www.mql5.com",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 50),
              TextField(
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Login',
                  labelStyle: const TextStyle(color: Colors.white70),
                  filled: true,
                  fillColor: const Color(
                    0xFF2C2C2C,
                  ), // Dark grey/black for input fields
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none, // No border visible
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(
                      color: Colors.blueAccent,
                      width: 2,
                    ), // Highlight on focus
                  ),
                ),
              ),
              const SizedBox(height: 8),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Latin characters and digits without spaces",
                  style: TextStyle(color: Colors.white54, fontSize: 12),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'E-Mail',
                  labelStyle: const TextStyle(color: Colors.white70),
                  filled: true,
                  fillColor: const Color(0xFF2C2C2C),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(
                      color: Colors.blueAccent,
                      width: 2,
                    ),
                  ),
                  hintText: 'ex@gmail.com',
                  hintStyle: const TextStyle(color: Colors.white30),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                "The password for your new MQL5 account will be sent to the specified email address",
                style: TextStyle(color: Colors.white70, fontSize: 14),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(
                      0xFFFDD835,
                    ), // Yellow for Get an Account button
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () {
                    // Handle Get an Account logic
                  },
                  child: const Text(
                    'Get an Account',
                    style: TextStyle(
                      color: Colors.black, // Text color on yellow button
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'or',
                style: TextStyle(color: Colors.white70, fontSize: 16),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    backgroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    side: BorderSide.none, // No border as background is white
                  ),
                  onPressed: () {
                    // Handle Sign in with Google
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Placeholder for Google logo if no asset is available
                      Image.network(
                        'https://upload.wikimedia.org/wikipedia/commons/thumb/c/c1/Google_%22G%22_logo.svg/2048px-Google_%22G%22_logo.svg.png', // Small Google logo
                        height: 24,
                        width: 24,
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        'Sign in with Google',
                        style: TextStyle(
                          color: Colors
                              .black54, // Dark grey for Google button text
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 40),
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  text: "If you have an account, please ",
                  style: const TextStyle(color: Colors.white70, fontSize: 16),
                  children: [
                    TextSpan(
                      text: 'login',
                      style: const TextStyle(
                        color: Color(0xFFFDD835), // Yellow for login link
                        fontWeight: FontWeight.bold,
                      ),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const LoginScreen(),
                            ),
                          );
                        },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  text: "Visit ",
                  style: const TextStyle(color: Colors.white70, fontSize: 16),
                  children: [
                    TextSpan(
                      text: 'mql5.com',
                      style: const TextStyle(
                        color: Color(0xFFFDD835), // Yellow for mql5.com link
                        fontWeight: FontWeight.bold,
                      ),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          // Handle opening mql5.com in a browser
                          print('Open mql5.com');
                        },
                    ),
                    const TextSpan(
                      text: " to access all community services.",
                      style: TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
