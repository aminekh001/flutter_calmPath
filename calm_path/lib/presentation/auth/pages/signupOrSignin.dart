import 'package:calm_path/common/widgets/app_bar/app_bar.dart';
import 'package:calm_path/common/widgets/button/basic_app_button.dart';
import 'package:calm_path/core/configs/assets/app_images.dart';
import 'package:calm_path/core/configs/assets/app_vectors.dart';
import 'package:calm_path/core/configs/theme/app_colors.dart';
import 'package:calm_path/presentation/auth/pages/signup.dart';
import 'package:flutter/material.dart';

class Signuporsignin extends StatelessWidget {
  const Signuporsignin({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const BasicAppBar(),
          const Align(
            alignment: Alignment.bottomLeft,
            child: Image(
              image: AssetImage(AppImages.login),
                // Set width in pixels
              
              ),
          ),
   
        
          Align(
            alignment: Alignment.center,
            child: Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: 40,
            
            ), 
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
               const Image(
              image: AssetImage(AppVectors.logoH),
             
                ),
                const SizedBox(height: 30,),
              const Text(
                'strive to improve every day',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                  color: AppColors.grey
                ),
              ),
                              const SizedBox(height: 10,),
              const Text(
                'Thryve is a stress relief app designed to bring happiness and promote wellness in your daily life',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                  color: AppColors.grey
                ),
              ),
              const SizedBox(height: 30,),
              Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: BasicButton(
                      onPressed: (){
                        Navigator.push(
                          context, 
                          MaterialPageRoute(builder: (BuildContext contex)=>const Signup()
                          ),
                          );
                      },
                       title: 'Sign up'),
                  ),
                  const SizedBox(width: 5,),
                  Expanded(
                  child: TextButton(
                    onPressed: (){
                      
                    }, 
                    child: const Text(
                      'Sign in',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: Colors.white
                      ) ,
                    )
                    )
                  )
                ],
              ),
              ],

            )
          )
          )
        ],
      ),
    );
  }
}