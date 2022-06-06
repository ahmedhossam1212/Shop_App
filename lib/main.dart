import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shop_app/layout/shop_layout.dart';
import 'package:shop_app/modules/login/login.dart';
import 'package:shop_app/modules/onboarding.dart';
import 'package:shop_app/shared/componantes/constans.dart';
import 'package:shop_app/shared/style/theme.dart';
import 'layout/cubit/cubit.dart';
import 'shared/network/local/cach_helper.dart';
import 'shared/network/local/dio_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await CacheHelper.init();
  DioHelper.init();
  Widget startScreen;
  dynamic onBoarding = CacheHelper.getData(key: 'onBoarding');
  token = CacheHelper.getData(key: 'token');
  debugPrint(token);
  if (onBoarding != null) {
    if (token != null) {
      startScreen = const ShopLayout();
    } else {
      startScreen = ShopLoginScreen();
    }
  } else {
    startScreen = const OnBoardingScreen();
  }
  runApp(MyApp(
    startScreen: startScreen,
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, this.startScreen});
  final Widget? startScreen;
  @override
  Widget build(BuildContext context) {
    return 
    BlocProvider(
      create: (BuildContext context) => ShopCubit()
        ..getHomeData()
        ..getCategoriesData()
        ..getFavorites()
        ..getUserData(),
      child: MaterialApp(
        title: 'Shop App',
        debugShowCheckedModeBanner: false,
        theme: lightTheme,
        home: startScreen,
      ),
    );
  }
}