import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:map_app/views/map_view.dart';
import 'package:map_app/pages/profile.dart';
import 'package:map_app/utils/theme_data.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  List<Widget> views = [];

  late PageController _pageController;
  late MapView _mapView;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _mapView = MapView();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      _pageController.animateToPage(index,
          duration: Duration(milliseconds: 500), curve: Curves.easeOut);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CustomTheme.darkBackground,
      body: SafeArea(
        child: SizedBox.expand(
          child: PageView(
            physics: NeverScrollableScrollPhysics(),
            controller: _pageController,
            onPageChanged: (index) {
              setState(() => _selectedIndex = index);
            },
            children: <Widget>[
              Profile(),
              _mapView,
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: CustomTheme.darkForeground,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.person_rounded),
            label: "Stats",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.map_rounded),
            label: "Map",
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: CustomTheme.highlight,
        unselectedItemColor: CustomTheme.inactive,
        onTap: _onItemTapped,
      ),
    );
  }
}
