// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors

import 'package:flutter/material.dart';

class Wallet extends StatefulWidget {
  const Wallet({Key? key}) : super(key: key);

  @override
  State<Wallet> createState() => _WalletState();
}

class _WalletState extends State<Wallet> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          balanceCard(context),
        ],
      ),
    );
  }

  Widget balanceCard(BuildContext context) {
    return Container(
      width: double.infinity,
      height: MediaQuery.of(context).size.height * 0.3,
      decoration: BoxDecoration(
        color: Colors.indigo[200],
        borderRadius: BorderRadius.circular(30),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 32),
            Row(
              children: [
                ClipOval(
                  child: Image.network(
                    'https://picsum.photos/200',
                    fit: BoxFit.cover,
                    width: 48 * 2,
                    height: 48 * 2,
                  ),
                ),
                Spacer(),
                Icon(Icons.grid_view_outlined),
              ],
            ),
            SizedBox(height: 16),
            Text(
              '\$12,345,678',
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                //       color: Colors.white,
              ),
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Chip(
                  label: Text('2.49%'),
                  backgroundColor: Colors.white30,
                ),
                SizedBox(width: 16),
                Chip(
                  label: Text('+ \$7890'),
                  backgroundColor: Colors.indigo[200],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
