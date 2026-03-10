import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../payments/payment_accounts.dart';

class PaymentAccountPage extends StatelessWidget {
  final String method; // 'bKash' or 'Nagad'
  final String accountNumber;
  final String receiverName;
  final String? reference; // booking id or tx to show/copy

  const PaymentAccountPage({
    super.key,
    required this.method,
    required this.accountNumber,
    required this.receiverName,
    this.reference,
  });

  /// Construct from method using configured accounts
  factory PaymentAccountPage.forMethod(String method, {String? reference}) {
    final account = PaymentAccounts.accountNumberFor(method);
    final receiver = PaymentAccounts.receiverFor(method);
    return PaymentAccountPage(
      method: method,
      accountNumber: account,
      receiverName: receiver,
      reference: reference,
    );
  }

  Future<void> _openAppIfPossible(BuildContext context) async {
    final uriStr = PaymentAccounts.uriFor(method);
    if (uriStr.isEmpty) return;
    try {
      final uri = Uri.parse(uriStr);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        return;
      }
    } catch (_) {}
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Unable to open app — use manual method.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('$method Payment')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 2,
              child: ListTile(
                title: Text(
                  receiverName,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(method),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Account / Number',
              style: TextStyle(color: Colors.grey.shade700),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                SelectableText(
                  accountNumber,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: accountNumber));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Copied number to clipboard'),
                      ),
                    );
                  },
                  icon: const Icon(Icons.copy),
                  label: const Text('Copy'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text('Reference', style: TextStyle(color: Colors.grey.shade700)),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: SelectableText(
                    reference ?? 'Use booking ID shown after confirmation',
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: () {
                    final ref = reference ?? '';
                    if (ref.isNotEmpty) {
                      Clipboard.setData(ClipboardData(text: ref));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Copied reference to clipboard'),
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Reference not available yet'),
                        ),
                      );
                    }
                  },
                  icon: const Icon(Icons.copy),
                  label: const Text('Copy'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text('Instructions', style: TextStyle(color: Colors.grey.shade700)),
            const SizedBox(height: 8),
            Text(
              method == 'bKash'
                  ? 'Open the bKash app → Send Money → Enter number above → Add reference: booking id.'
                  : 'Open the Nagad app → Send Money → Enter number above → Add reference: booking id.',
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: () => _openAppIfPossible(context),
                  icon: const Icon(Icons.open_in_new),
                  label: const Text('Open App'),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: () async {
                    final uri = Uri.parse('tel:$accountNumber');
                    if (await canLaunchUrl(uri)) await launchUrl(uri);
                  },
                  icon: const Icon(Icons.call),
                  label: const Text('Call'),
                ),
                const SizedBox(width: 12),
                OutlinedButton.icon(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('Done'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
