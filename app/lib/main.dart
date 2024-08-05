import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'ScriptGeneratorScreen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Sign Up/Login',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: LoginPage(registeredEmail: 'Email', registeredPassword: 'Password',),
    );
  }
}
class LoginPage extends StatelessWidget {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  final String registeredEmail;
  final String registeredPassword;

  LoginPage({required this.registeredEmail, required this.registeredPassword});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:  Column(
        crossAxisAlignment: CrossAxisAlignment.center, // Center horizontally
        children: [
          // RichText widget to show different font sizes for text
          Padding(
            padding: const EdgeInsets.only(top: 60.0), // Adjust this value as needed
            child:RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                children: [
                  TextSpan(
                    text: 'VerbaGen\n\n',
                    style: TextStyle(
                      fontSize: 26.0, // Smaller font size for "AI Powered"
                      fontWeight: FontWeight.normal,
                      color: Colors.black,
                    ),
                  ),
                  TextSpan(
                    text: 'Login to your\nAccount',
                    style: TextStyle(
                      fontSize: 44.0, // Larger font size for "ScriptGen"
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 70.0),
          TextField(
            controller: emailController,
            decoration: InputDecoration(
                prefixIcon: Icon(Icons.person), // Lock icon for password

                labelText: 'Email'),
          ),
          TextField(
            controller: passwordController,
            obscureText: true,
            decoration: InputDecoration(
                prefixIcon: Icon(Icons.lock), // Lock icon for password

                labelText: 'Password'),
          ),
          SizedBox(height: 70),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white, backgroundColor: Colors.purple,
              padding: EdgeInsets.symmetric(horizontal: 120.0, vertical: 15.0),
              textStyle: TextStyle(fontSize: 18.0),
            ),
            onPressed: () {
              String email = emailController.text;
              String password = passwordController.text;

              if (email == registeredEmail && password == registeredPassword) {
                // Successful login, navigate to HomePage
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => HomePage()),
                );
              } else {
                // Show error message and option to go back to Sign Up Page
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Invalid email or password')),
                );
              }
            },
            child: Text('Login'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => SignUpPage()),
              );
            },
            child: Text('Do not have an account? Sign up'),
          ),
        ],
      ),
    );

  }
}
class SignUpPage extends StatelessWidget {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool _validateEmail(String email) {
    final emailPattern = RegExp(r'^[a-zA-Z0-9._%+-]+@scriptgen\.com$');
    return emailPattern.hasMatch(email);
  }

  bool _validatePassword(String password) {
    final passwordPattern =
    RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\W).+$');
    return passwordPattern.hasMatch(password);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:  Column(
          crossAxisAlignment: CrossAxisAlignment.center, // Center horizontally
          children: [
      // RichText widget to show different font sizes for text
      Padding(
      padding: const EdgeInsets.only(top: 60.0), // Adjust this value as needed
      child:RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          children: [
            TextSpan(
              text: 'VerbaGen\n\n',
              style: TextStyle(
                fontSize: 26.0, // Smaller font size for "AI Powered"
                fontWeight: FontWeight.normal,
                color: Colors.black,
              ),
            ),
            TextSpan(
              text: 'Sign in to your\nAccount',
              style: TextStyle(
                fontSize: 44.0, // Larger font size for "ScriptGen"
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    ),

    SizedBox(height: 70.0),

      TextField(
              controller: emailController,
              decoration: InputDecoration(
                  prefixIcon: Icon(Icons.person), // Icon for username

                  labelText: 'Email'),

      ),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: InputDecoration(
                  prefixIcon: Icon(Icons.lock), // Lock icon for password

                  labelText: 'Password'),
            ),
            SizedBox(height: 70),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white, backgroundColor: Colors.purple,
                padding: EdgeInsets.symmetric(horizontal: 120.0, vertical: 15.0),
                textStyle: TextStyle(fontSize: 18.0),
              ),
              onPressed: () {
                String email = emailController.text;
                String password = passwordController.text;

                if (!_validateEmail(email)) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Email must be in the format name@scriptgen.com')),
                  );
                } else if (!_validatePassword(password)) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Password must contain at least one uppercase letter, one lowercase letter, and one special character')),
                  );
                } else {
                  // Navigate to Login Page after registration
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => LoginPage(
                        registeredEmail: email,
                        registeredPassword: password,
                      ),
                    ),
                  );
                }
              },
              child: Text('Register'),
            ),
    ]
      ),
    );



  }
}



class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(


      body:  Column(
        crossAxisAlignment: CrossAxisAlignment.center, // Center horizontally
        children: [
          // RichText widget to show different font sizes for text
          Padding(
            padding: const EdgeInsets.only(top: 60.0), // Adjust this value as needed
            child:RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                children: [
                  TextSpan(
                    text: 'AI Powered\n',
                    style: TextStyle(
                      fontSize: 26.0, // Smaller font size for "AI Powered"
                      fontWeight: FontWeight.normal,
                      color: Colors.black,
                    ),
                  ),
                  TextSpan(
                    text: 'VerbaGen',
                    style: TextStyle(
                      fontSize: 54.0, // Larger font size for "ScriptGen"
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 20.0), // Space between text and image

          // Image below the text
          Image.asset(
            'assets/Screenshot 2024-07-31 200751.png',
            width: 520.0, // Adjust the size as needed
            height: 520.0,
          ),

          SizedBox(height: 15.0), // Space between image and button

          // Generate button below the image
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => Generator()),
              );
              // Add your onPressed functionality here
            },
            child: Text('Get Started'),
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white, backgroundColor: Colors.purple,
              padding: EdgeInsets.symmetric(horizontal: 120.0, vertical: 15.0),
              textStyle: TextStyle(fontSize: 18.0),
            ),
          ),

        ],
      ),


    );
  }

}



class Generator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'YouTube Script Generator',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: ScriptGeneratorScreen(),
    );
  }
}
