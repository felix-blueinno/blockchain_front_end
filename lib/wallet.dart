// ignore_for_file: prefer_const_constructors

import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'shared_variables.dart';

class Wallet extends StatefulWidget {
  const Wallet({Key? key}) : super(key: key);

  @override
  State<Wallet> createState() => _WalletState();
}

class _WalletState extends State<Wallet> {
  late Timer timer;

  final coinNames = [
    'bitcoin',
    'ethereum',
    'ripple',
    'litecoin',
    'bitcoin-cash',
    'cardano',
    'stellar',
    'tether',
  ];

  final Map<String, Map<String, dynamic>> coinInfo = {};

  @override
  void initState() {
    var url = Uri.parse('https://Blockchain.felixwong6.repl.co/get_balance');
    var headers = {'Content-Type': 'application/json'};
    var body = jsonEncode(
        {'username': SharedVars.username, 'password': SharedVars.password});

    timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      /// Get account balance:
      http.post(url, headers: headers, body: body).then((response) {
        if (response.statusCode == 200) {
          var json = jsonDecode(response.body);

          SharedVars.balance = json['balance'].toDouble();
          if (mounted) setState(() {});
        }
      }).onError((error, stackTrace) {
        print(error);
      });

      /// Get information for each coin:
      for (var name in coinNames) {
        var url = Uri.parse('https://api.coingecko.com/api/v3/coins/$name');

        http.get(url).then((value) {
          if (value.statusCode == 200) {
            Map<String, dynamic> coin = jsonDecode(value.body);

            if (coin.isNotEmpty) {
              coinInfo[name] = coin;
              print(coinInfo[name].runtimeType);
              if (mounted) setState(() {});
            }
          }
        }).timeout(Duration(seconds: 5), onTimeout: () {
          print('timeout');
        }).onError((error, stackTrace) {
          print(error);
        });
      }
    });

    super.initState();
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          balanceCard(context),
          favText(),
          Expanded(
            child: SizedBox(
              width: MediaQuery.of(context).size.width,
              child: coinInfo.isEmpty
                  ? Center(child: CircularProgressIndicator())
                  : ListView.separated(
                      itemCount: coinInfo.length,
                      separatorBuilder: (context, index) => Divider(),
                      itemBuilder: (context, index) {
                        if (!coinInfo.containsKey(coinNames[index])) {
                          return SizedBox();
                        }
                        if (coinInfo[coinNames[index]] is! Map) {
                          return SizedBox();
                        }
                        Map coin = coinInfo[coinNames[index]] as Map;

                        String imgSrc = coin['image']['large'];
                        String coinName = coin['name'];
                        var currentPrice =
                            coin['market_data']['current_price']['usd'];
                        var allTimeHigh = coin['market_data']['ath']['usd'];
                        var priceChange24H =
                            coin['market_data']['price_change_24h'];
                        var priceChange24HPercent =
                            coin['market_data']['price_change_percentage_24h'];

                        TextStyle style =
                            TextStyle(fontSize: 16, color: Colors.grey[800]);
                        return buildCoinCard(
                            coinName,
                            style,
                            allTimeHigh,
                            currentPrice,
                            priceChange24H,
                            priceChange24HPercent,
                            imgSrc);
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildCoinCard(
    String coinName,
    TextStyle style,
    allTimeHigh,
    currentPrice,
    priceChange24H,
    priceChange24HPercent,
    String imgSrc,
  ) {
    return SizedBox(
      width: double.infinity,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                coinName,
                style: style.copyWith(fontWeight: FontWeight.bold),
              ),
              Row(
                children: [
                  Text('All Time High: \$', style: style),
                  Text(allTimeHigh.toStringAsFixed(2), style: style),
                ],
              ),
              Row(
                children: [
                  Text('Current Price: \$', style: style),
                  Text(currentPrice.toStringAsFixed(2), style: style),
                ],
              ),
              Row(
                children: [
                  Text('Price Change: ', style: style),
                  Text(
                      priceChange24H > 0
                          ? '\$${priceChange24H.toStringAsFixed(2)}'
                          : '-\$${priceChange24H.abs().toStringAsFixed(2)}',
                      style: style.copyWith(
                          color:
                              priceChange24H > 0 ? Colors.green : Colors.red)),
                ],
              ),
              Row(
                children: [
                  Text('Price Change: ', style: style),
                  Text(
                    priceChange24HPercent > 0
                        ? '${priceChange24HPercent.toStringAsFixed(2)}%'
                        : '-${priceChange24HPercent.abs().toStringAsFixed(2)}%',
                    style: style.copyWith(
                        color: priceChange24H > 0 ? Colors.green : Colors.red),
                  ),
                ],
              ),
            ],
          ),
          Image.network(imgSrc, width: 80, height: 80),
        ],
      ),
    );
  }

  void depositDialog() {
    double amt = 0;

    showDialog(
        context: context,
        builder: (ctx) {
          return AlertDialog(
            title: const Text('Deposit'),
            content: TextField(
              decoration: const InputDecoration(labelText: 'Amount'),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                if (double.tryParse(value) != null) {
                  amt = double.parse(value);
                }
              },
            ),
            actions: [
              TextButton(
                  child: const Text('Cancel'),
                  onPressed: () => Navigator.pop(ctx)),
              ElevatedButton(
                child: const Text('Deposit'),
                onPressed: () {
                  if (amt <= 0) return;

                  var url = Uri.parse(
                      'https://Blockchain.felixwong6.repl.co/new_transaction');
                  var headers = {'Content-Type': 'application/json'};
                  var body = jsonEncode({
                    'from': '_',
                    'to': SharedVars.username,
                    'password': SharedVars.password,
                    'amount': amt
                  });

                  http.post(url, headers: headers, body: body).then((response) {
                    if (response.statusCode == 200) {
                      showSuccessDialog('Success', 'Deposit request succeed');
                    }
                  });

                  Navigator.pop(ctx);
                },
              ),
            ],
          );
        });
  }

  void showSuccessDialog(String title, String content) {
    showDialog(
        context: context,
        builder: (ctx) {
          return AlertDialog(
            title: Text(title),
            content: Text(content),
            actions: [
              TextButton(
                child: const Text('OK'),
                onPressed: () => Navigator.pop(ctx),
              ),
            ],
          );
        });
  }

  Widget balanceCard(BuildContext context) {
    return Container(
      width: double.infinity,
      height: MediaQuery.of(context).size.height * 0.35,
      decoration: BoxDecoration(
        color: Colors.indigo[200],
        borderRadius: BorderRadius.circular(30),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            const Spacer(),
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
                const Spacer(),
                const Icon(Icons.grid_view_outlined),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              '\$${SharedVars.balance}',
              style: const TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
            ),
            Row(
              children: [
                ElevatedButton(
                  child: Text(
                    'Transfer',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  onPressed: () {},
                ),
                const SizedBox(width: 16),
                TextButton(
                  onPressed: () => depositDialog(),
                  style:
                      TextButton.styleFrom(backgroundColor: Colors.indigo[200]),
                  child: Text(
                    'Deposit',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget favText() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          const Text(
            'FAVOURITE',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.more_horiz),
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}
