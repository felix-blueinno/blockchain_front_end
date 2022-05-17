import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class DashBoard extends StatelessWidget {
  const DashBoard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<http.Response>(
        stream: chainStream(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (snapshot.hasData) {
            return Center(child: Text(snapshot.data!.body));
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  Stream<http.Response> chainStream() {
    return Stream.periodic(const Duration(seconds: 5)).asyncMap((_) async =>
        await http
            .get(Uri.parse('https://Blockchain.felixwong6.repl.co/chain')));
  }
}
