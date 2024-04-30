import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';import '../screens/all_bill/all_bill_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/order/order_screen.dart';
import '../screens/profile/profile_screen.dart';

// ignore: must_be_immutable
class BotomNavBar extends StatefulWidget {
  static const routeName='/botomnvabar';
  const BotomNavBar({super.key});

  @override
  State<BotomNavBar> createState() => _BotomNavBarState();
}

class _BotomNavBarState extends State<BotomNavBar> {
  int currentTabIndex = 0;

  late List<Widget> pages;
  late Widget currentPage;
  late HomeScreen homePage;
  late Profile profilePage;
  late Order orderPage;
  late AllBillsPage allBillsPage;
  @override
  void initState() {
    homePage = const HomeScreen();
    profilePage = const Profile();
    orderPage = const Order();
    allBillsPage= AllBillsPage();
    pages = [homePage, orderPage,allBillsPage, profilePage];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: CurvedNavigationBar(
          height: 65.0,
          backgroundColor: Colors.white,
          color: Colors.black,
          animationDuration: const Duration(milliseconds: 500),
          // ignore: prefer_const_literals_to_create_immutables
          onTap: (int index) {
            setState(() {
              currentTabIndex = index;
            });
          },
          // ignore: prefer_const_literals_to_create_immutables
          items:  [
            const Icon(Icons.home_outlined, color: Colors.white),
            const Icon(
              Icons.shopping_bag_outlined,
              color: Colors.white,
            ),
            const Icon(
              Icons.payment_outlined,
              color: Colors.white
            ),
            const Icon(
              Icons.person_outline,
              color: Colors.white,
            )
          ]),
      body: pages[currentTabIndex],
    );
  }
}
