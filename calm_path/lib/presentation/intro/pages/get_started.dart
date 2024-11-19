import 'package:calm_path/common/widgets/button/basic_app_button.dart';
import 'package:calm_path/core/configs/assets/app_images.dart';
import 'package:calm_path/core/configs/assets/app_vectors.dart';
import 'package:calm_path/core/configs/theme/app_colors.dart';
import 'package:calm_path/presentation/choose_mode/pages/choose_mode.dart';
import 'package:flutter/material.dart';

class GetStartedPage extends StatelessWidget {
  const GetStartedPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
              vertical: 70,
              horizontal: 40
            ),
            decoration:  BoxDecoration(
              
              image: DecorationImage(
                image: const AssetImage(
                  AppImages.introbg,
                ),
                fit: BoxFit.fill,
                colorFilter: ColorFilter.mode(
                Colors.black.withOpacity(0.4), // Add opacity to the image only
                BlendMode.dstATop,
                ),
              )
            ),
            child: Column(
              children: [
                Align(
                  alignment: Alignment.topCenter,
                
                 child:  Image.asset(
                  AppVectors.logoH
                ),
                ),
                const Spacer(),
                const Text(
                  'Give your stress wings and let it fly away',
                  style: TextStyle(
                    fontWeight:  FontWeight.bold,
                    color: Colors.white,
                    fontSize: 17
                  ),
                ),
                const SizedBox(height:21,),
                const Text(
                  'Alleviate stress and anxiety through exercise and meaningful connections',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: AppColors.grey,
                    fontSize: 13,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 21,),
                BasicButton(
                  onPressed: (){

                  
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (BuildContext context ) => const ChooseModePage()
                      )
                  ) ;
                  },
                  title: 'Get Started'
                  )
              ],
            ),
          ),
  
         

        ],
      ),
    );
  }
}