import 'package:flutter/material.dart';

void main() {
  runApp(const CalculatorApp());
}

class CalculatorApp extends StatelessWidget {
  const CalculatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Calculator',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
      ),
      home: const CalculatorScreen(),
    );
  }
}

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  final List<String> buttons = [
    'AC', '±', '%', '÷',
    '7', '8', '9', 'x',
    '4', '5', '6', '-',
    '1', '2', '3', '+',
    '0', ' ', 'DEL', '='
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calculator'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TextField(
            readOnly: true,
            showCursor: true,
            textAlign: TextAlign.right,
            style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold)
          ),

          SizedBox(height: 40),

          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                mainAxisSpacing: 3.5,
                crossAxisSpacing: 3.5,
              ),
              itemCount: buttons.length,
              itemBuilder: (context, index) {
                return ElevatedButton(
                    onPressed: () {
                    setState(() {
                      String buttonText = buttons[index];
                      if (buttonText == 'AC') {
                      // Clear all
                      } else if (buttonText == 'DEL') {
                      // Delete last character
                      } else if (buttonText == '=') {
                      // Calculate result
                      } else {
                      // Append to display
                      }
                    });
                    },
                  child: buttons[index] == 'DEL' ? 
                  Icon(Icons.backspace, size: 35) : 
                  Text(buttons[index], style: const TextStyle(fontSize: 35, fontWeight: FontWeight.bold))
                );
              }
            ),
          ),
        ],
      ),
    );
  }
}
