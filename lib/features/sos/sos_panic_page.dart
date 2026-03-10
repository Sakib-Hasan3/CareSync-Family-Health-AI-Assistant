import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';

import '../family_profiles/family_repository.dart';
import 'sos_service.dart';

class SosPanicPage extends StatefulWidget {
  const SosPanicPage({super.key});

  @override
  State<SosPanicPage> createState() => _SosPanicPageState();
}

class _SosPanicPageState extends State<SosPanicPage>
    with TickerProviderStateMixin {
  final _sosService = SosService();
  final _familyRepo = FamilyRepository();

  Position? _location;
  bool _locating = false;
  bool _sosActive = false;
  int _countdown = 5;
  Timer? _countdownTimer;
  List<_Contact> _contacts = [];
  bool _loadingContacts = true;

  // Pulse animation for the SOS button
  late AnimationController _pulse;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _fetchLocation();
    _loadContacts();
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _pulse.dispose();
    super.dispose();
  }

  Future<void> _fetchLocation() async {
    setState(() => _locating = true);
    final pos = await _sosService.getCurrentLocation();
    if (mounted) setState(() { _location = pos; _locating = false; });
  }

  Future<void> _loadContacts() async {
    try {
      await _familyRepo.init();
      final members = _familyRepo.getAll();
      final contacts = <_Contact>[];
      for (final m in members) {
        m.emergencyContacts.forEach((name, phone) {
          if (phone.isNotEmpty) {
            contacts.add(_Contact(name: name, phone: phone, member: m.name));
          }
        });
      }
      if (mounted) {
        setState(() {
          _contacts = contacts;
          _loadingContacts = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loadingContacts = false);
    }
  }

  // -------------------------------------------------------------------------
  // SOS countdown + dispatch
  // -------------------------------------------------------------------------
  void _startSos() {
    if (_sosActive) return;
    setState(() {
      _sosActive = true;
      _countdown = 5;
    });

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) { t.cancel(); return; }
      setState(() => _countdown--);
      if (_countdown <= 0) {
        t.cancel();
        _dispatchSos();
      }
    });
  }

  void _cancelSos() {
    _countdownTimer?.cancel();
    if (mounted) setState(() { _sosActive = false; _countdown = 5; });
  }

  Future<void> _dispatchSos() async {
    if (mounted) setState(() => _sosActive = false);
    final body = _sosService.buildSmsBody(location: _location);
    if (_contacts.isEmpty) {
      // No saved contacts — just show a call dialog
      _showNoContactsDialog();
      return;
    }
    // Send to all contacts sequentially via SMS intent
    for (final c in _contacts) {
      final uri = Uri(
        scheme: 'sms',
        path: c.phone,
        queryParameters: {'body': body},
      );
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
        await Future.delayed(const Duration(milliseconds: 500));
      }
    }
  }

  void _showNoContactsDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('No Emergency Contacts'),
        content: const Text(
          'Add emergency contacts under Family Profiles to use the SOS feature.\n\nCall 999 for immediate help.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.pop(context);
              _callNumber('999');
            },
            child: const Text('Call 999', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _sendSmsTo(_Contact contact) async {
    final body = _sosService.buildSmsBody(location: _location);
    final uri = Uri(
      scheme: 'sms',
      path: contact.phone,
      queryParameters: {'body': body},
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _callNumber(String phone) async {
    final uri = Uri(scheme: 'tel', path: phone);
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  Future<void> _openLocation() async {
    if (_location == null) return;
    final uri = Uri.parse(_sosService.mapsUrl(_location!));
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  // -------------------------------------------------------------------------
  // Build
  // -------------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F172A),
        foregroundColor: Colors.white,
        title: const Text(
          'SOS Emergency',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Colors.white70),
            onPressed: _fetchLocation,
            tooltip: 'Refresh location',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Location status
            _LocationStatusCard(
              locating: _locating,
              location: _location,
              onRefresh: _fetchLocation,
              onOpenMap: _openLocation,
            ),
            const SizedBox(height: 28),

            // Big SOS button
            _SosButton(
              active: _sosActive,
              countdown: _countdown,
              pulse: _pulse,
              onPress: _startSos,
              onCancel: _cancelSos,
            ),
            const SizedBox(height: 10),
            if (!_sosActive)
              const Text(
                'Hold button to trigger SOS alert\nto all emergency contacts',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white54, fontSize: 12, height: 1.6),
              ),
            const SizedBox(height: 32),

            // Quick call row
            _QuickCallRow(onCall: _callNumber),
            const SizedBox(height: 28),

            // Emergency contacts
            _ContactsList(
              contacts: _contacts,
              loading: _loadingContacts,
              onCall: (c) => _callNumber(c.phone),
              onSms: _sendSmsTo,
            ),
            const SizedBox(height: 20),

            // Disclaimer
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.yellow.shade900.withOpacity(0.25),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.yellow.shade800.withOpacity(0.4)),
              ),
              child: const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info_outline_rounded, color: Colors.yellow, size: 16),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'For life-threatening emergencies always call 999 directly. SMS delivery is not guaranteed.',
                      style: TextStyle(
                        color: Colors.yellow,
                        fontSize: 11,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// Sub-widgets
// =============================================================================

class _LocationStatusCard extends StatelessWidget {
  final bool locating;
  final Position? location;
  final VoidCallback onRefresh;
  final VoidCallback onOpenMap;

  const _LocationStatusCard({
    required this.locating,
    required this.location,
    required this.onRefresh,
    required this.onOpenMap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: location != null
                  ? const Color(0xFF10B981).withOpacity(0.15)
                  : Colors.red.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              location != null
                  ? Icons.location_on_rounded
                  : Icons.location_off_rounded,
              color: location != null ? const Color(0xFF10B981) : Colors.red,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: locating
                ? Row(
                    children: const [
                      SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white54,
                        ),
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Getting location…',
                        style: TextStyle(color: Colors.white70, fontSize: 13),
                      ),
                    ],
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        location != null
                            ? 'Location ready'
                            : 'Location unavailable',
                        style: TextStyle(
                          color: location != null
                              ? const Color(0xFF10B981)
                              : Colors.red,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (location != null)
                        Text(
                          '${location!.latitude.toStringAsFixed(5)}, ${location!.longitude.toStringAsFixed(5)}',
                          style: const TextStyle(
                            color: Colors.white38,
                            fontSize: 11,
                          ),
                        )
                      else
                        const Text(
                          'SOS will be sent without location',
                          style: TextStyle(color: Colors.white38, fontSize: 11),
                        ),
                    ],
                  ),
          ),
          if (location != null)
            IconButton(
              onPressed: onOpenMap,
              icon: const Icon(
                Icons.open_in_new_rounded,
                color: Colors.white38,
                size: 18,
              ),
              tooltip: 'Open in Maps',
            ),
          if (!locating)
            IconButton(
              onPressed: onRefresh,
              icon: const Icon(Icons.refresh, color: Colors.white38, size: 18),
              tooltip: 'Refresh',
            ),
        ],
      ),
    );
  }
}

