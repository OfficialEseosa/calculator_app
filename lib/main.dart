import 'package:flutter/material.dart';

void main() {
  runApp(const CalculatorApp());
}

class CalculatorApp extends StatefulWidget {
  const CalculatorApp({super.key});

  @override
  State<CalculatorApp> createState() => _CalculatorAppState();
}

class _CalculatorAppState extends State<CalculatorApp> {
  bool _isDarkMode = false;

  void _toggleTheme() {
    setState(() {
      _isDarkMode = !_isDarkMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Calculator',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: _isDarkMode ? Brightness.dark : Brightness.light,
        ),
        brightness: _isDarkMode ? Brightness.dark : Brightness.light,
      ),
      home: CalculatorScreen(
        isDarkMode: _isDarkMode,
        onToggleTheme: _toggleTheme,
      ),
    );
  }
}

class CalculatorScreen extends StatefulWidget {
  final bool isDarkMode;
  final VoidCallback onToggleTheme;

  const CalculatorScreen({
    super.key,
    required this.isDarkMode,
    required this.onToggleTheme,
  });

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  final List<String> buttons = [
    'C', '±', '%', '÷',
    '7', '8', '9', 'x',
    '4', '5', '6', '-',
    '1', '2', '3', '+',
    '0', '.', 'DEL', '=',
  ];

  final TextEditingController _controller = TextEditingController(text: '0');

  String _expression = '';
  String _firstOperand = '';
  String _operator = '';
  bool _shouldResetDisplay = false;
  bool _calculated = false;

  final List<String> _operators = ['÷', 'x', '-', '+'];

  bool _isOperator(String s) => _operators.contains(s);

  void _allClear() {
    _controller.text = '0';
    _expression = '';
    _firstOperand = '';
    _operator = '';
    _shouldResetDisplay = false;
    _calculated = false;
  }

  void _handleButtonPress(String btn) {
    setState(() {
      if (btn == 'C') {
        _allClear();
      } else if (btn == 'DEL') {
        _handleDelete();
      } else if (btn == '±') {
        _handleToggleSign();
      } else if (btn == '%') {
        _handlePercent();
      } else if (_isOperator(btn)) {
        _handleOperator(btn);
      } else if (btn == '.') {
        _handleDecimal();
      } else if (btn == '=') {
        _handleEquals();
      } else {
        _handleDigit(btn);
      }
    });
  }

  void _handleDigit(String digit) {
    if (_calculated) {
      _expression = digit;
      _controller.text = digit;
      _calculated = false;
      _shouldResetDisplay = false;
    } else if (_shouldResetDisplay) {
      _expression += digit;
      _controller.text = _expression;
      _shouldResetDisplay = false;
    } else if (_expression.isEmpty || _expression == '0') {
      _expression = digit;
      _controller.text = digit;
    } else {
      _expression += digit;
      _controller.text = _expression;
    }
  }

  void _handleDecimal() {
    if (_calculated) {
      _expression = '0.';
      _controller.text = '0.';
      _shouldResetDisplay = false;
      _calculated = false;
      return;
    }
    if (_shouldResetDisplay) {
      _expression += '0.';
      _controller.text = _expression;
      _shouldResetDisplay = false;
      return;
    }
    String lastNumber = _getLastNumber();
    if (!lastNumber.contains('.')) {
      _expression += '.';
      _controller.text = _expression;
    }
  }

  String _getLastNumber() {
    String result = '';
    for (int i = _expression.length - 1; i >= 0; i--) {
      if ('÷x-+'.contains(_expression[i]) && result.isNotEmpty) break;
      result = _expression[i] + result;
    }
    return result;
  }

  void _handleDelete() {
    if (_expression.length > 1 && _controller.text != 'Error') {
      _expression = _expression.substring(0, _expression.length - 1);
      _controller.text = _expression;
    } else {
      _expression = '0';
      _controller.text = '0';
    }
  }

