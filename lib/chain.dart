import 'dart:async';
import 'dart:convert';
import 'package:blockchain_front_end/shared_variables.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Chain extends StatefulWidget {
  const Chain({Key? key}) : super(key: key);

  @override
  State<Chain> createState() => _ChainState();
}

class _ChainState extends State<Chain> {
  late Timer timer;

  int _currentStep = 0;
  int prevChainLength = 0;
  Key stepperKey = UniqueKey();
  bool isPublic = false;

  @override
  void initState() {
    timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      http
          .get(Uri.parse('https://Blockchain.felixwong6.repl.co/chain'))
          .then((response) {
        if (response.statusCode == 200) {
          SharedVars.chain = response.body;
          if (mounted) setState(() {});
        }
      }).onError((error, stackTrace) {
        print(error);
      });

      http
          .get(
              Uri.parse('https://Blockchain.felixwong6.repl.co/unmined_blocks'))
          .then((response) {
        if (response.statusCode == 200) {
          SharedVars.unminedChain = response.body;

          if (mounted) setState(() {});
        }
      }).onError((error, stackTrace) {
        print(error);
      });
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
      appBar: AppBar(title: const Text('Chain'), actions: [
        IconButton(
          onPressed: () => setState(() => isPublic = !isPublic),
          icon: Icon(isPublic ? Icons.visibility_off : Icons.visibility),
        ),
      ]),
      body: SharedVars.chain.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : buildSteps(),
    );
  }

  Widget buildSteps() {
    Map<String, dynamic> json = jsonDecode(SharedVars.chain);
    final chain = json['chain'] as List<dynamic>;

    if (prevChainLength != chain.length) {
      prevChainLength = chain.length;
      stepperKey = UniqueKey();
    }

    return Stepper(
      key: stepperKey,
      currentStep: _currentStep,
      onStepTapped: (index) => setState(() => _currentStep = index),
      controlsBuilder: (_, __) => const SizedBox(),
      steps: List.generate(
        chain.length,
        (index) {
          final b = chain[index];

          final tx = b['transaction'];
          final from = tx['from'];
          final to = tx['to'];
          final amount = tx['amount'];

          final nonce = b['nonce'];
          final prevHash = b['prev_hash'];
          final hash = b['hash'];
          final timestamp = b['timestamp'];

          final date =
              DateTime.fromMillisecondsSinceEpoch(timestamp.toInt() * 1000);
          final formattedDate = DateFormat("yyyy-MM-dd, HH:mm:ss").format(date);

          return Step(
            state: StepState.complete,
            isActive: index == _currentStep,
            title: Text('Block #$index'),
            subtitle: Text(formattedDate),
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (isPublic) Text('From: $from'),
                if (isPublic) Text('To: $to'),
                if (isPublic) Text('Amount: \$$amount'),
                Text('Nonce: $nonce'),
                Text('Prev Hash: $prevHash'),
                Text('Hash: $hash'),
              ],
            ),
          );
        },
      ),
    );
  }
}
