import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';

class FacebookLogin extends StatefulWidget {
  const FacebookLogin({super.key});

  @override
  State<FacebookLogin> createState() => _FacebookLoginState();
}

class _FacebookLoginState extends State<FacebookLogin> {
  Map<String, dynamic>? _userData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkLogging();
  }

  Future<void> _checkLogging() async {
    final AccessToken? accessToken = await FacebookAuth.instance.accessToken;
    setState(() {
      _isLoading = false;
    });

    if (accessToken != null) {
      await _getUserData();
    }
  }

  Future<void> _getUserData() async {
    try {
      final userData = await FacebookAuth.instance.getUserData();
      setState(() {
        _userData = userData;
      });
    } catch (e) {
      print("Error fetching user data: $e");
    }
  }

  Future<void> _login() async {
    try {
      final LoginResult result = await FacebookAuth.instance.login();

      if (result.status == LoginStatus.success) {
        await _getUserData();
      } else {
        print("Facebook login failed: ${result.message}");
      }
    } catch (e) {
      print("Error during Facebook login: $e");
    }
  }

  Future<void> _logout() async {
    try {
      await FacebookAuth.instance.logOut();
      setState(() {
        _userData = null;
      });
    } catch (e) {
      print("Error during Facebook logout: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Facebook Login'),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  if (_userData != null) ...[
                    Text('Name: ${_userData!['name']}'),
                    Text('Email: ${_userData!['email'] ?? 'N/A'}'),
                    Image.network(
                      _userData!['picture']['data']['url'],
                      width: 100,
                      height: 100,
                    ),
                  ],
                  const SizedBox(
                    height: 20,
                  ),
                  ElevatedButton(
                    onPressed: _userData != null ? _logout : _login,
                    child: Text(
                      _userData != null ? 'LOGOUT' : 'LOGIN',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