  void _handleToggleSign() {
    if (_controller.text == '0' || _controller.text == 'Error') return;
    String lastNum = _getLastNumber();
    if (lastNum.isEmpty) return;
    int start = _expression.length - lastNum.length;
    String prefix = _expression.substring(0, start);
    if (lastNum.startsWith('-')) {
      lastNum = lastNum.substring(1);
    } else {
      lastNum = '-$lastNum';
    }
    _expression = prefix + lastNum;
    _controller.text = _expression;
  }

  void _handlePercent() {
    if (_controller.text == 'Error') return;
    String lastNum = _getLastNumber();
    final double current = double.tryParse(lastNum) ?? 0;

    if (_firstOperand.isNotEmpty && _operator.isNotEmpty) {
      final double base = double.tryParse(_firstOperand) ?? 0;
      final double percentValue = base * (current / 100);
      String result = _formatResult(percentValue);
      int start = _expression.length - lastNum.length;
      _expression = _expression.substring(0, start) + result;
      _controller.text = _expression;
    } else {
      String result = _formatResult(current / 100);
      _expression = result;
      _controller.text = result;
    }
  }

  void _handleOperator(String op) {
    if (_controller.text == 'Error') {
      _allClear();
      return;
    }

    String lastNum = _getLastNumber();

    if (_firstOperand.isNotEmpty &&
        _operator.isNotEmpty &&
        !_shouldResetDisplay) {
      final result = _evaluate(
        double.tryParse(_firstOperand) ?? 0,
        _operator,
        double.tryParse(lastNum) ?? 0,
      );
      if (result == null) {
        _controller.text = 'Error';
        _expression = '';
        _firstOperand = '';
        _operator = '';
        return;
      }
      String formatted = _formatResult(result);
      _firstOperand = formatted;
      _expression = formatted + op;
      _controller.text = _expression;
    } else {
      _firstOperand = lastNum;
      _expression += op;
      _controller.text = _expression;
    }

    _operator = op;
    _shouldResetDisplay = true;
    _calculated = false;
  }

  void _handleEquals() {
    if (_controller.text == 'Error') return;
    if (_firstOperand.isEmpty || _operator.isEmpty) return;

    String lastNum = _getLastNumber();
    final double left = double.tryParse(_firstOperand) ?? 0;
    final double right = double.tryParse(lastNum) ?? 0;

    final result = _evaluate(left, _operator, right);
    if (result == null) {
      _controller.text = 'Error';
      _expression = '';
    } else {
      String formatted = _formatResult(result);
      _controller.text = formatted;
      _expression = formatted;
    }

    _firstOperand = '';
    _operator = '';
    _shouldResetDisplay = false;
    _calculated = true;
  }

  double? _evaluate(double a, String op, double b) {
    switch (op) {
      case '+':
        return a + b;
      case '-':
        return a - b;
      case 'x':
        return a * b;
      case '÷':
        if (b == 0) return null;
        return a / b;
      default:
        return null;
    }
  }

  String _formatResult(double value) {
    if (value.isInfinite || value.isNaN) return 'Error';
    if (value == value.truncateToDouble()) {
      return value.toInt().toString();
    }
    return double.parse(value.toStringAsFixed(10)).toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calculator'),
        actions: [
          IconButton(
            icon: Icon(
              widget.isDarkMode ? Icons.wb_sunny : Icons.nightlight_round,
            ),
            onPressed: widget.onToggleTheme,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              alignment: Alignment.bottomRight,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              child: TextField(
                readOnly: true,
                showCursor: true,
                textAlign: TextAlign.right,
                style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                ),
                controller: _controller,
              ),
            ),
          ),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.all(8),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
            ),
            itemCount: buttons.length,
            itemBuilder: (context, index) {
              return ElevatedButton(
                onPressed: () => _handleButtonPress(buttons[index]),
                child: buttons[index] == 'DEL'
                    ? const Icon(Icons.backspace, size: 28)
                    : Text(
                        buttons[index] == 'C'
                            ? (_firstOperand.isNotEmpty ||
                                    _operator.isNotEmpty ||
                                    _controller.text != '0'
                                ? 'AC'
                                : 'C')
                            : buttons[index],
                        style: const TextStyle(
                            fontSize: 28, fontWeight: FontWeight.bold),
                      ),
              );
            },
          ),
        ],
      ),
    );
  }
}
