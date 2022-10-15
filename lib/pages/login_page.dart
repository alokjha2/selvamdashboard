import '../utils/colors.dart';
import 'package:selvam_broilers/widgets/custom_button.dart';
import 'package:selvam_broilers/widgets/custom_input.dart';
import 'package:selvam_broilers/pages/home_page.dart';
import 'package:selvam_broilers/services/auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:loading_overlay/loading_overlay.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController _userNameController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  FirebaseAuthService _firebaseAuthService = FirebaseAuthService();
  bool _isLoading = false;
  String _errorMessage = '';
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Scaffold(
      body: LoadingOverlay(
        isLoading: _isLoading,
        child: Container(
          alignment: Alignment.center,
          padding: EdgeInsets.all(8.0),
          child: Container(
            height: 360,
            width: 320,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(6.0)),
                border: Border.all(color: primaryBorder)),
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                SizedBox(height: 20),
                Icon(
                  Icons.lock,
                  size: 50,
                  color: gray,
                ),
                SizedBox(height: 20),
                Text(
                  'Admin Login',
                  style: Theme.of(context).textTheme.headline1,
                ),
                SizedBox(height: 20),
                CustomInputField(
                  hint: 'User Name',
                  controller: _userNameController,
                  autoFocus: true,
                ),
                SizedBox(height: 20),
                CustomPasswordField(
                  hint: 'Password',
                  controller: _passwordController,
                  onSubmitted: () {
                    _login();
                  },
                ),
                SizedBox(height: 10),
                Text(
                  _errorMessage,
                  style: Theme.of(context)
                      .textTheme
                      .caption
                      ?.copyWith(color: Colors.redAccent),
                ),
                SizedBox(height: 10),
                CustomButton(
                    width: 100,
                    height: 35,
                    onPressed: () {
                      _login();
                    },
                    text: 'Login')
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  void _login() async {
    try {
      _showOverlayProgress();
      final user = await _firebaseAuthService.signInWithEmailAndPassword(
          _userNameController.text + '@mymail.com', _passwordController.text);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomePage()),
      );
    } on FirebaseAuthException catch (e) {
      if (e.code == 'wrong-password') {
        setState(() {
          _errorMessage = 'Wrong password!';
        });
      } else if (e.code == 'user-not-found') {
        setState(() {
          _errorMessage = 'Wrong Username!';
        });
      } else {
        setState(() {
          _errorMessage = 'Unable to login. Try again.';
        });
      }
      print(e.code);
      _hideOverlayProgress();
    }
  }

  void _showOverlayProgress() {
    setState(() {
      _isLoading = true;
    });
  }

  void _hideOverlayProgress() {
    setState(() {
      _isLoading = false;
    });
  }
}
