import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/service_locator.dart'; 
import 'features/auth/presentation/cubit/auth_cubit.dart';
import 'features/auth/presentation/cubit/product_cubit.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'core/app_theme.dart';

void main() {
  setupServiceLocator(); 
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthCubit>(
          create: (context) => getIt<AuthCubit>(), 
        ),
        BlocProvider<ProductCubit>(
          create: (context) => getIt<ProductCubit>(),
        ),
      ],
      child: MaterialApp(
        title: 'DeviceHub',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const LoginPage(),
      ),
    );
  }
}