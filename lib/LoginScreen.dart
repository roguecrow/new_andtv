import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'HomeScreen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Offset> _offsetAnimation;
  bool _isAnimationCompleted = false;
  bool _isConnected = true;
  var clinicId = "";
  var doctorName = "";

  Future<void> checkConnectivity() async {
    final connectivityResult = await (Connectivity().checkConnectivity());
    setState(() {
      if (connectivityResult == ConnectivityResult.none) {
        _isConnected = false;
      }
      else
      {
        _isConnected = true;
      }
    });
  }

  @override
  void initState() {
    super.initState();

    // Initialize animation controller
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    // Define offset animation
    _offsetAnimation = Tween<Offset>(
      begin: const Offset(0, 0),
      end: const Offset(0, -0.1),
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );

    // Start the animation
    _animationController.forward().whenComplete(() {
      setState(() {
        _isAnimationCompleted = true;
      });
    });
    checkConnectivity();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<String> retrieveTvCode() async {

    SharedPreferences preferences = await SharedPreferences.getInstance() ;
    // Check if the tvToken is stored and not expired
    final storedTvToken = preferences.getString('tvToken');
    final storedTimestamp = preferences.getInt('tvTokenTimestamp');
    // preferences.setString('clinic_id', "");
    // preferences.setString('doctorName', "");
    preferences.setStringList('userList', []);

    if (storedTvToken != null && storedTimestamp != null) {
      var storedDateTime = DateTime.fromMillisecondsSinceEpoch(storedTimestamp);
      var currentDateTime = DateTime.now();

      if (storedDateTime.year == currentDateTime.year &&
          storedDateTime.month == currentDateTime.month &&
          storedDateTime.day == currentDateTime.day) {
        // Valid tvToken exists, return it
        return storedTvToken;
      }
    }
    Future<String?> _getId() async {
      var deviceInfo = DeviceInfoPlugin();
      if (Platform.isIOS) { // import 'dart:io'
        var iosDeviceInfo = await deviceInfo.iosInfo;
        return iosDeviceInfo.identifierForVendor; // unique ID on iOS
      } else if(Platform.isAndroid) {
        var androidDeviceInfo = await deviceInfo.androidInfo;
        return androidDeviceInfo.androidId; // unique ID on Android
      }
    }
    String? deviceId = await _getId();

    // If tvToken is expired or not stored, retrieve it from the API
    var url = 'https://api30.slashdr.com/tv_token?andriod_id=$deviceId';
    print('' + url);
    var response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      var jsonData = jsonDecode(response.body);
      var tvCode = jsonData['token'];

      // Store tvToken and timestamp in local storage
      var currentTime = DateTime.now().millisecondsSinceEpoch;
      await preferences.setString('tvToken', tvCode.toString());
      await preferences.setInt('tvTokenTimestamp', currentTime);

      return tvCode.toString();
    } else {
      throw Exception('Failed to retrieve TV code.');
    }
  }

  Future<void> checkTokenStatus(String tvToken) async {
    var url = 'https://api30.slashdr.com/get_token_status?tv_token=$tvToken';
    print('request: ' + url);

    var response = await http.get(Uri.parse(url));
    print('status: ' + response.statusCode.toString());

    if (response.statusCode == 200) {
      var jsonData = jsonDecode(response.body);
      print('' + jsonDecode(response.body).toString());

      if (jsonData['doctors'] != null && jsonData['doctors'].length != 0) {
        if (jsonData['doctors'] is List) {
         List<dynamic> user = jsonData['doctors'];
          print(user);
          SharedPreferences preferences = await SharedPreferences.getInstance() ;
          preferences.setStringList('userList', user.map((doctor) => jsonEncode(doctor)).toList());
          print('List stored in shared preferences');
           // ignore: prefer_interpolation_to_compose_strings, non_constant_identifier_names
          }

        // ignore: use_build_context_synchronously
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const HomeScreen(),
          ),
        );
        print('API response success');
      } else {
        print('API response failure: Data is null');
      }
    } else {
      Future.delayed(const Duration(seconds: 15), () {
        checkTokenStatus(tvToken);
      });
      print('API response failure');
      // Handle error or display an error message
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF010038),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return Transform.translate(
                  offset: _offsetAnimation.value,
                  child: child,
                );
              },
              child: Image.asset(
                'assets/uhi_white_2048.png',
                width: 200,
                height: 200,
              ),
            ),
            if (_isAnimationCompleted)
              Text(
                'Connect using this code',
                style: TextStyle(
                  fontFamily: 'sf_pro',
                  color: Colors.white,
                  fontSize: ScreenUtil().setSp(40),
                  fontWeight: FontWeight.w200,
                ),
              ),
            const SizedBox(height: 20),
            if (_isAnimationCompleted && _isConnected)
              FutureBuilder<String>(
                future: retrieveTvCode(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    final tvCode = snapshot.data!;
                    // checkTokenStatus(tvCode);
                    Future.delayed(const Duration(seconds: 15), () {
                      checkTokenStatus(tvCode);
                    });
                    return Column(
                      children: [
                        Text(
                          tvCode,
                          style: TextStyle(
                            fontFamily: 'sf_pro',
                            color: Colors.white,
                            fontSize: ScreenUtil().setSp(180),
                          ),
                        ),
                      ],
                    );
                  } else if (snapshot.hasError) {
                    return Column(
                      children: [
                        Text(
                          'Error: ${snapshot.error}',
                          style: TextStyle(
                            fontFamily: 'sf_pro',
                            color: Colors.red,
                            fontSize: ScreenUtil().setSp(16),
                          ),
                        ),
                      ],
                    );
                  }
                  else {
                    return const CircularProgressIndicator();
                  }
                },
              ),
            if (_isAnimationCompleted && !_isConnected)
              FutureBuilder<void>(
                future: checkConnectivity(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: Column(
                        children: [
                          Text('No Internet',style: TextStyle(fontFamily: 'sf_pro',color: Colors.red,fontSize: ScreenUtil().setSp(40)),
                          ),
                          const SizedBox(height: 10,),
                          const CircularProgressIndicator(),
                        ],
                      ),
                    );
                  } else if (snapshot.hasError) {
                    return Text(
                      'Error: ${snapshot.error}',
                      style:  TextStyle(
                        color: Colors.red,
                        fontSize: ScreenUtil().setSp(16),
                      ),
                    );
                  } else {
                    return Text(
                      'No network connection.',
                      style: TextStyle(
                        fontFamily: 'sf_pro',
                        color: Colors.red,
                        fontSize: ScreenUtil().setSp(16),
                      ),
                    );
                  }
                },
              ),
          ],
        ),
      ),
    );
  }
}

