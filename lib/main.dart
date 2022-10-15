import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:selvam_broilers/services/network.dart';
import 'package:selvam_broilers/utils/utils.dart';
import 'package:selvam_broilers/widgets/custom_button.dart';
import 'utils/colors.dart';
import 'package:selvam_broilers/pages/error_page.dart';
import 'package:selvam_broilers/routes.dart';
import 'utils/style.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // await Firebase.initializeApp();
  await Firebase.initializeApp(
    options: FirebaseOptions(
      apiKey: "AIzaSyCyD8TtRAQpg3-6MOUXZRxbqZLv6EQQo8s",
      authDomain: "makeit-pub-dev.firebaseapp.com",
      databaseURL: "https://makeit-pub-dev.firebaseio.com",
      projectId: "makeit-pub-dev",
      storageBucket: "makeit-pub-dev.appspot.com",
      messagingSenderId: "807052202486",
      appId: "1:807052202486:web:eeb10c5385f4177e2077d7",
    ),
  );
  FirebaseFirestore.instance
      .enablePersistence(const PersistenceSettings(synchronizeTabs: false));
  runApp(App());
}

class App extends StatefulWidget {
  @override
  _AppState createState() => _AppState();
}

class _AppState extends State<App> {
  final Future<FirebaseApp> _initFirebaseSdk = Firebase.initializeApp();
  final _navigatorKey = new GlobalKey<NavigatorState>();
  final sessionStartTime = DateTime.now();

  Future<bool> isDeviceTimeCorrect() async {
    try {
      var url = Uri.parse('${BASE_URL}getServerTimeStamp');
      var timeResponse = await http.post(
        url,
        headers: {"Access-Control-Allow-Origin": "*"},
      );

      print('crossed');
      if (timeResponse.statusCode == 200) {
        print(timeResponse.body);
        DateTime networkTime =
            new DateFormat("MM/dd/yyyy, hh:mm:ss aa").parse(timeResponse.body);
        Duration timeDifference = networkTime.difference(DateTime.now());
        if (timeDifference.inMinutes.abs() < 2) {
          return true;
        } else {
          return false;
        }
      } else {
        print('error ${timeResponse.statusCode}');
        return false;
      }
    } catch (err) {
      print('error $err');
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    double fontScale = 1;

    if (isTab()) {
      fontScale = 1.35;
    } else {
      fontScale = 1;
    }

    return ScreenUtilInit(
      designSize: Size(1353, 853),
      builder: (_, w) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          navigatorKey: _navigatorKey,
          theme: getAppTheme(),

          builder: (context, widget) {
            return MediaQuery(
              ///Setting font does not change with system font size
              data: MediaQuery.of(context).copyWith(textScaleFactor: fontScale),
              child: widget!,
            );
          },
          home: FutureBuilder(
            future: Future.wait([_initFirebaseSdk, isDeviceTimeCorrect()]),
            builder: (_, AsyncSnapshot<List> snapshot) {
              if (snapshot.hasError) return ErrorPage();
              if (snapshot.connectionState == ConnectionState.done) {
                if (snapshot.data![1] == true) {
                  // Assign listener after the SDK is initialized successfully
                  FirebaseAuth.instance
                      .authStateChanges()
                      .listen((User? user) async {
                    if (user == null)
                      _navigatorKey.currentState!
                          .pushReplacementNamed(PageRoutes.loginPage);
                    else {
                      _navigatorKey.currentState!
                          .pushReplacementNamed(PageRoutes.homePage);
                    }
                  });
                }
              } else {
                print('Device Time is Wrong or API not working');
                return DeviceTimeErrorScreen();
              }
              

              return LoadingScreen();
            },
          ),
          localizationsDelegates: [
            GlobalWidgetsLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: [Locale('en', 'US')], //, Locale('pt', 'BR')],
          routes: PageRoutes().routes(),
        );
      },
    );
  }
}

class LoadingScreen extends StatefulWidget {
  @override
  _LoadingScreenState createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      color: grayDark,
      child: CircularProgressIndicator(),
    );
  }
}

class DeviceTimeErrorScreen extends StatelessWidget {
  const DeviceTimeErrorScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      color: grayDark,
      child: Scaffold(
        body: SafeArea(
          child: Container(
            child: Column(
              children: [
                SizedBox(height: 20),
                Text('Date is inaccurate', textAlign: TextAlign.center),
                SizedBox(height: 20),
                CircleAvatar(
                  radius: 50,
                  child: Icon(
                    Icons.access_time_outlined,
                    size: 60,
                  ),
                ),
                SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Text(
                      'Your device date is inaccurate or Network issue. Please check date & time of the phone, and network.',
                      textAlign: TextAlign.center),
                ),
                Expanded(child: SizedBox()),
                SizedBox(height: 20),
                CustomButton(
                    onPressed: () {
                      SystemNavigator.pop();
                    },
                    text: 'Exit'),
                SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
