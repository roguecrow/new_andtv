  import 'dart:io';
  import 'package:flutter/material.dart';
  import 'package:flutter/services.dart';
  import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:new_andtv/LoginScreen.dart';
import 'package:new_andtv/SplashScreen.dart';

  void main()async{
    WidgetsFlutterBinding.ensureInitialized();

    ByteData data = await PlatformAssetBundle().load('assets/ca/slashdr.pem');
    SecurityContext.defaultContext.setTrustedCertificatesBytes(data.buffer.asUint8List());

    runApp(const MyApp());
  }


  class MyApp extends StatelessWidget {
    const MyApp({Key? key}) : super(key: key);
    @override
    Widget build(BuildContext context) {
      //Set the fit size (Find your UI design, look at the dimensions of the device screen and fill it in,unit in dp)
      return ScreenUtilInit(
        designSize: const Size(960,540),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (context , child) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            // You can use the library anywhere in the app even in theme
            theme: ThemeData(
              primarySwatch: Colors.blue,
              textTheme: Typography.englishLike2018.apply(fontSizeFactor: 1.sp),
            ),
            home: Splash(),
          );
        },
      );
    }
  }
