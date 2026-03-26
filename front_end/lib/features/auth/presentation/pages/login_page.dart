import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:front_end/features/auth/presentation/pages/buyer_home_page.dart';
import 'package:front_end/features/auth/presentation/pages/main_layout.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:front_end/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:front_end/features/auth/presentation/cubit/auth_state.dart';
import 'package:front_end/features/auth/presentation/pages/admin_home_page.dart';
import 'package:front_end/features/auth/presentation/pages/seller_home.dart';

import 'package:front_end/features/auth/presentation/pages/register_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onAuthSuccess(BuildContext context, AuthSuccess state) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Login successful'), backgroundColor: Colors.green),
    );
    if (!context.mounted) return;
    final role = (state.userRole ?? state.user.role).toString().toLowerCase();
    if (role == 'admin') {
      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const AdminHomePage()), (_) => false);
    } else if (role == 'seller') {
      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const SellerHomePage()), (_) => false);
    } else {
     Navigator.pushAndRemoveUntil(
  context, 
  MaterialPageRoute(builder: (_) => const MainLayout()), 
  (route) => false,
);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: BlocConsumer<AuthCubit, AuthState>(
          listener: (context, state) {
            if (state is AuthSuccess) _onAuthSuccess(context, state);
            if (state is AuthError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message), backgroundColor: Colors.red),
              );
            }
          },
          builder: (context, state) {
            final isLoading = state is AuthLoading;
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 48),
                    Text(
                      'DeviceHub',
                      style: GoogleFonts.poppins(fontSize: 28, fontWeight: FontWeight.bold, color: const Color(0xFF1A237E)),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Sign in to your account',
                      style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey.shade600),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 40),
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        hintText: 'you@example.com',
                        prefixIcon: Icon(Icons.email_outlined),
                        border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
                      ),
                      validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter email' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: 'Password',
                        hintText: '••••••••',
                        prefixIcon: Icon(Icons.lock_outline),
                        border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
                      ),
                      validator: (v) => (v == null || v.isEmpty) ? 'Enter password' : null,
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      height: 52,
                      child: ElevatedButton(
                        onPressed: isLoading
                            ? null
                            : () {
                                if (_formKey.currentState?.validate() ?? false) {
                                  context.read<AuthCubit>().login(
                                        _emailController.text.trim(),
                                        _passwordController.text,
                                      );
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1A237E),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: isLoading
                            ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                            : const Text('Login', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Don\'t have an account? ', style: GoogleFonts.poppins(color: Colors.grey.shade700)),
                        TextButton(
                          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RegisterPage())),
                          child: Text('Register', style: GoogleFonts.poppins(color: const Color(0xFF1A237E), fontWeight: FontWeight.w600)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
