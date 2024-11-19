import 'package:calm_path/common/widgets/app_bar/app_bar.dart';
import 'package:calm_path/core/configs/assets/app_vectors.dart';
import 'package:flutter/material.dart';

class Signup extends StatelessWidget {
  const Signup({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: BasicAppBar(
        title: Image.asset(
          AppVectors.logoH,
          height: 100 ,
          width: 100,
        ),
      ),
      body: Padding(padding: const EdgeInsets.symmetric(
        vertical: 50,
        horizontal: 30
      ),
      
      child:   Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _registerText(),
          const SizedBox(height: 20,),
          _fullNameFild(context),
          const SizedBox(height: 20,),
          _passwordFild()

        ],
      ),
      ),
    );
  }
  Widget _registerText(){
    return const Text(
      'Register',
      style: TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 25, 
      ),
      textAlign: TextAlign.center,
    );
  }
  Widget _fullNameFild(BuildContext context){
    return TextField(
      decoration: const InputDecoration(
        hintText: 'Full Name',
      ).applyDefaults (
         Theme.of(context).inputDecorationTheme
         ),
    );
  }
    Widget _passwordFild(){
    return const TextField(      
   );
  }
}