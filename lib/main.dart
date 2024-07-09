import 'package:dars_52/services/location_services.dart';
import 'package:dars_52/views/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  // final cameraPermission = await Permission.camera.status;
  // PermissionStatus locationPermission = await Permission.location.status;
  Map<Permission,PermissionStatus> statutes = await [
    Permission.location,
    Permission.camera,
  ].request();

  // if(cameraPermission != PermissionStatus.granted){
  //   await Permission.camera.request();
  // }
  //
  // if(locationPermission != PermissionStatus.granted){
  //   locationPermission = await Permission.location.request();
  // }

  await LocationService.init();
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomeScreen(),
    );
  }
}