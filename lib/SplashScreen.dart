import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'HomeScreen.dart';
import 'LoginScreen.dart';

class Splash extends StatefulWidget {
  const Splash({Key? key}) : super(key: key);

  @override
  State<Splash> createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  @override
  void initState() {
    _navigatePage();
    super.initState();
  }

  _navigatePage() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    // preferences.setString('clinic_id', "");
    // preferences.setString('doctorName', "");
    // preferences.setString('userList', "");
    String? storedTvToken = preferences.getString('tvToken');
    int storedTimestamp = preferences.getInt('tvTokenTimestamp') ?? 0;
    DateTime storedDateTime = DateTime.fromMillisecondsSinceEpoch(storedTimestamp);
    DateTime currentDateTime = DateTime.now();
    // String? storedClinicId = preferences.getString('clinic_id');
    // String? storedDoctorName = preferences.getString('doctorName');
    List<String>? storedList = preferences.getStringList('userList'); // Retrieve the list
    print(storedList);
    print(storedDateTime);
    print(currentDateTime);
    print(storedTvToken);
    // print(storedClinicId);
    // print(storedDoctorName);

    // Delay for 1500 milliseconds

    if (storedTvToken != null && storedTvToken.isNotEmpty && storedDateTime.year == currentDateTime.year &&
        storedDateTime.month == currentDateTime.month &&
        storedDateTime.day == currentDateTime.day && storedList!= null && storedList.isNotEmpty) {
      print('matched');
      // Navigate to the home screen with the stored TV token
      // ignore: use_build_context_synchronously
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => HomeScreen(),
        ),
      );
    } else {
      print('nope');
      // Navigate to the login screen
      // ignore: use_build_context_synchronously
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF010038),
      body: Center(
        child: Container(child: Image.asset(
          'assets/uhi_white_2048.png',
          width: 200,
          height: 200,
        ),),
      ),
    );
  }
}
