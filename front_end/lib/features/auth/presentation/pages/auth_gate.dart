import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:front_end/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:front_end/features/auth/presentation/cubit/auth_state.dart';
import 'package:front_end/features/auth/presentation/pages/login_page.dart';
import 'package:front_end/features/auth/presentation/pages/admin_home_page.dart';
import 'package:front_end/features/auth/presentation/pages/seller_home.dart';
import 'package:front_end/features/auth/presentation/pages/main_layout.dart'; 

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        if (state is AuthLoading) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(color: Color(0xFF1A237E)),
            ),
          );
        }

        if (state is AuthSuccess) {
          final role = (state.userRole ?? state.user.role).toString().toLowerCase();

          if (role == 'admin') {
            return const AdminHomePage();
          } else if (role == 'seller') {
            return const SellerHomePage();
          } else {
            return const MainLayout(); 
          }
        }

        return const LoginPage();
      },
    );
  }
}