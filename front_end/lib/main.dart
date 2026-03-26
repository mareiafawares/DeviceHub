import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:path_provider/path_provider.dart'; 
import 'package:front_end/features/auth/presentation/cubit/cart_cubit.dart';
import 'package:front_end/features/auth/presentation/cubit/order_cubit.dart'; 

import 'package:front_end/features/auth/presentation/cubit/favorite_cubit.dart'; 
import 'core/service_locator.dart';
import 'core/app_theme.dart';
import 'features/auth/presentation/cubit/auth_cubit.dart';
import 'features/auth/presentation/cubit/product_cubit.dart';
import 'features/auth/presentation/pages/auth_gate.dart';

void main() async {
 
  WidgetsFlutterBinding.ensureInitialized();

  HydratedBloc.storage = await HydratedStorage.build(
    storageDirectory: await getApplicationDocumentsDirectory(),
  );

  
  setupServiceLocator();
  
  runApp(const DeviceHubApp());
}

class DeviceHubApp extends StatelessWidget {
  const DeviceHubApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        
        BlocProvider<AuthCubit>(create: (_) => getIt<AuthCubit>()),
        
        
        BlocProvider<ProductCubit>(create: (_) => getIt<ProductCubit>()),
        
       
        BlocProvider<CartCubit>(create: (_) => CartCubit()), 
        
       
        BlocProvider<OrderCubit>(create: (_) => getIt<OrderCubit>()),

       
        BlocProvider<FavoriteCubit>(create: (_) => getIt<FavoriteCubit>()),
      ],
      child: MaterialApp(
        title: 'DeviceHub',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const AuthGate(),
      ),
    );
  }
}