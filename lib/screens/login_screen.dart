import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../layouts/base_layout.dart';
import '../services/auth_service.dart';

/// Login screen that allows users to sign in or continue anonymously
class LoginScreen extends StatefulWidget {
  /// Callback for when login is complete
  final VoidCallback onLoginComplete;

  const LoginScreen({
    super.key,
    required this.onLoginComplete,
  });

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  
  bool _isLoading = false;
  bool _isRegistering = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Sign in with email and password
  Future<void> _handleEmailSignIn() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    
    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final user = _isRegistering
          ? await authService.registerWithEmailAndPassword(
              _emailController.text.trim(), 
              _passwordController.text
            )
          : await authService.signInWithEmailAndPassword(
              _emailController.text.trim(), 
              _passwordController.text
            );
      
      if (user != null) {
        widget.onLoginComplete();
      } else {
        setState(() {
          _errorMessage = _isRegistering
              ? 'Registration failed. This email may already be in use.'
              : 'Invalid email or password.';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }
  
  // Continue with anonymous access
  Future<void> _handleAnonymousSignIn() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    
    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      if (authService.isAnonymous) {
        // Already signed in anonymously
        widget.onLoginComplete();
        return;
      }
      
      final user = await authService.signInAnonymously();
      if (user != null) {
        widget.onLoginComplete();
      } else {
        setState(() {
          _errorMessage = 'Anonymous sign-in failed.';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }
  
  void _toggleRegistration() {
    setState(() {
      _isRegistering = !_isRegistering;
      _errorMessage = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return BaseLayout(
      title: 'Welcome to Chronii',
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Logo/Header
                      const Icon(
                        Icons.timer_outlined,
                        size: 64,
                        color: Colors.indigo,
                      ),
                      const SizedBox(height: 24),
                      Text(
                        _isRegistering ? 'Create Account' : 'Welcome to Chronii',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _isRegistering 
                          ? 'Register to save your data in the cloud'
                          : 'Sign in to access your account',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: theme.colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                      const SizedBox(height: 32),
                      
                      // Error message if any
                      if (_errorMessage != null) ...[
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.error.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: theme.colorScheme.error.withOpacity(0.5),
                            ),
                          ),
                          child: Text(
                            _errorMessage!,
                            style: TextStyle(color: theme.colorScheme.error),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                      
                      // Email field
                      TextFormField(
                        controller: _emailController,
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          prefixIcon: Icon(Icons.email),
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your email';
                          }
                          if (!value.contains('@') || !value.contains('.')) {
                            return 'Please enter a valid email';
                          }
                          return null;
                        },
                        enabled: !_isLoading,
                      ),
                      const SizedBox(height: 16),
                      
                      // Password field
                      TextFormField(
                        controller: _passwordController,
                        decoration: const InputDecoration(
                          labelText: 'Password',
                          prefixIcon: Icon(Icons.lock),
                          border: OutlineInputBorder(),
                        ),
                        obscureText: true,
                        textInputAction: TextInputAction.done,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your password';
                          }
                          if (_isRegistering && value.length < 6) {
                            return 'Password must be at least 6 characters';
                          }
                          return null;
                        },
                        onFieldSubmitted: (_) => _handleEmailSignIn(),
                        enabled: !_isLoading,
                      ),
                      const SizedBox(height: 24),
                      
                      // Sign In / Register button
                      FilledButton(
                        onPressed: _isLoading ? null : _handleEmailSignIn,
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: _isLoading
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              _isRegistering ? 'Register' : 'Sign In',
                              style: const TextStyle(fontSize: 16),
                            ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Toggle between sign in and register
                      TextButton(
                        onPressed: _isLoading ? null : _toggleRegistration,
                        child: Text(
                          _isRegistering 
                            ? 'Already have an account? Sign in'
                            : 'New user? Create account',
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      const Divider(height: 0),
                      const SizedBox(height: 16),
                      
                      // Anonymous sign in
                      OutlinedButton.icon(
                        onPressed: _isLoading ? null : _handleAnonymousSignIn,
                        icon: const Icon(Icons.person_outline),
                        label: const Text('Continue without account'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      // Info text
                      Text(
                        'Anonymous mode stores your data only on this device. Sign in or register to sync across devices.',
                        style: TextStyle(
                          fontSize: 12,
                          color: theme.colorScheme.onSurface.withOpacity(0.6),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
