import 'package:flutter/material.dart';
import 'ScriptGeneratorScreen.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(MyApp());
}



// User model
class User {
  final String username;
  final String password;

  User({required this.username, required this.password});
}

// Authentication provider
class AuthProvider with ChangeNotifier {
  User? _user;

  User? get user => _user;

  bool login(String username, String password) {
    // Dummy login logic
    if (username == 'test' && password == 'password') {
      _user = User(username: username, password: password);
      notifyListeners();
      return true;
    }
    return false;
  }

  bool register(String username, String password) {
    // Dummy registration logic
    if (username.isNotEmpty && password.isNotEmpty) {
      _user = User(username: username, password: password);
      notifyListeners();
      return true;
    }
    return false;
  }

  void logout() {
    _user = null;
    notifyListeners();
  }
}



class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => AuthProvider(),
      child: MaterialApp(
        title: 'Flutter Login/Register',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: AuthScreen(),
      ),
    );
  }
}

class AuthScreen extends StatefulWidget {
  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLogin = true;
  String _errorMessage = '';

  void _toggleMode() {
    setState(() {
      _isLogin = !_isLogin;
      _errorMessage = '';
    });
  }

  void _submit() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final username = _usernameController.text;
    final password = _passwordController.text;
    bool success;

    if (_isLogin) {
      success = authProvider.login(username, password);
    } else {
      success = authProvider.register(username, password);
    }

    if (!success) {
      setState(() {
        _errorMessage = 'Invalid username or password';
      });
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomeScreen()),
      );
    }
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
                      text: 'ScriptGen\n\n',
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


            SizedBox(height: 70),

            TextField(
              controller: _usernameController,
              decoration: InputDecoration(
                  prefixIcon: Icon(Icons.person), // Icon for username

                  labelText: 'Username'),

            ),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(

                  prefixIcon: Icon(Icons.lock), // Lock icon for password

                  labelText: 'Password'),
              obscureText: true,
            ),
            SizedBox(height: 30),
            if (_errorMessage.isNotEmpty)
              Text(
                _errorMessage,
                style: TextStyle(color: Colors.red),
              ),
            SizedBox(height: 60),
            ElevatedButton(
              onPressed: _submit,
              child: Text(_isLogin ? 'Login' : 'Register'),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white, backgroundColor: Colors.indigoAccent,
                padding: EdgeInsets.symmetric(horizontal: 120.0, vertical: 15.0),
                textStyle: TextStyle(fontSize: 18.0),
              ),
            ),
            TextButton(
              onPressed: _toggleMode,
              child: Text(_isLogin
                  ? 'Don\'t have an account? Register'
                  : 'Already have an account? Login'),
            ),
          ],
        )
    );



  }
}

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
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
                    text: 'ScriptGen',
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
              foregroundColor: Colors.white, backgroundColor: Colors.indigoAccent,
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


