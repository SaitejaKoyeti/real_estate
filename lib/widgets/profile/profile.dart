import 'package:flutter/material.dart';
import 'package:real_estate/widgets/profile/widgets/scheduled.dart';

import '../../const.dart';
import '../../responsive.dart';


class Profile extends StatelessWidget {
  const Profile({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(Responsive.isMobile(context) ? 10 : 30.0),
          topLeft: Radius.circular(Responsive.isMobile(context) ? 10 : 30.0),
        ),
        color: cardBackgroundColor,
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            children: [
              // const SizedBox(
              //   height:   50,
              // ),
              Image.asset(
                "assets/images/logo.png",
                height: 250,
                width: 400,
              ),
              // const SizedBox(
              //   height: 15,
              // ),
              // const Text(
              //   "Summer",
              //   style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              // ),
              // const SizedBox(
              //   height: 2,
              // ),
              // Text(
              //   "Edit health details",
              //   style: TextStyle(
              //     fontSize: 12,
              //     color: Theme.of(context).primaryColor,
              //   ),
              // ),
              Padding(
                padding:
                EdgeInsets.all(Responsive.isMobile(context) ? 05 : 05.0),
                // child:  SalesScreen(),
              ),
              // SizedBox(
              //   height: Responsive.isMobile(context) ? 20 : 40,
              // ),

              Scheduled()
            ],
          ),
        ),
      ),
    );
  }
}