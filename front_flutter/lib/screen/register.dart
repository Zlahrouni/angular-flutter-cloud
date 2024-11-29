import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class RegisterScreen extends StatefulWidget {
  final VoidCallback onLoginTap;

  const RegisterScreen({Key? key, required this.onLoginTap}) : super(key: key);

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final AuthService _authService = AuthService();
  final _formKey = GlobalKey<FormState>();
  String _email = '';
  String _password = '';
  String _confirmPassword = '';
  String _error = '';
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  Future<void> _register() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
        _error = '';
      });

      if (_password != _confirmPassword) {
        setState(() {
          _error = 'Les mots de passe ne correspondent pas';
          _isLoading = false;
        });
        return;
      }

      try {
        await _authService.register(_email, _password);
      } catch (e) {
        setState(() {
          _error = e.toString();
        });
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.deepPurple[800],
        title: Text(
          'Inscription',
          style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold
          ),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Créez votre compte',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple[800],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 30),
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 8,
                  shadowColor: Colors.black26,
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      children: [
                        TextFormField(
                          decoration: InputDecoration(
                            labelText: 'Email',
                            labelStyle: TextStyle(color: Colors.deepPurple[700]),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.deepPurple[700]!),
                            ),
                            prefixIcon: Icon(
                              Icons.email,
                              color: Colors.deepPurple[300],
                            ),
                          ),
                          style: TextStyle(color: Colors.grey[800]),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Veuillez entrer votre email';
                            }
                            if (!value.contains('@')) {
                              return 'Veuillez entrer un email valide';
                            }
                            return null;
                          },
                          onChanged: (value) => _email = value,
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          decoration: InputDecoration(
                            labelText: 'Mot de passe',
                            labelStyle: TextStyle(color: Colors.deepPurple[700]),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.deepPurple[700]!),
                            ),
                            prefixIcon: Icon(
                              Icons.lock,
                              color: Colors.deepPurple[300],
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                                color: Colors.deepPurple[300],
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                            ),
                          ),
                          style: TextStyle(color: Colors.grey[800]),
                          obscureText: _obscurePassword,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Veuillez entrer votre mot de passe';
                            }
                            if (value.length < 6) {
                              return 'Le mot de passe doit contenir au moins 6 caractères';
                            }
                            return null;
                          },
                          onChanged: (value) => _password = value,
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          decoration: InputDecoration(
                            labelText: 'Confirmer le mot de passe',
                            labelStyle: TextStyle(color: Colors.deepPurple[700]),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.deepPurple[700]!),
                            ),
                            prefixIcon: Icon(
                              Icons.lock_outline,
                              color: Colors.deepPurple[300],
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscureConfirmPassword
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                                color: Colors.deepPurple[300],
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscureConfirmPassword = !_obscureConfirmPassword;
                                });
                              },
                            ),
                          ),
                          style: TextStyle(color: Colors.grey[800]),
                          obscureText: _obscureConfirmPassword,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Veuillez confirmer votre mot de passe';
                            }
                            return null;
                          },
                          onChanged: (value) => _confirmPassword = value,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                if (_error.isNotEmpty)
                  Text(
                    _error,
                    style: TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                const SizedBox(height: 20),
                _isLoading
                    ? Center(
                  child: CircularProgressIndicator(
                    color: Colors.deepPurple[500],
                  ),
                )
                    : ElevatedButton(
                  onPressed: _register,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple[500],
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'S\'inscrire',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: widget.onLoginTap,
                  child: Text(
                    'Déjà inscrit ? Connectez-vous',
                    style: TextStyle(color: Colors.deepPurple[700]),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}