import 'package:flutter/material.dart';
import 'package:caresync/shared/app_settings.dart';
import 'pin_lock_screen.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final _settings = AppSettings();

  @override
  void initState() {
    super.initState();
    _settings.addListener(_rebuild);
  }

  @override
  void dispose() {
    _settings.removeListener(_rebuild);
    super.dispose();
  }

  void _rebuild() => setState(() {});

  // ── Font scale options ────────────────────────────────────────────────────
  static const _fontScales = [
    (0.85, 'Small', Icons.text_fields),
    (1.0, 'Normal', Icons.text_fields),
    (1.15, 'Large', Icons.text_fields),
    (1.30, 'Extra Large', Icons.text_fields),
  ];

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = _settings.themeMode == ThemeMode.dark;

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          // ── Appearance ─────────────────────────────────────────────────
          _Section(title: 'Appearance', icon: Icons.palette_outlined),

          // Dark mode tile
          _SettingsTile(
            icon: isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
            iconColor: isDark ? const Color(0xFF818CF8) : const Color(0xFFFBBF24),
            title: 'Dark Mode',
            subtitle: isDark ? 'On — easier on eyes at night' : 'Off — bright and clear',
            trailing: Switch.adaptive(
              value: isDark,
              activeColor: cs.primary,
              onChanged: (v) => _settings.setThemeMode(
                v ? ThemeMode.dark : ThemeMode.light,
              ),
            ),
          ),

          // Font size
          _SettingsTile(
            icon: Icons.format_size_rounded,
            iconColor: const Color(0xFF10B981),
            title: 'Text Size',
            subtitle: _settings.fontScaleLabel,
            onTap: () => _showFontSizeSheet(context),
          ),

          // ── Privacy & Security ─────────────────────────────────────────
          _Section(title: 'Privacy & Security', icon: Icons.security_rounded),

          _SettingsTile(
            icon: Icons.pin_rounded,
            iconColor: const Color(0xFF8B5CF6),
            title: 'PIN Lock',
            subtitle: _settings.pinEnabled
                ? 'Enabled — app is protected'
                : 'Disabled — tap to set up',
            trailing: Switch.adaptive(
              value: _settings.pinEnabled,
              activeColor: cs.primary,
              onChanged: (v) => v ? _setupPin(context) : _disablePin(context),
            ),
          ),

          if (_settings.pinEnabled)
            _SettingsTile(
              icon: Icons.edit_rounded,
              iconColor: const Color(0xFF64748B),
              title: 'Change PIN',
              subtitle: 'Update your access PIN',
              onTap: () => _setupPin(context, isChange: true),
            ),

          // ── Notifications ──────────────────────────────────────────────
          _Section(title: 'Notifications', icon: Icons.notifications_outlined),

          _SettingsTile(
            icon: Icons.alarm_rounded,
            iconColor: const Color(0xFF2563EB),
            title: 'Medication Alarms',
            subtitle: 'Manage scheduled reminders',
            onTap: () => Navigator.pushNamed(context, '/alarm-settings'),
          ),

          _SettingsTile(
            icon: Icons.summarize_rounded,
            iconColor: const Color(0xFF06B6D4),
            title: 'Weekly Health Digest',
            subtitle: 'Every Monday at 8:00 AM',
            trailing: const Icon(Icons.check_circle_rounded, color: Color(0xFF10B981), size: 20),
          ),

          // ── Data & Export ─────────────────────────────────────────────
          _Section(title: 'Data & Export', icon: Icons.folder_open_outlined),

          _SettingsTile(
            icon: Icons.picture_as_pdf_rounded,
            iconColor: const Color(0xFFEF4444),
            title: 'Share with Doctor',
            subtitle: 'Export health summary as PDF',
            onTap: () => Navigator.pushNamed(context, '/doctor-share'),
          ),

          // ── About ─────────────────────────────────────────────────────
          _Section(title: 'About', icon: Icons.info_outline_rounded),

          _SettingsTile(
            icon: Icons.verified_rounded,
            iconColor: const Color(0xFF10B981),
            title: 'Version',
            subtitle: '1.0.0 — CareSync',
          ),

          _SettingsTile(
            icon: Icons.replay_rounded,
            iconColor: const Color(0xFF64748B),
            title: 'View Onboarding',
            subtitle: 'See the tutorial again',
            onTap: () => Navigator.pushNamed(context, '/onboarding'),
          ),

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  void _showFontSizeSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (_) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              'Text Size',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(height: 8),
          ..._fontScales.map(
            (entry) => RadioListTile<double>(
              value: entry.$1,
              groupValue: _settings.fontScale,
              title: Text(
                entry.$2,
                style: TextStyle(
                  fontSize: 14 * entry.$1,
                  fontWeight: _settings.fontScale == entry.$1
                      ? FontWeight.w700
                      : FontWeight.w400,
                ),
              ),
              onChanged: (v) {
                if (v != null) _settings.setFontScale(v);
                Navigator.pop(context);
              },
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Future<void> _setupPin(BuildContext context, {bool isChange = false}) async {
    if (isChange) {
      // Verify old PIN first
      final verified = await Navigator.push<bool>(
        context,
        MaterialPageRoute(builder: (_) => const PinLockScreen(verifyOnly: true)),
      );
      if (verified != true) return;
    }
    if (!mounted) return;
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const _PinSetupScreen()),
    );
  }

  Future<void> _disablePin(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Disable PIN Lock'),
        content: const Text('Are you sure you want to remove PIN protection from this app?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Disable', style: TextStyle(color: Color(0xFFEF4444))),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await _settings.disablePin();
    }
  }
}

