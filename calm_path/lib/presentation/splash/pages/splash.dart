import 'package:calm_path/presentation/intro/pages/get_started.dart';
import 'package:flutter/material.dart';
import 'package:calm_path/core/configs/assets/app_vectors.dart';

class SplashPage extends StatefulWidget{
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState(){
    super.initState();
    redirect();

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Image.asset(
          AppVectors.logoH
        ),
      ),
    );
  }
  Future<void> redirect() async{
    await Future.delayed(const Duration(seconds: 2));
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (BuildContext contex) => const GetStartedPage() 
      )
     );
  }
}
