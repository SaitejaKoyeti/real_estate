import 'package:flutter/material.dart';

class NavigationProvider with ChangeNotifier {
  int _currentIndex = 0;
  PageController _pageController = PageController(initialPage: 0);

  int get currentIndex => _currentIndex;
  PageController get pageController => _pageController;

  set currentIndex(int index) {
    _currentIndex = index;
    notifyListeners();
  }

  // Remember to dispose of the page controller when the provider is disposed
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}