class _SosButton extends StatelessWidget {
  final bool active;
  final int countdown;
  final AnimationController pulse;
  final VoidCallback onPress;
  final VoidCallback onCancel;

  const _SosButton({
    required this.active,
    required this.countdown,
    required this.pulse,
    required this.onPress,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: pulse,
      builder: (_, child) {
        final scale = active ? (1.0 + pulse.value * 0.06) : 1.0;
        return Transform.scale(scale: scale, child: child);
      },
      child: GestureDetector(
        onTap: active ? null : onPress,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Outer ring
            AnimatedBuilder(
              animation: pulse,
              builder: (_, __) => AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: active ? (180 + pulse.value * 16) : 160,
                height: active ? (180 + pulse.value * 16) : 160,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.red.withOpacity(active ? 0.15 + pulse.value * 0.1 : 0),
                ),
              ),
            ),
            // Button
            Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    active ? const Color(0xFFFF1744) : const Color(0xFFEF4444),
                    active ? const Color(0xFFB71C1C) : const Color(0xFFC62828),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    blurRadius: active ? 40 : 20,
                    color: Colors.red.withOpacity(active ? 0.7 : 0.4),
                    spreadRadius: active ? 4 : 0,
                  ),
                ],
              ),
              child: active
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '$countdown',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 52,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        GestureDetector(
                          onTap: onCancel,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white24,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text(
                              'CANCEL',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1.5,
                              ),
                            ),
                          ),
                        ),
                      ],
                    )
                  : const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.sos_rounded, color: Colors.white, size: 52),
                        SizedBox(height: 4),
                        Text(
                          'SOS',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 4,
                          ),
                        ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickCallRow extends StatelessWidget {
  final Future<void> Function(String) onCall;
  const _QuickCallRow({required this.onCall});

  @override
  Widget build(BuildContext context) {
    final numbers = [
      ('999', 'Emergency', Icons.local_police_rounded),
      ('102', 'Ambulance', Icons.emergency_rounded),
      ('199', 'Fire', Icons.local_fire_department_rounded),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'QUICK CALL',
          style: TextStyle(
            color: Colors.white38,
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: numbers
              .map(
                (n) => Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: GestureDetector(
                      onTap: () => onCall(n.$1),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.07),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.12),
                          ),
                        ),
                        child: Column(
                          children: [
                            Icon(n.$3, color: Colors.red.shade300, size: 22),
                            const SizedBox(height: 4),
                            Text(
                              n.$1,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                                fontSize: 15,
                              ),
                            ),
                            Text(
                              n.$2,
                              style: const TextStyle(
                                color: Colors.white38,
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}

class _ContactsList extends StatelessWidget {
  final List<_Contact> contacts;
  final bool loading;
  final Future<void> Function(_Contact) onCall;
  final Future<void> Function(_Contact) onSms;

  const _ContactsList({
    required this.contacts,
    required this.loading,
    required this.onCall,
    required this.onSms,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'EMERGENCY CONTACTS',
          style: TextStyle(
            color: Colors.white38,
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 10),
        if (loading)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: CircularProgressIndicator(color: Colors.white24),
            ),
          )
        else if (contacts.isEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withOpacity(0.08)),
            ),
            child: const Row(
              children: [
                Icon(Icons.person_off_rounded, color: Colors.white38, size: 20),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'No emergency contacts found.\nAdd them under Family Profiles.',
                    style: TextStyle(color: Colors.white38, fontSize: 13, height: 1.5),
                  ),
                ),
              ],
            ),
          )
        else
          ...contacts.map(
            (c) => Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.06),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withOpacity(0.1)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.person_rounded,
                      color: Colors.blueAccent,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          c.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          '${c.member} • ${c.phone}',
                          style: const TextStyle(
                            color: Colors.white38,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // SMS button
                  IconButton(
                    onPressed: () => onSms(c),
                    icon: const Icon(Icons.sms_rounded, color: Colors.greenAccent, size: 22),
                    tooltip: 'Send SOS SMS',
                  ),
                  // Call button
                  IconButton(
                    onPressed: () => onCall(c),
                    icon: const Icon(Icons.phone_rounded, color: Colors.lightBlueAccent, size: 22),
                    tooltip: 'Call',
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Internal data class
// ---------------------------------------------------------------------------
class _Contact {
  final String name;
  final String phone;
  final String member;
  const _Contact({
    required this.name,
    required this.phone,
    required this.member,
  });
}
