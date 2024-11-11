import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fgdc_14_chatapp/widgets/user_image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

final _firebase = FirebaseAuth.instance;

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  var _enteredEmail = '';
  var _enteredPassword = '';
  var _isLoggedIn = true;
  var _isAuthenticating = false;
  var _enteredUserName = '';
  File? _selectedImage;

  void _submit() async {
    final isValid = _formKey.currentState!.validate();

    if (!isValid || !_isLoggedIn && _selectedImage == null) {
      return;
    }

    _formKey.currentState!.save();

    try {
      setState(() {
        _isAuthenticating = true;
      });
      if (_isLoggedIn) {
        final authCred = await _firebase.signInWithEmailAndPassword(
            email: _enteredEmail,
            password: _enteredPassword);
      } else {
        final userCreds = await _firebase.createUserWithEmailAndPassword(
            email: _enteredEmail,
            password: _enteredPassword);

        // TODO- figure out why upload not working
        // final storageRef = FirebaseStorage.instance.ref()
        //     .child('user_images')
        //     .child('${userCreds.user!.uid}.jpg');
        //
        // await storageRef.putFile(_selectedImage!);
        // final imageUrl = await storageRef.getDownloadURL();

        await FirebaseFirestore.instance.collection('users').doc(userCreds.user!.uid).set({
          'username': _enteredUserName,
          'email': _enteredEmail,
        });
        print('User creds->$userCreds<-');
        // print('User image->$imageUrl<-');
      }
    } on FirebaseAuthException catch (error) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(error.message ?? 'Authorization failed'),),);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.primary,
        body: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  margin: const EdgeInsets.only(
                      top: 30, bottom: 20, left: 20, right: 20),
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
                            if (!_isLoggedIn) UserImagePicker(onPickedImage: (pickImage) {
                              _selectedImage = pickImage;
                            },),
                            TextFormField(
                              decoration: const InputDecoration(
                                labelText: 'Email Address',
                              ),
                              keyboardType: TextInputType.emailAddress,
                              autocorrect: false,
                              textCapitalization: TextCapitalization.none,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty || !value.contains('@')) {
                                  return 'Please enter a valid email...';
                                }
                                return null;
                              },
                              onSaved: (value) {
                                _enteredEmail = value!;
                              },
                            ),
                            if (!_isLoggedIn)
                              TextFormField(
                                decoration: const InputDecoration(
                                  labelText: 'Username',
                                ),
                                enableSuggestions: false,
                                onSaved: (value) {
                                  _enteredUserName = value!;
                                },
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty
                                      || value.trim().length < 4) {
                                    return 'Please enter a valid username...';
                                  }
                                  return null;
                                },
                              ),
                            TextFormField(
                              decoration: const InputDecoration(
                                labelText: 'Password',
                              ),
                              obscureText: true,
                              validator: (value) {
                                if (value == null || value
                                    .trim()
                                    .length < 6) {
                                  return 'Enter at least a 6 character password';
                                }
                                return null;
                              },
                              onSaved: (value) {
                                _enteredPassword = value!;
                              },
                            ),
                            const SizedBox(height: 12),
                            ElevatedButton(
                                onPressed: _submit,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Theme.of(context)
                                    .colorScheme.primaryContainer,
                              ),
                                child: Text(_isLoggedIn ? 'Log In' : 'Sign Up'),
                            ),
                            TextButton(
                              onPressed: () {
                                setState(() {
                                  _isLoggedIn = !_isLoggedIn;
                                });
                              },
                              child: Text(_isLoggedIn ? 'Create an account' : 'I already have an account'),
                            ),
                        
                          ],
                        ),
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ));
  }
}
