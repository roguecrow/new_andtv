import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;
import 'package:new_andtv/patients.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:intl/intl.dart';
import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Patient> patientList = [];
  late Timer _timer;
  DateTime lastUpdatedTime = DateTime.now();
  bool _isConnected = true;
  String? doctorName = '';
  String? clinicId;
  String? tvToken;
  bool isRequestSent = false;

  Future<void> checkConnectivity() async {
    final connectivityResult = await (Connectivity().checkConnectivity());
    setState(() {
      if (connectivityResult == ConnectivityResult.none) {
        _isConnected = false;
      } else {
        if(_isConnected==false)
          {
            isRequestSent=false;
          }
        _isConnected = true;
      }
    });
  }

  @override
  @override
  void initState() {
    fetchData();
    super.initState();
      // Fetch data every 60 seconds
      _timer = Timer.periodic(const Duration(seconds: 60), (timer) {
        checkConnectivity();
        if(!isRequestSent) {
            fetchData();
        }
      });
  }


  @override
  void dispose() {
    _timer.cancel(); // Cancel the timer when the screen is disposed
    super.dispose();
  }

  void fetchData() async {
    isRequestSent = true;
    SharedPreferences preferences = await SharedPreferences.getInstance();
    doctorName = preferences.getString('doctorName');
    final url =
        'https://api30.slashdr.com/tv/queue/?tv_token=${preferences.getString('tvToken')}&clinic_id=${preferences.getString('clinic_id')}';
    print(url);
    // Make an HTTP GET request to the API endpoint
    var response = await http.get(Uri.parse(url));
    isRequestSent = false;
    if (response.statusCode == 200) {
      print(response.statusCode);
      // Parsing the response and extracting the data
      var jsonData = jsonDecode(response.body);
      var results = jsonData['list'];

      setState(() {
        // Update the patientList with the fetched data
        patientList = List<Patient>.from(
            results.map((data) => Patient.fromJson(data))).toList();
        lastUpdatedTime = DateTime.now();
        print(patientList);// Update the last updated time
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(
      context,
      designSize: const Size(375, 812),
      minTextAdapt: true,
    );
    return WillPopScope(
      onWillPop: () async{
        SystemNavigator.pop();
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xFF010038),
          toolbarHeight: ScreenUtil().setHeight(100),
          elevation: 10,
          automaticallyImplyLeading: false,
          title: Image.asset(
            'assets/uhi_white_2048.png',
            width: 100.h,
            height:100.h,
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 25.0, top: 30.0),
              child: Text(
                '$doctorName',
                style: TextStyle(fontFamily: 'sf_pro',fontSize:ScreenUtil().setSp(40)),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF010038),
        body: Padding(
          padding: const EdgeInsets.only(top: 16.0),
          child: Column(
            children: [
              if (_isConnected) // Show ListView.builder only if connected
                Visibility(
                  visible: patientList.isNotEmpty,
                  replacement: Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          'assets/emptystate_queue.png',
                          width: 500.w,
                          height: 500.h,
                        ),
                        SizedBox(
                          height: 10.h,
                        ),
                        const Text(
                          'No Patients In Waiting!',
                          style: TextStyle(
                            fontFamily: 'sf_pro',
                              color: Colors.white,
                              letterSpacing: .5,
                              fontSize: 40,
                          ),
                        ),
                      ],
                    ),
                  ),
                  child: Expanded(
                    child: ListView.builder(
                      itemCount: patientList.length,
                      itemBuilder: (context, index) {
                        final patient = patientList[index];
                        return Container(
                          margin: EdgeInsets.symmetric(
                            horizontal: ScreenUtil().setWidth(4),
                            vertical: ScreenUtil().setWidth(3),


                          ),
                          padding: EdgeInsets.all(
                            ScreenUtil().setWidth(2),
                          ),
                          decoration: BoxDecoration(
                            color: index == 0 ? Color(0x44ffffff) : Colors.transparent,
                            borderRadius: BorderRadius.circular(
                              ScreenUtil().setWidth(10),
                            ),
                          ),
                          child: ListTile(
                            title: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${patient.name.trim()}, ${patient.age}',
                                  style: TextStyle(
                                    fontFamily: 'sf_pro',
                                    color: Colors.white,
                                    letterSpacing: 2,
                                    fontSize: ScreenUtil().setSp(60),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              if (!_isConnected) // Show "No Internet Connection" message when not connected
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          'assets/NoNet_Connect_queue.png',
                          width: 500.w,
                          height: 500.h,
                        ),
                        SizedBox(
                          height: 5.h,
                        ),
                        const Text(
                          'No internet connection !',
                          style:
                             TextStyle(
                               fontFamily: 'sf_pro',
                              color: Colors.white,
                              letterSpacing: .5,
                              fontSize: 50,
                            ),
                        ),
                      ],
                    ),
                  ),
                ),
              Align(
                alignment: Alignment.bottomRight,
                child: Padding(
                  padding: EdgeInsets.only(
                    right: ScreenUtil().setWidth(5),
                    bottom: ScreenUtil().setWidth(5),
                  ),
                  child: Text(
                    _isConnected
                        ? 'Last Updated: ${DateFormat('hh:mm a, MMM dd, yyyy').format(lastUpdatedTime)}'
                        : '',
                    style:  TextStyle(
                        fontFamily: 'sf_pro',
                        color: Colors.white,
                        fontSize: ScreenUtil().setSp(15),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
