import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'main_screen.dart';

class PinScreen extends StatefulWidget {
  const PinScreen({super.key});

  @override
  State<PinScreen> createState() => _PinScreenState();
}

class _PinScreenState extends State<PinScreen> with TickerProviderStateMixin {
  String _pin = '';
  String _confirmPin = '';
  bool _isSetup = false;
  bool _isConfirming = false;
  bool _hasError = false;
  late AnimationController _shakeCtrl;
  late Animation<double> _shakeAnim;

  @override
  void initState() {
    super.initState();
    _shakeCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 400));
    _shakeAnim = Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(parent: _shakeCtrl, curve: Curves.elasticIn));
    _checkPin();
  }

  @override
  void dispose() {
    _shakeCtrl.dispose();
    super.dispose();
  }

  Future<void> _checkPin() async {
    final prefs = await SharedPreferences.getInstance();
    final savedPin = prefs.getString('app_pin');
    setState(() => _isSetup = savedPin == null);
  }

  Future<void> _handlePin(String digit) async {
    if (_pin.length >= 4) return;
    setState(() {
      _pin += digit;
      _hasError = false;
    });

    if (_pin.length == 4) {
      await Future.delayed(const Duration(milliseconds: 200));
      final prefs = await SharedPreferences.getInstance();

      if (_isSetup) {
        if (!_isConfirming) {
          setState(() {
            _confirmPin = _pin;
            _pin = '';
            _isConfirming = true;
          });
        } else {
          if (_pin == _confirmPin) {
            await prefs.setString('app_pin', _pin);
            _goHome();
          } else {
            _shake();
            setState(() {
              _pin = '';
              _confirmPin = '';
              _isConfirming = false;
            });
          }
        }
      } else {
        final savedPin = prefs.getString('app_pin');
        if (_pin == savedPin) {
          _goHome();
        } else {
          _shake();
          setState(() => _pin = '');
        }
      }
    }
  }

  void _shake() {
    setState(() => _hasError = true);
    _shakeCtrl.forward(from: 0);
  }

  void _goHome() {
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const MainScreen(),
        transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: child),
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }

  void _deletePin() {
    if (_pin.isNotEmpty) setState(() => _pin = _pin.substring(0, _pin.length - 1));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF7B2FF7), Color(0xFFF107A3)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 60),

              // Icon
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white24,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.lock_outline,
                    size: 40, color: Colors.white),
              ),
              const SizedBox(height: 20),

              Text(
                _isSetup
                    ? (_isConfirming ? 'Confirmer le PIN' : 'Créer un PIN')
                    : 'Entrer le PIN',
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                _isSetup
                    ? (_isConfirming
                        ? 'Répétez votre PIN'
                        : 'Choisissez un PIN à 4 chiffres')
                    : 'Bienvenue !',
                style: TextStyle(
                    color: Colors.white.withOpacity(0.8), fontSize: 14),
              ),
              const SizedBox(height: 40),

              // PIN dots
              AnimatedBuilder(
                animation: _shakeAnim,
                builder: (_, child) {
                  final offset = _hasError
                      ? 10 * (0.5 - (_shakeAnim.value % 0.25) / 0.25).abs()
                      : 0.0;
                  return Transform.translate(
                    offset: Offset(offset, 0),
                    child: child,
                  );
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(4, (i) {
                    final filled = i < _pin.length;
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.symmetric(horizontal: 10),
                      width: filled ? 20 : 16,
                      height: filled ? 20 : 16,
                      decoration: BoxDecoration(
                        color: _hasError
                            ? Colors.redAccent
                            : filled
                                ? Colors.white
                                : Colors.white38,
                        shape: BoxShape.circle,
                        boxShadow: filled
                            ? [
                                BoxShadow(
                                  color: Colors.white.withOpacity(0.5),
                                  blurRadius: 8,
                                )
                              ]
                            : [],
                      ),
                    );
                  }),
                ),
              ),

              if (_hasError) ...[
                const SizedBox(height: 12),
                const Text('PIN incorrect !',
                    style: TextStyle(color: Colors.redAccent, fontSize: 13)),
              ],

              const Spacer(),

              // Keypad
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Column(
                  children: [
                    for (var row in [
                      ['1', '2', '3'],
                      ['4', '5', '6'],
                      ['7', '8', '9'],
                      ['', '0', '⌫'],
                    ])
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: row.map((d) => _keyButton(d)).toList(),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _keyButton(String digit) {
    if (digit.isEmpty) return const SizedBox(width: 80, height: 80);
    return GestureDetector(
      onTap: () => digit == '⌫' ? _deletePin() : _handlePin(digit),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        width: 80,
        height: 80,
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: digit == '⌫'
              ? Colors.white12
              : Colors.white24,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white24),
        ),
        child: Center(
          child: digit == '⌫'
              ? const Icon(Icons.backspace_outlined,
                  color: Colors.white, size: 22)
              : Text(digit,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }
}