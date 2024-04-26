import 'dart:io';

import 'package:chat_app/widgets/user_image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

final _formKey = GlobalKey<FormState>();
final _firebase = FirebaseAuth.instance;
var _isAuthenticating = false;

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() {
    return _AuthScreenState();
  }
}

class _AuthScreenState extends State<AuthScreen> {
  var _isLogin = true;
  var _enteredEmail;
  var _enteredPassword;
  var _enteredUserName;
  File? _selectedImage;

  void _commitData() async {
    var isValid = _formKey.currentState!.validate();

    if (!isValid) {
      return;
    }

    if (!_isLogin && _selectedImage == null) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Please choose photo.')));
      return;
    }

    _formKey.currentState!.save();
    try {
      setState(() {
        _isAuthenticating = true;
      });
      if (!_isLogin) {
        var userCredentials = await _firebase.createUserWithEmailAndPassword(
            email: _enteredEmail, password: _enteredPassword);
        var storageRef = FirebaseStorage.instance
            .ref()
            .child('User Images')
            .child('${userCredentials.user!.uid}.jpg');
        await storageRef.putFile(_selectedImage!);
        var urlOfThatImg = await storageRef.getDownloadURL();
        FirebaseFirestore.instance.collection('users').doc(
            userCredentials.user!.uid).set({
          'user_name': _enteredUserName,
          'email': _enteredEmail,
          'password': _enteredPassword,
          'imageUrl': urlOfThatImg
        });
        setState(() {
          _isAuthenticating = false;
        });
      } else {
        var userCredentials = await _firebase.signInWithEmailAndPassword(
            email: _enteredEmail, password: _enteredPassword);
        setState(() {
          _isAuthenticating = false;
        });
      }
    } on FirebaseAuthException catch (error) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error.message ?? 'Something went wrong.')));
    }
    setState(() {
      _isAuthenticating = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme
          .of(context)
          .colorScheme
          .primary,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  margin: const EdgeInsets.only(
                      top: 30, left: 20, right: 20, bottom: 20),
                  width: 200,
                  child: Image.asset('assets/images/chat.png'),
                ),
                Card(
                  margin: const EdgeInsets.all(20),
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (!_isLogin)
                              UserImagePicker(onSelectImage: (img) {
                                _selectedImage = img;
                              }),
                            TextFormField(
                              decoration: const InputDecoration(
                                labelText: 'Email address',
                              ),
                              keyboardType: TextInputType.emailAddress,
                              autocorrect: false,
                              textCapitalization: TextCapitalization.none,
                              validator: (value) {
                                if (value == null ||
                                    value
                                        .trim()
                                        .isEmpty ||
                                    !value.contains('@') ||
                                    value
                                        .trim()
                                        .length <= 1) {
                                  return 'Please enter valid email address.';
                                }
                                return null;
                              },
                              onSaved: (value) {
                                _enteredEmail = value;
                              },
                            ),
                            if(!_isLogin)
                              TextFormField(
                                decoration: const InputDecoration(
                                    labelText: 'Username'),
                                validator: (value) {
                                  if (value == null || value
                                      .trim()
                                      .isEmpty || value
                                      .trim()
                                      .length < 5) {
                                    return 'Enter a valid user name that contains at least 4 characters';
                                  }
                                  return null;
                                },
                                onSaved: (val){
                                  _enteredUserName = val;
                                },
                              ),
                            TextFormField(
                              decoration: const InputDecoration(
                                labelText: 'Password',
                              ),
                              obscureText: true,
                              validator: (value) {
                                if (value == null || value.length < 6) {
                                  return 'Password should contain at least 6 characters.';
                                }
                              },
                              onSaved: (value) {
                                _enteredPassword = value;
                              },
                            ),
                            const SizedBox(
                              height: 12,
                            ),
                            if (_isAuthenticating)
                              const CircularProgressIndicator(),
                            if (!_isAuthenticating)
                              ElevatedButton(
                                  onPressed: _commitData,
                                  child: Text(_isLogin ? 'Login' : 'Sign up')),
                            if (!_isAuthenticating)
                              TextButton(
                                  onPressed: () {
                                    setState(() {
                                      _isLogin = !_isLogin;
                                      _formKey.currentState!.reset();
                                    });
                                  },
                                  child: Text(_isLogin
                                      ? 'Create an account'
                                      : 'I already have an account'))
                          ],
                        ),
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
