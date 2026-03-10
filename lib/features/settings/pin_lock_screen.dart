import 'package:flutter/material.dart';
import 'package:caresync/shared/app_settings.dart';

/// Full-screen PIN lock. Set [verifyOnly] = true to just verify and pop(true/false).
/// Otherwise it guards the app on resume.
class PinLockScreen extends StatefulWidget {
  final bool verifyOnly;
  const PinLockScreen({super.key, this.verifyOnly = false});

  @override
  State<PinLockScreen> createState() => _PinLockScreenState();
}

class _PinLockScreenState extends State<PinLockScreen> {
  final _settings = AppSettings();
  String _pin = '';
  String? _error;
  bool _checking = false;

  void _onDigit(String d) {
    if (_checking || _pin.length >= 4) return;
    setState(() {
      _error = null;
      _pin += d;
    });
    if (_pin.length == 4) _verify();
  }

  void _onBackspace() {
    setState(() {
      _error = null;
      if (_pin.isNotEmpty) _pin = _pin.substring(0, _pin.length - 1);
    });
  }

  Future<void> _verify() async {
    setState(() => _checking = true);
    final ok = await _settings.verifyPin(_pin);
    if (!mounted) return;
    if (ok) {
      if (widget.verifyOnly) {
        Navigator.pop(context, true);
      } else {
        Navigator.pop(context, true);
      }
    } else {
      setState(() {
        _checking = false;
        _error = 'Incorrect PIN. Please try again.';
        _pin = '';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      // Prevent back-button dismissal (security)
      canPop: widget.verifyOnly,
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              if (widget.verifyOnly)
                Align(
                  alignment: Alignment.topLeft,
                  child: IconButton(
                    onPressed: () => Navigator.pop(context, false),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: const Color(0xFF2563EB).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.lock_rounded,
                  color: Color(0xFF2563EB),
                  size: 40,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Enter PIN',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 6),
              const Text(
                'Enter your 4-digit PIN to continue',
                style: TextStyle(fontSize: 14, color: Color(0xFF64748B)),
              ),
              const SizedBox(height: 36),
              // Dots
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  4,
                  (i) => AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    margin: const EdgeInsets.symmetric(horizontal: 10),
                    width: 18,
                    height: 18,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: i < _pin.length
                          ? const Color(0xFF2563EB)
                          : Colors.grey.shade300,
                    ),
                  ),
                ),
              ),
              if (_error != null) ...[
                const SizedBox(height: 14),
                Text(
                  _error!,
                  style: const TextStyle(color: Color(0xFFEF4444), fontSize: 13),
                ),
              ],
              const Spacer(),
              _Numpad(onDigit: _onDigit, onBackspace: _onBackspace),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

class _Numpad extends StatelessWidget {
  final void Function(String) onDigit;
  final VoidCallback onBackspace;

  const _Numpad({required this.onDigit, required this.onBackspace});

  @override
  Widget build(BuildContext context) {
    final keys = [
      ['1', '2', '3'],
      ['4', '5', '6'],
      ['7', '8', '9'],
      ['', '0', '⌫'],
    ];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        children: keys
            .map(
              (row) => Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: row
                    .map(
                      (k) => GestureDetector(
                        onTap: () {
                          if (k == '⌫') {
                            onBackspace();
                          } else if (k.isNotEmpty) {
                            onDigit(k);
                          }
                        },
                        child: Container(
                          width: 72,
                          height: 72,
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          alignment: Alignment.center,
                          decoration: k.isEmpty
                              ? null
                              : BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: k == '⌫'
                                      ? Colors.transparent
                                      : Colors.grey.shade100,
                                ),
                          child: k == '⌫'
                              ? const Icon(
                                  Icons.backspace_outlined,
                                  size: 22,
                                  color: Color(0xFF475569),
                                )
                              : k.isEmpty
                                  ? const SizedBox()
                                  : Text(
                                      k,
                                      style: const TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF1E293B),
                                      ),
                                    ),
                        ),
                      ),
                    )
                    .toList(),
              ),
            )
            .toList(),
      ),
    );
  }
}
