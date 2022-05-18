import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class Chain extends StatefulWidget {
  const Chain({Key? key}) : super(key: key);

  @override
  State<Chain> createState() => _ChainState();
}

class _ChainState extends State<Chain> {
  List<Step> steps = [];
  int _currentStep = 0;
  int prevChainLength = 0;
  Key stepperKey = UniqueKey();
  bool isPublic = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: () => setState(() => isPublic = !isPublic),
            icon: Icon(isPublic ? Icons.visibility_off : Icons.visibility),
          ),
        ],
      ),
      body: StreamBuilder<http.Response>(
        stream: chainStream(),
        builder: (context, response) {
          if (response.hasData && response.data!.statusCode == 200) {
            try {
              Map<String, dynamic> json = jsonDecode(response.data!.body);
              steps = generateSteps(json);

              if (prevChainLength != steps.length) {
                prevChainLength = steps.length;
                stepperKey = UniqueKey();
              }
            } catch (e) {
              print(e);
            }
          }

          return steps.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : Stepper(
                  /// Use the same key to prevent stepper repaint every frame
                  /// this solves issue of stepper crashing when steps amount changes
                  /// https://github.com/flutter/flutter/issues/27187
                  key: stepperKey,
                  steps: steps,
                  controlsBuilder: (_, __) => const SizedBox(),
                  currentStep: _currentStep,
                  onStepTapped: (index) => setState(() => _currentStep = index),
                );
        },
      ),
    );
  }

  Stream<http.Response> chainStream() {
    return Stream.periodic(const Duration(seconds: 5))
        .asyncMap((_) async => await http
            .get(Uri.parse('https://Blockchain.felixwong6.repl.co/chain')))
        .timeout(const Duration(seconds: 5));
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

      final date =
          DateTime.fromMillisecondsSinceEpoch(timestamp.toInt() * 1000);
      final formattedDate = DateFormat("yyyy-MM-dd, HH:mm:ss").format(date);

      final step = Step(
        isActive: _currentStep == steps.length,
        title: Text('Block #${steps.length + 1}'),
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
      steps.add(step);
    }
    return steps;
  }
}
