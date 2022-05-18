import 'package:blockchain_front_end/chain.dart';
import 'package:blockchain_front_end/history.dart';
import 'package:blockchain_front_end/wallet.dart';
import 'package:flutter/material.dart';

class DashBoard extends StatefulWidget {
  const DashBoard({Key? key}) : super(key: key);

  @override
  State<DashBoard> createState() => _DashBoardState();
}

class _DashBoardState extends State<DashBoard> {
  int pageIndex = 0;
  final pages = [const Wallet(), const Chain(), const History()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: pageIndex,
        children: pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: pageIndex,
        showUnselectedLabels: false,
        onTap: (index) => setState(() => pageIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance_wallet),
            label: 'Wallet',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.api_sharp),
            label: 'Chain',
          ),
        ],
      ),
    );
  }
}