// ── Section header ────────────────────────────────────────────────────────────
class _Section extends StatelessWidget {
  final String title;
  final IconData icon;
  const _Section({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 28, 20, 8),
      child: Row(
        children: [
          Icon(icon, size: 15, color: cs.primary),
          const SizedBox(width: 6),
          Text(
            title.toUpperCase(),
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: cs.primary,
              letterSpacing: 1.1,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Single settings tile ──────────────────────────────────────────────────────
class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _SettingsTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      leading: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: iconColor.withOpacity(0.12),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: iconColor, size: 20),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: isDark ? Colors.white : const Color(0xFF1E293B),
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 13,
          color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
        ),
      ),
      trailing: trailing ?? (onTap != null
          ? const Icon(Icons.chevron_right_rounded, color: Color(0xFF94A3B8))
          : null),
      onTap: onTap,
    );
  }
}

// ── PIN setup screen (new PIN entry) ─────────────────────────────────────────
class _PinSetupScreen extends StatefulWidget {
  const _PinSetupScreen();

  @override
  State<_PinSetupScreen> createState() => _PinSetupScreenState();
}

class _PinSetupScreenState extends State<_PinSetupScreen> {
  final _settings = AppSettings();
  String _pin = '';
  String _confirm = '';
  bool _confirming = false;
  String? _error;

  void _onDigit(String d) {
    setState(() {
      _error = null;
      if (!_confirming) {
        if (_pin.length < 4) {
          _pin += d;
          if (_pin.length == 4) _confirming = true;
        }
      } else {
        if (_confirm.length < 4) {
          _confirm += d;
          if (_confirm.length == 4) _finalize();
        }
      }
    });
  }

  void _onBackspace() {
    setState(() {
      _error = null;
      if (_confirming) {
        if (_confirm.isNotEmpty) _confirm = _confirm.substring(0, _confirm.length - 1);
      } else {
        if (_pin.isNotEmpty) _pin = _pin.substring(0, _pin.length - 1);
      }
    });
  }

  Future<void> _finalize() async {
    if (_pin == _confirm) {
      await _settings.setupPin(_pin);
      if (mounted) Navigator.pop(context);
    } else {
      setState(() {
        _error = 'PINs do not match. Try again.';
        _confirm = '';
        _confirming = false;
        _pin = '';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final current = _confirming ? _confirm : _pin;
    return _PinScaffold(
      title: _confirming ? 'Confirm PIN' : 'Set New PIN',
      subtitle: _confirming ? 'Enter your PIN again to confirm' : 'Choose a 4-digit PIN',
      current: current,
      error: _error,
      onDigit: _onDigit,
      onBackspace: _onBackspace,
    );
  }
}

// ── Reusable PIN scaffold (used by setup and lock screens) ───────────────────
class PinScaffold extends StatelessWidget {
  final String title;
  final String subtitle;
  final String current;
  final String? error;
  final void Function(String) onDigit;
  final VoidCallback onBackspace;
  final Widget? topAction;

  const PinScaffold({
    super.key,
    required this.title,
    required this.subtitle,
    required this.current,
    required this.onDigit,
    required this.onBackspace,
    this.error,
    this.topAction,
  });

  @override
  Widget build(BuildContext context) {
    return _PinScaffold(
      title: title,
      subtitle: subtitle,
      current: current,
      error: error,
      onDigit: onDigit,
      onBackspace: onBackspace,
      topAction: topAction,
    );
  }
}

class _PinScaffold extends StatelessWidget {
  final String title;
  final String subtitle;
  final String current;
  final String? error;
  final void Function(String) onDigit;
  final VoidCallback onBackspace;
  final Widget? topAction;

  const _PinScaffold({
    required this.title,
    required this.subtitle,
    required this.current,
    required this.onDigit,
    required this.onBackspace,
    this.error,
    this.topAction,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            if (topAction != null)
              Align(alignment: Alignment.topRight, child: Padding(padding: const EdgeInsets.all(12), child: topAction!)),
            const Spacer(),
            // Lock icon
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF2563EB).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.lock_rounded, color: Color(0xFF2563EB), size: 36),
            ),
            const SizedBox(height: 20),
            Text(title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
            const SizedBox(height: 6),
            Text(subtitle, style: const TextStyle(fontSize: 14, color: Color(0xFF64748B))),
            const SizedBox(height: 32),
            // PIN dots
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
                    color: i < current.length
                        ? const Color(0xFF2563EB)
                        : Colors.grey.shade300,
                  ),
                ),
              ),
            ),
            if (error != null) ...[
              const SizedBox(height: 14),
              Text(error!, style: const TextStyle(color: Color(0xFFEF4444), fontSize: 13)),
            ],
            const Spacer(),
            // Numpad
            _Numpad(onDigit: onDigit, onBackspace: onBackspace),
            const SizedBox(height: 32),
          ],
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
                              ? const Icon(Icons.backspace_outlined, size: 22, color: Color(0xFF475569))
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
