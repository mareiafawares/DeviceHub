import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:front_end/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:front_end/features/auth/presentation/cubit/auth_state.dart';
import 'package:front_end/features/auth/presentation/pages/login_page.dart';
import 'package:front_end/features/auth/presentation/pages/admin_home_page.dart';
import 'package:front_end/features/auth/presentation/pages/seller_home.dart';
import 'package:front_end/features/auth/presentation/pages/customer_home.dart';

/// Decides initial screen: restore session from token, then show Login or role-based home.
class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  bool _restoreAttempted = false;

  @override
  void initState() {
    super.initState();
    // Only restore once per app start. After logout we navigate away and this route is removed.
    if (!_restoreAttempted) {
      _restoreAttempted = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        context.read<AuthCubit>().restoreSession();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        if (state is AuthLoading) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        if (state is AuthSuccess) {
          final role = (state.userRole ?? state.user.role).toString().toLowerCase();
          if (role == 'admin') return const AdminHomePage();
          if (role == 'seller') return const SellerHomePage();
          return const CustomerHomePage();
        }
        return const LoginPage();
      },
    );
  }
}
