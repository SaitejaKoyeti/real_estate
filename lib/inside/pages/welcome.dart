// import 'package:flutter/material.dart';
// import 'package:real_estate_project/login/loginform.dart';
//
// class WelcomeScreen extends StatefulWidget {
//   @override
//   _WelcomeScreenState createState() => _WelcomeScreenState();
// }
//
// class _WelcomeScreenState extends State<WelcomeScreen>
//     with SingleTickerProviderStateMixin {
//   final List<String> imageUrls = [
//     'https://content.jdmagicbox.com/comp/allahabad/b4/0532px532.x532.190510161607.y8b4/catalogue/n-i-real-estate-civil-lines-allahabad-estate-agents-yw16py6790.jpg',
//
//     "https://assets.site-static.com/userFiles/2464/image/real-estate-investment-types.jpg",
//     'https://previews.123rf.com/images/cunaplus/cunaplus1601/cunaplus160100253/52067987-businessman-is-making-a-positive-trend-in-investment-real-estate-concept-with-black-background.jpg',
//     'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRP3DhFIVGai7jq28TtSEFZy5GuKgXp8YYpnA&usqp=CAU'
// 'https://i.pinimg.com/736x/a8/b4/40/a8b4404a2a1e732c183fd0ca292faff8.jpg',
//     'https://wallpapers.com/images/hd/real-estate-background-image-v4tntoo3b4ajnner.jpg',
//     'https://i.pinimg.com/736x/a8/b4/40/a8b4404a2a1e732c183fd0ca292faff8.jpg',
//   ];
//
//   late PageController _pageController;
//   int _currentIndex = 0;
//
//   @override
//   void initState() {
//     super.initState();
//     _pageController = PageController(
//       initialPage: _currentIndex,
//     );
//     _startAutoSlide();
//   }
//
//   void _startAutoSlide() {
//     Future.delayed(Duration(seconds: 2), () {
//       _pageController.animateToPage(
//         (_currentIndex + 1) % imageUrls.length,
//         duration: Duration(seconds: 5),
//         curve: Curves.easeInOut,
//       );
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.black, // Set background color to black
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: <Widget>[
//             Expanded(
//               child: PageView.builder(
//                 controller: _pageController,
//                 itemCount: imageUrls.length,
//                 onPageChanged: (index) {
//                   setState(() {
//                     _currentIndex = index;
//                   });
//                   _startAutoSlide();
//                 },
//                 itemBuilder: (context, index) {
//                   return AnimatedOpacity(
//                     opacity: _currentIndex == index ? 1.0 : 0.0,
//                     duration: Duration(seconds: 1),
//                     curve: Curves.easeInOut,
//                     child: Image.network(
//                       imageUrls[index],
//                       fit: BoxFit.contain,
//                       errorBuilder: (BuildContext context, Object exception,
//                           StackTrace? stackTrace) {
//                         return Text('Failed to load image');
//                       },
//                     ),
//                   );
//                 },
//               ),
//             ),
//             SizedBox(height: 20.0),
//             ElevatedButton(
//               onPressed: () {
//                 Navigator.pushReplacement(
//                   context,
//                   MaterialPageRoute(builder: (context) => LoginPage()),
//                 );
//                 // Add navigation to next screen or functionality
//               },
//               child: Text('Get Started'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   @override
//   void dispose() {
//     _pageController.dispose();
//     super.dispose();
//   }
// };
import 'package:flutter/material.dart';

import '../../login/loginform.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({Key? key}) : super(key: key);

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child:SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  Image.asset(
                    'assets/images/istockphoto-1411304340-612x612.jpg',
                    // Adjust height as needed
                    fit: BoxFit.fill,
                  ),

                  Column(
                    children: [
                      SizedBox(height: 600,),
                      Text(
                        'Welcome to My App!',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => LoginPage()),
                          );
                        },
                        child: Text(
                          'Get Started',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          shape: StadiumBorder(),
                          primary: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
