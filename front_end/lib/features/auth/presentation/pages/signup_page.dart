import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:front_end/core/service_locator.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:front_end/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:front_end/features/auth/presentation/pages/seller_home.dart';
import 'package:front_end/features/auth/presentation/pages/customer_home.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
 
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  
 
  String selectedRole = 'customer'; 

  @override
  void dispose() {
   
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      appBar: AppBar(
        backgroundColor: Colors.transparent, 
        elevation: 0, 
        iconTheme: const IconThemeData(color: Color(0xFF1A237E)),
      ),
      body: BlocProvider(
        create: (context) => getIt<AuthCubit>(),
        child: BlocConsumer<AuthCubit, AuthState>(
          listener: (context, state) {
            if (state is AuthSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Account Created Successfully!"), 
                  backgroundColor: Colors.green,
                ),
              );

             
              if (selectedRole == 'seller') {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const SellerHome()),
                  (route) => false, 
                );
              } else {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const CustomerHome()),
                  (route) => false,
                );
              }
            } else if (state is AuthError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message), backgroundColor: Colors.red),
              );
            }
          },
          builder: (context, state) {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Create Account", 
                    style: GoogleFonts.poppins(
                      fontSize: 28, 
                      fontWeight: FontWeight.bold, 
                      color: const Color(0xFF1A237E),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "Fill in the details to get started.",
                    style: GoogleFonts.poppins(color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 40),
                  
                 
                  _buildTextField(label: "Full Name", hint: "Maria Fawares", icon: Icons.person_outline, controller: nameController),
                  const SizedBox(height: 20),
                  _buildTextField(label: "Email", hint: "example@email.com", icon: Icons.email_outlined, controller: emailController),
                  const SizedBox(height: 20),
                  _buildTextField(label: "Password", hint: "••••••••", icon: Icons.lock_outline, isPassword: true, controller: passwordController),
                  const SizedBox(height: 30),

                  
                  Text("Join as:", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: ChoiceChip(
                          label: const Center(child: Text("Customer")),
                          selected: selectedRole == 'customer',
                          selectedColor: const Color(0xFF1A237E).withOpacity(0.2),
                          onSelected: (val) => setState(() => selectedRole = 'customer'),
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: ChoiceChip(
                          label: const Center(child: Text("Seller")),
                          selected: selectedRole == 'seller',
                          selectedColor: const Color(0xFF1A237E).withOpacity(0.2),
                          onSelected: (val) => setState(() => selectedRole = 'seller'),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 40),
                  
                 
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: state is AuthLoading ? null : () {
                       
context.read<AuthCubit>().signUp(
  username: nameController.text,
  email: emailController.text,   
  password: passwordController.text,
  role: selectedRole,             
);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1A237E), 
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: state is AuthLoading 
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            "Sign Up", 
                            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  
  Widget _buildTextField({
    required String label, 
    required String hint, 
    required IconData icon, 
    required TextEditingController controller, 
    bool isPassword = false
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: isPassword,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
            ),
          ),
        ),
      ],
    );
  }
}