import 'package:flutter/material.dart';
import '../../core/constants/app_strings.dart';
import '../../core/utils/app_utils.dart';
import '../../widgets/custom_button.dart';

/// Settings screen for app configuration
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _medicationReminders = true;
  bool _appointmentReminders = true;
  bool _biometricLogin = false;
  bool _autoSync = true;
  bool _darkMode = false;
  String _language = 'English';
  String _timeFormat = '12-hour';
  String _dateFormat = 'MM/DD/YYYY';

  final List<String> _languages = ['English', 'Spanish', 'French', 'German'];
  final List<String> _timeFormats = ['12-hour', '24-hour'];
  final List<String> _dateFormats = ['MM/DD/YYYY', 'DD/MM/YYYY', 'YYYY-MM-DD'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.settings)),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildSection('Notifications', Icons.notifications, [
            _buildSwitchTile(
              'Enable Notifications',
              'Receive app notifications',
              _notificationsEnabled,
              (value) => setState(() => _notificationsEnabled = value),
            ),
            _buildSwitchTile(
              'Medication Reminders',
              'Get reminded to take medications',
              _medicationReminders,
              (value) => setState(() => _medicationReminders = value),
              enabled: _notificationsEnabled,
            ),
            _buildSwitchTile(
              'Appointment Reminders',
              'Get reminded of upcoming appointments',
              _appointmentReminders,
              (value) => setState(() => _appointmentReminders = value),
              enabled: _notificationsEnabled,
            ),
          ]),
          _buildSection('Security & Privacy', Icons.security, [
            _buildSwitchTile(
              'Biometric Login',
              'Use fingerprint or face recognition',
              _biometricLogin,
              (value) => setState(() => _biometricLogin = value),
            ),
            _buildNavigationTile(
              'Change Password',
              'Update your account password',
              Icons.lock,
              () => _navigateToChangePassword(),
            ),
            _buildNavigationTile(
              'Privacy Settings',
              'Manage data sharing preferences',
              Icons.privacy_tip,
              () => _navigateToPrivacySettings(),
            ),
          ]),
          _buildSection('Data & Sync', Icons.sync, [
            _buildSwitchTile(
              'Auto Sync',
              'Automatically sync data across devices',
              _autoSync,
              (value) => setState(() => _autoSync = value),
            ),
            _buildNavigationTile(
              'Backup & Restore',
              'Manage your data backups',
              Icons.backup,
              () => _navigateToBackup(),
            ),
            _buildNavigationTile(
              'Export Data',
              'Download your health data',
              Icons.download,
              () => _exportData(),
            ),
          ]),
          _buildSection('Appearance', Icons.palette, [
            _buildSwitchTile(
              'Dark Mode',
              'Use dark theme',
              _darkMode,
              (value) => setState(() => _darkMode = value),
            ),
            _buildDropdownTile(
              'Language',
              _language,
              _languages,
              (value) => setState(() => _language = value!),
            ),
            _buildDropdownTile(
              'Time Format',
              _timeFormat,
              _timeFormats,
              (value) => setState(() => _timeFormat = value!),
            ),
            _buildDropdownTile(
              'Date Format',
              _dateFormat,
              _dateFormats,
              (value) => setState(() => _dateFormat = value!),
            ),
          ]),
          _buildSection('Emergency', Icons.emergency, [
            _buildNavigationTile(
              'Emergency Contacts',
              'Manage emergency contact information',
              Icons.contact_emergency,
              () => Navigator.of(context).pushNamed('/emergency-card'),
            ),
            _buildNavigationTile(
              'Medical Information',
              'Update emergency medical details',
              Icons.medical_information,
              () => _navigateToMedicalInfo(),
            ),
          ]),
          _buildSection('About', Icons.info, [
            _buildNavigationTile(
              'Help & Support',
              'Get help and contact support',
              Icons.help,
              () => _navigateToHelp(),
            ),
            _buildNavigationTile(
              'Terms of Service',
              'Read our terms and conditions',
              Icons.description,
              () => _showTermsOfService(),
            ),
            _buildNavigationTile(
              'Privacy Policy',
              'Read our privacy policy',
              Icons.policy,
              () => _showPrivacyPolicy(),
            ),
            _buildNavigationTile(
              'About CareSync',
              'App version and information',
              Icons.info_outline,
              () => _showAboutDialog(),
            ),
          ]),
          const SizedBox(height: 32),
          CustomButton(
            text: 'Sign Out',
            onPressed: _showSignOutDialog,
            backgroundColor: Colors.red,
            icon: Icons.logout,
          ),
          const SizedBox(height: 16),
          CustomButton(
            text: 'Delete Account',
            onPressed: _showDeleteAccountDialog,
            backgroundColor: Colors.grey[300],
            textColor: Colors.red,
            icon: Icons.delete_forever,
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, IconData icon, List<Widget> children) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Colors.blue),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildSwitchTile(
    String title,
    String subtitle,
    bool value,
    ValueChanged<bool> onChanged, {
    bool enabled = true,
  }) {
    return SwitchListTile(
      title: Text(title, style: TextStyle(color: enabled ? null : Colors.grey)),
      subtitle: Text(
        subtitle,
        style: TextStyle(color: enabled ? Colors.grey[600] : Colors.grey[400]),
      ),
      value: value,
      onChanged: enabled ? onChanged : null,
      contentPadding: EdgeInsets.zero,
    );
  }

  Widget _buildNavigationTile(
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap,
  ) {
    return ListTile(
      leading: Icon(icon, color: Colors.grey[600]),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
    );
  }

  Widget _buildDropdownTile(
    String title,
    String value,
    List<String> items,
    ValueChanged<String?> onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Expanded(child: Text(title, style: const TextStyle(fontSize: 16))),
          DropdownButton<String>(
            value: value,
            items: items
                .map((item) => DropdownMenuItem(value: item, child: Text(item)))
                .toList(),
            onChanged: onChanged,
            underline: Container(),
          ),
        ],
      ),
    );
  }

  void _navigateToChangePassword() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Change Password'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: InputDecoration(
                labelText: 'Current Password',
                prefixIcon: Icon(Icons.lock),
              ),
              obscureText: true,
            ),
            SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(
                labelText: 'New Password',
                prefixIcon: Icon(Icons.lock_outline),
              ),
              obscureText: true,
            ),
            SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(
                labelText: 'Confirm New Password',
                prefixIcon: Icon(Icons.lock_outline),
              ),
              obscureText: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              AppUtils.showSuccessSnackBar(
                context,
                'Password updated successfully',
              );
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  void _navigateToPrivacySettings() {
    AppUtils.showSuccessSnackBar(context, 'Opening privacy settings...');
  }

  void _navigateToBackup() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Backup & Restore'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Last backup: 2 hours ago'),
            SizedBox(height: 16),
            Text('Backup includes:'),
            Text('• Medical records'),
            Text('• Medication data'),
            Text('• Appointment history'),
            Text('• Family member information'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              AppUtils.showSuccessSnackBar(context, 'Backup started...');
            },
            child: const Text('Backup Now'),
          ),
        ],
      ),
    );
  }

  void _exportData() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Export Data'),
        content: const Text(
          'This will create a downloadable file containing all your health data. '
          'This may take a few minutes to process.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              AppUtils.showSuccessSnackBar(context, 'Data export started...');
            },
            child: const Text('Export'),
          ),
        ],
      ),
    );
  }

  void _navigateToMedicalInfo() {
    AppUtils.showSuccessSnackBar(context, 'Opening medical information...');
  }

  void _navigateToHelp() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Help & Support'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Need help? Contact us:'),
            SizedBox(height: 16),
            Text('Email: support@caresync.com'),
            Text('Phone: 1-800-CARESYNC'),
            Text('Website: www.caresync.com/help'),
            SizedBox(height: 16),
            Text('We\'re here to help 24/7!'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              AppUtils.showSuccessSnackBar(context, 'Opening support chat...');
            },
            child: const Text('Contact Support'),
          ),
        ],
      ),
    );
  }

  void _showTermsOfService() {
    AppUtils.showSuccessSnackBar(context, 'Opening Terms of Service...');
  }

  void _showPrivacyPolicy() {
    AppUtils.showSuccessSnackBar(context, 'Opening Privacy Policy...');
  }

  void _showAboutDialog() {
    showAboutDialog(
      context: context,
      applicationName: 'CareSync',
      applicationVersion: '1.0.0',
      applicationIcon: const Icon(Icons.health_and_safety, size: 48),
      children: [
        const Text(
          'CareSync is a comprehensive family health management app '
          'designed to help you track medications, appointments, '
          'and health records for your entire family.',
        ),
      ],
    );
  }

  void _showSignOutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pushReplacementNamed('/login');
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Account'),
        content: const Text(
          'This will permanently delete your account and all associated data. '
          'This action cannot be undone. Are you sure?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _showFinalDeleteConfirmation();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showFinalDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Final Confirmation'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Type "DELETE" to confirm account deletion:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(
                hintText: 'Type DELETE here',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              AppUtils.showSuccessSnackBar(
                context,
                'Account deletion request submitted',
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Confirm Delete'),
          ),
        ],
      ),
    );
  }
}
