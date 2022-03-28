import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:map_app/pages/overview.dart';
import 'package:map_app/views/map_view.dart';
import 'package:map_app/pages/technical.dart';
import 'package:map_app/utils/theme_data.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex =
      0; // for selection of the three panels of the bottom nav menu bar

  late PageController _pageController; // controls swiping between pages
  late MapView _mapView; // the map ui

  @override
  void initState() {
    // init page and map
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
    // when a navigation item is tapped, do swipe animation to that page
    setState(() {
      _selectedIndex = index;
      _pageController.animateToPage(index,
          duration: Duration(milliseconds: 500), curve: Curves.easeOut);
    });
  }

  @override
  Widget build(BuildContext context) {
    // build the home screen
    return Scaffold(
      backgroundColor: CustomTheme.background,
      body: SafeArea(
        child: SizedBox.expand(
          child: PageView(
            physics: NeverScrollableScrollPhysics(),
            controller: _pageController,
            onPageChanged: (index) {
              setState(() => _selectedIndex =
                  index); // refresh the state when a page is changed
            },
            children: <Widget>[
              Overview(),
              Technical(),
              _mapView,
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        // build the nav bar
        backgroundColor: CustomTheme.secondary,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.person_rounded),
            label: "Overview",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: "Technical",
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
