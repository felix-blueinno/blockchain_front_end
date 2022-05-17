import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class DashBoard extends StatefulWidget {
  const DashBoard({Key? key}) : super(key: key);

  @override
  State<DashBoard> createState() => _DashBoardState();
}

class _DashBoardState extends State<DashBoard> {
  int _currentStep = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<http.Response>(
        stream: chainStream(),
        builder: (context, response) {
          if (response.hasError) {
            return Center(child: Text('Error: ${response.error}'));
          }
          if (response.hasData) {
            Map<String, dynamic> json = jsonDecode(response.data!.body);

            final List<Step> steps = generateSteps(json);
            return Stepper(
              steps: steps,
              controlsBuilder: (_, __) => const SizedBox(),
              currentStep: _currentStep,
              onStepTapped: (index) => setState(() => _currentStep = index),
            );
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

  List<Step> generateSteps(Map<String, dynamic> json) {
    final List<Step> steps = [];

    final chain = json['chain'] as List<dynamic>;
    for (Map b in chain) {
      final tx = b['transaction'];
      final from = tx['from'];
      final to = tx['to'];
      final amount = tx['amount'];

      final nonce = b['nonce'];
      final prevHash = b['prev_hash'];
      final hash = b['hash'];
      final timestamp = b['timestamp'];

      final step = Step(
        isActive: _currentStep == steps.length,
        title: Text('Block #${steps.length}'),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('From: $from'),
            Text('To: $to'),
            Text('Amount: $amount'),
            Text('Nonce: $nonce'),
            Text('Prev Hash: $prevHash'),
            Text('Hash: $hash'),
            Text('Timestamp: $timestamp'),
          ],
        ),
      );
      steps.add(step);
    }
    return steps;
  }
}
