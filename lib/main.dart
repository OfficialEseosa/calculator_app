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

  final TextEditingController _controller = TextEditingController();
  final List<String> _operators = ['÷', 'x', '-', '+'];

  List<String> _tokens = [];
  int _pos = 0;

  bool _isOperator(String s) => _operators.contains(s);
  bool _endsWithOperator(String text) =>
      text.isNotEmpty && _isOperator(text[text.length - 1]);

  void _handleButtonPress(String buttonText) {
    if (buttonText.trim().isEmpty) return;
    setState(() {
      final current = _controller.text;
      if (buttonText == 'AC') {
        _controller.text = '';
      } else if (buttonText == 'DEL') {
        if (current.isNotEmpty) {
          _controller.text = current.substring(0, current.length - 1);
        }
      } else if (buttonText == '=') {
        try {
          _controller.text = _calculate(current);
        } catch (_) {
          _controller.text = 'Error';
        }
      } else if (buttonText == '±') {
        _controller.text = _toggleSign(current);
      } else if (buttonText == '%') {
        if (current.isNotEmpty && !_endsWithOperator(current) && !current.endsWith('%')) {
          _controller.text = current + '%';
        }
      } else if (_isOperator(buttonText)) {
        if (current.isEmpty) return;
        if (_endsWithOperator(current)) {
          _controller.text = current.substring(0, current.length - 1) + buttonText;
        } else {
          _controller.text = current + buttonText;
        }
      } else {
        _controller.text = current + buttonText;
      }
    });
  }

  String _toggleSign(String expression) {
    if (expression.isEmpty) return expression;

    int i = expression.length - 1;
    while (i >= 0 && RegExp(r'[0-9.%]').hasMatch(expression[i])) i--;

    final numPart = expression.substring(i + 1);
    if (numPart.isEmpty || numPart == '0') return expression;

    if (i >= 0 && expression[i] == '-') {
      final bool isUnary = i == 0 || _isOperator(expression[i - 1]);
      if (isUnary) {
        return expression.substring(0, i) + numPart;
      }
    }

    final prefix = expression.substring(0, i + 1);
    return prefix + '-' + numPart;
  }

  String _calculate(String expression) {
    if (expression.isEmpty) return '0';

    while (expression.isNotEmpty &&
        (_isOperator(expression[expression.length - 1]) ||
            expression[expression.length - 1] == '%')) {
      expression = expression.substring(0, expression.length - 1);
    }
    if (expression.isEmpty) return '0';

    expression = expression.replaceAllMapped(
      RegExp(r'(\d+\.?\d*)%'),
      (m) => '(${m.group(1)}/100)',
    );
    expression = expression.replaceAll('x', '*').replaceAll('÷', '/');

    final result = _eval(expression);

    if (result == result.truncateToDouble()) {
      return result.toInt().toString();
    }
    return double.parse(result.toStringAsFixed(10)).toString();
  }

  double _eval(String expression) {
    _tokens = _tokenize(expression);
    _pos = 0;
    return _parseExpr();
  }

  List<String> _tokenize(String expr) {
    final tokens = <String>[];
    int i = 0;
    while (i < expr.length) {
      if (expr[i] == ' ') { i++; continue; }
      if (RegExp(r'[0-9.]').hasMatch(expr[i])) {
        int j = i;
        while (j < expr.length && RegExp(r'[0-9.]').hasMatch(expr[j])) j++;
        tokens.add(expr.substring(i, j));
        i = j;
      } else if ('+-*/()'.contains(expr[i])) {
        tokens.add(expr[i]);
        i++;
      } else {
        i++;
      }
    }
    return tokens;
  }

  double _parseExpr() {
    double result = _parseTerm();
    while (_pos < _tokens.length && (_tokens[_pos] == '+' || _tokens[_pos] == '-')) {
      final op = _tokens[_pos++];
      final right = _parseTerm();
      result = op == '+' ? result + right : result - right;
    }
    return result;
  }

  double _parseTerm() {
    double result = _parseFactor();
    while (_pos < _tokens.length && (_tokens[_pos] == '*' || _tokens[_pos] == '/')) {
      final op = _tokens[_pos++];
      final right = _parseFactor();
      result = op == '*' ? result * right : result / right;
    }
    return result;
  }

  double _parseFactor() {
    if (_pos >= _tokens.length) return 0;
    final token = _tokens[_pos++];
    if (token == '(') {
      final result = _parseExpr();
      if (_pos < _tokens.length) _pos++;
      return result;
    }
    if (token == '-') return -_parseFactor();
    return double.parse(token);
  }

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
            style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            controller: _controller,
          ),

          const SizedBox(height: 40),

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
                  onPressed: () => _handleButtonPress(buttons[index]),
                  child: buttons[index] == 'DEL'
                      ? const Icon(Icons.backspace, size: 35)
                      : Text(
                          buttons[index],
                          style: const TextStyle(fontSize: 35, fontWeight: FontWeight.bold),
                        ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
