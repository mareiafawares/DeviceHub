import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/service_locator.dart'; 
import 'features/auth/presentation/cubit/auth_cubit.dart';
import 'features/auth/presentation/cubit/product_cubit.dart'; // Import الجديد
import 'features/auth/presentation/pages/login_page.dart';
import 'core/app_theme.dart';

void main() {
  // تأكدي أن setupServiceLocator مهيأة لتعريف ProductCubit أيضاً
  setupServiceLocator(); 
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        // 1. مزود نظام المصادقة
        BlocProvider<AuthCubit>(
          create: (context) => getIt<AuthCubit>(), 
        ),
        
        // 2. مزود نظام المنتجات (الذي أضفناه الآن)
        BlocProvider<ProductCubit>(
          create: (context) => getIt<ProductCubit>(),
        ),
      ],
      child: MaterialApp(
        title: 'DeviceHub',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        // الصفحة الأولى هي تسجيل الدخول
        home: const LoginPage(),
      ),
    );
  }
}