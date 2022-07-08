import 'package:blockchain_front_end/chain.dart';
import 'package:blockchain_front_end/history.dart';
import 'package:blockchain_front_end/wallet.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: pages[pageIndex],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: pageIndex,
        showUnselectedLabels: false,
        onTap: (index) => setState(() => pageIndex = index),
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.account_balance_wallet), label: 'Wallet'),
          BottomNavigationBarItem(icon: Icon(Icons.api_sharp), label: 'Chain'),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'History'),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () =>
            http.get(Uri.parse('https://Blockchain.felixwong6.repl.co/mine')),
        child: const Icon(Icons.wb_twilight_rounded),
      ),
    );
  }
}
