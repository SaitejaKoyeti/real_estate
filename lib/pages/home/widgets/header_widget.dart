import 'package:flutter/material.dart';

import '../../../responsive.dart';

class Header extends StatefulWidget {
  const Header({
    Key? key,
    required this.scaffoldKey,
  }) : super(key: key);

  final GlobalKey<ScaffoldState> scaffoldKey;

  @override
  _HeaderState createState() => _HeaderState();
}

class _HeaderState extends State<Header> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 5), // Adjust the duration as needed
    )..repeat(reverse: true);

    _animation = Tween<double>(
      begin: 0.0,
      end: 480.0, // Adjust the distance to move
    ).animate(_controller);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 35,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (!Responsive.isDesktop(context))
            Padding(
              padding: const EdgeInsets.only(right: 20),
              child: InkWell(
                onTap: () => widget.scaffoldKey.currentState!.openDrawer(),
                child: const Padding(
                  padding: EdgeInsets.all(3.0),
                  child: Icon(
                    Icons.menu,
                    color: Colors.white,
                    size: 25,
                  ),
                ),
              ),
            ),

          if (!Responsive.isMobile(context))
            Expanded(
              flex: 5,
              child: AnimatedBuilder(
                animation: _animation,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(_animation.value, 0),
                    child: Text(
                      'Welcome Admin, Have a nice day',
                      style: TextStyle(
                        color: Colors.lightBlueAccent, // Change to the desired color
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  );
                },
              ),
            ),

          if (Responsive.isMobile(context))
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // IconButton(
                //   icon: const Icon(
                //     Icons.search,
                //     color: Colors.white,
                //     size: 25,
                //   ),
                //   onPressed: () {},
                // ),
                InkWell(
                  onTap: () => widget.scaffoldKey.currentState!.openEndDrawer(),
                  child: CircleAvatar(
                    backgroundColor: Colors.transparent,
                    child: Icon(
                      Icons.expand_more, // Replace with your desired icon
                      color: Colors.white, // Customize the icon color
                      size: 32, // Customize the icon size
                    ),
                  ),
                )

              ],
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}