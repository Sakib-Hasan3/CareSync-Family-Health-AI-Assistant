import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/donor.dart';
import '../donor_repository.dart';

class DonorDetailPage extends StatefulWidget {
  final Donor donor;
  const DonorDetailPage({super.key, required this.donor});

  @override
  State<DonorDetailPage> createState() => _DonorDetailPageState();
}

class _DonorDetailPageState extends State<DonorDetailPage> {
  final DonorRepository _repo = DonorRepository();
  late Donor _donor;

  @override
  void initState() {
    super.initState();
    _donor = widget.donor;
  }

  Future<void> _toggleAvailability() async {
    setState(() {
      _donor = Donor(
        id: _donor.id,
        name: _donor.name,
        bloodGroup: _donor.bloodGroup,
        phone: _donor.phone,
        city: _donor.city,
        available: !_donor.available,
        lastDonated: _donor.lastDonated,
        notes: _donor.notes,
      );
    });
    
    await _repo.init();
    await _repo.addOrUpdate(_donor);
    
    if (!mounted) return;
    
    // Show confirmation
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_donor.available ? 
          'Marked as available for donation' : 
          'Marked as unavailable'
        ),
        backgroundColor: _donor.available ? Colors.green : Colors.orange,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  Future<void> _contactDonor() async {
    final Uri telLaunchUri = Uri(
      scheme: 'tel',
      path: _donor.phone,
    );
    
    if (await canLaunchUrl(telLaunchUri)) {
      await launchUrl(telLaunchUri);
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not launch phone app'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _sendSMS() async {
    final Uri smsLaunchUri = Uri(
      scheme: 'sms',
      path: _donor.phone,
      queryParameters: {'body': 'Hello ${_donor.name}, I need blood donation assistance. Are you available?'},
    );
    
    if (await canLaunchUrl(smsLaunchUri)) {
      await launchUrl(smsLaunchUri);
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not launch messaging app'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _removeDonor() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Remove Donor'),
        content: const Text('Are you sure you want to remove this donor from the registry?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(c, true),
            child: const Text(
              'Remove',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
    
    if (ok != true) return;
    
    await _repo.init();
    await _repo.remove(_donor.id);
    
    if (!mounted) return;
    
    Navigator.pop(context);
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Donor removed successfully'),
        backgroundColor: Colors.green,
      ),
    );
  }

  Widget _buildInfoCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
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

  Widget _buildStatusBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: _donor.available ? Colors.green.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _donor.available ? Colors.green : Colors.orange,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _donor.available ? Icons.check_circle : Icons.remove_circle,
            size: 16,
            color: _donor.available ? Colors.green : Colors.orange,
          ),
          const SizedBox(width: 6),
          Text(
            _donor.available ? 'Available for Donation' : 'Currently Unavailable',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: _donor.available ? Colors.green : Colors.orange,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text(
          'Donor Profile',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFFDC143C),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: _shareDonorInfo,
            tooltip: 'Share Donor Info',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Header Card
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: _getBloodGroupColor(_donor.bloodGroup),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: _getBloodGroupColor(_donor.bloodGroup).withOpacity(0.3),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              _donor.bloodGroup,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 24,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _donor.name,
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Icon(
                                    Icons.location_on_rounded,
                                    size: 16,
                                    color: Colors.grey[600],
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    _donor.city,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              _buildStatusBadge(),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    
                    // Contact Buttons
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _contactDonor,
                            icon: const Icon(Icons.phone, size: 18),
                            label: const Text('Call'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _sendSMS,
                            icon: const Icon(Icons.message, size: 18),
                            label: const Text('Message'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFF2196F3),
                              side: const BorderSide(color: Color(0xFF2196F3)),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 20),

            // Information Section
            const Text(
              'Donor Information',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),

            // Info Cards Grid
            GridView(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.8,
              ),
              children: [
                _buildInfoCard(
                  'Blood Group',
                  _donor.bloodGroup,
                  Icons.bloodtype_rounded,
                  const Color(0xFFDC143C),
                ),
                _buildInfoCard(
                  'Phone',
                  _donor.phone,
                  Icons.phone_rounded,
                  const Color(0xFF2196F3),
                ),
                _buildInfoCard(
                  'City',
                  _donor.city,
                  Icons.location_city_rounded,
                  const Color(0xFF4CAF50),
                ),
                _buildInfoCard(
                  'Last Donation',
                  _donor.lastDonated != null 
                      ? DateFormat('MMM dd, yyyy').format(_donor.lastDonated!)
                      : 'Never',
                  Icons.calendar_today_rounded,
                  const Color(0xFFFF9800),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Donation Eligibility
            _buildEligibilityCard(),

            const SizedBox(height: 20),

            // Management Actions
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Manage Donor',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _toggleAvailability,
                            icon: Icon(
                              _donor.available ? Icons.person_off_rounded : Icons.person_rounded,
                              size: 18,
                            ),
                            label: Text(_donor.available ? 'Mark Unavailable' : 'Mark Available'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: _donor.available ? Colors.orange : Colors.green,
                              side: BorderSide(
                                color: _donor.available ? Colors.orange : Colors.green,
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _removeDonor,
                            icon: const Icon(Icons.delete_rounded, size: 18),
                            label: const Text('Remove'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.red,
                              side: const BorderSide(color: Colors.red),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildEligibilityCard() {
    final bool isEligible = _donor.lastDonated == null || 
        DateTime.now().difference(_donor.lastDonated!).inDays >= 90;
    
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isEligible ? Colors.green.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isEligible ? Icons.check_circle_rounded : Icons.info_rounded,
                color: isEligible ? Colors.green : Colors.orange,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isEligible ? 'Eligible for Donation' : 'Check Eligibility',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: isEligible ? Colors.green : Colors.orange,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _donor.lastDonated != null
                        ? 'Last donated ${DateFormat('MMM dd, yyyy').format(_donor.lastDonated!)}'
                        : 'First-time donor',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
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

  Future<void> _shareDonorInfo() async {
    // For now, show a dialog with shareable info
    // In a real app, you'd use the share_plus package
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Share Donor Information'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Name: ${_donor.name}'),
            Text('Blood Group: ${_donor.bloodGroup}'),
            Text('Phone: ${_donor.phone}'),
            Text('City: ${_donor.city}'),
            Text('Status: ${_donor.available ? 'Available' : 'Unavailable'}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Color _getBloodGroupColor(String bloodGroup) {
    final colors = {
      'A+': const Color(0xFFDC143C),
      'A-': const Color(0xFFC2185B),
      'B+': const Color(0xFF2196F3),
      'B-': const Color(0xFF1976D2),
      'AB+': const Color(0xFF4CAF50),
      'AB-': const Color(0xFF388E3C),
      'O+': const Color(0xFFFF9800),
      'O-': const Color(0xFFF57C00),
    };
    return colors[bloodGroup] ?? const Color(0xFFDC143C);
  }
}