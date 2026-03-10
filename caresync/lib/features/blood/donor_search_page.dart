import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../blood/donor_match_service.dart';
import '../blood/models/donor.dart';

class DonorSearchPage extends StatefulWidget {
  const DonorSearchPage({super.key});

  @override
  State<DonorSearchPage> createState() => _DonorSearchPageState();
}

class _DonorSearchPageState extends State<DonorSearchPage> {
  final _donorService = DonorMatchService();
  final _cityCtrl = TextEditingController();
  
  String? _selectedBloodGroup;
  List<Donor> _searchResults = [];
  bool _isSearching = false;
  bool _hasSearched = false;

  final List<String> _bloodGroups = [
    'A+',
    'A-',
    'B+',
    'B-',
    'AB+',
    'AB-',
    'O+',
    'O-',
  ];

  @override
  void dispose() {
    _cityCtrl.dispose();
    super.dispose();
  }

  Future<void> _searchDonors() async {
    if (_selectedBloodGroup == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a blood group'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isSearching = true;
      _hasSearched = false;
    });

    try {
      final results = await _donorService.findMatches(
        bloodGroup: _selectedBloodGroup!,
        city: _cityCtrl.text.trim().isEmpty ? null : _cityCtrl.text.trim(),
        limit: 50,
      );

      setState(() {
        _searchResults = results;
        _hasSearched = true;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSearching = false;
        });
      }
    }
  }

  Future<void> _makePhoneCall(String phone) async {
    final uri = Uri.parse('tel:$phone');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cannot make phone call')),
        );
      }
    }
  }

  void _copyToClipboard(String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$label copied to clipboard'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Blood Donors'),
        backgroundColor: const Color(0xFFEF4444),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Search Form
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Find Donors',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 16),
                
                // Blood Group Dropdown
                DropdownButtonFormField<String>(
                  value: _selectedBloodGroup,
                  decoration: InputDecoration(
                    labelText: 'Blood Group *',
                    prefixIcon: const Icon(Icons.bloodtype, color: Color(0xFFEF4444)),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                  ),
                  items: _bloodGroups.map((group) {
                    return DropdownMenuItem(
                      value: group,
                      child: Text(
                        group,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedBloodGroup = value;
                    });
                  },
                ),
                const SizedBox(height: 12),
                
                // City TextField
                TextField(
                  controller: _cityCtrl,
                  decoration: InputDecoration(
                    labelText: 'City (Optional)',
                    hintText: 'e.g., Dhaka, Chittagong',
                    prefixIcon: const Icon(Icons.location_city),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                  ),
                ),
                const SizedBox(height: 16),
                
                // Search Button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: _isSearching ? null : _searchDonors,
                    icon: _isSearching
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation(Colors.white),
                            ),
                          )
                        : const Icon(Icons.search),
                    label: Text(
                      _isSearching ? 'Searching...' : 'Search Donors',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFEF4444),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Search Results
          Expanded(
            child: _buildResultsSection(),
          ),
        ],
      ),
    );
  }

  Widget _buildResultsSection() {
    if (!_hasSearched && !_isSearching) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search,
              size: 80,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: 16),
            Text(
              'Select blood group and search',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      );
    }

    if (_isSearching) {
      return const Center(
        child: CircularProgressIndicator(
          color: Color(0xFFEF4444),
        ),
      );
    }

    if (_searchResults.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.person_off,
              size: 80,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: 16),
            Text(
              'No donors found',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try a different blood group or city',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        // Results Header
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.grey.shade100,
          child: Row(
            children: [
              const Icon(Icons.people, color: Color(0xFFEF4444)),
              const SizedBox(width: 8),
              Text(
                'Found ${_searchResults.length} donor${_searchResults.length == 1 ? '' : 's'}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        
        // Donors List
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _searchResults.length,
            itemBuilder: (context, index) {
              final donor = _searchResults[index];
              return _buildDonorCard(donor);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDonorCard(Donor donor) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Name and Blood Group
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEF4444),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    donor.bloodGroup,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    donor.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                ),
                if (donor.available)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'Available',
                      style: TextStyle(
                        color: Colors.green,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Location
            _buildInfoRow(
              icon: Icons.location_on,
              label: 'Location',
              value: donor.city,
              onCopy: () => _copyToClipboard(donor.city, 'Location'),
            ),
            const SizedBox(height: 12),
            
            // Phone
            _buildInfoRow(
              icon: Icons.phone,
              label: 'Phone',
              value: donor.phone,
              onCopy: () => _copyToClipboard(donor.phone, 'Phone number'),
              onTap: () => _makePhoneCall(donor.phone),
            ),
            
            // Last Donated
            if (donor.lastDonated != null) ...[
              const SizedBox(height: 12),
              _buildInfoRow(
                icon: Icons.calendar_today,
                label: 'Last Donated',
                value: _formatDate(donor.lastDonated!),
              ),
            ],
            
            // Notes
            if (donor.notes != null && donor.notes!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.info_outline,
                      size: 16,
                      color: Colors.blue,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        donor.notes!,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.blue.shade900,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    VoidCallback? onCopy,
    VoidCallback? onTap,
  }) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey.shade600),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF1E293B),
                ),
              ),
            ],
          ),
        ),
        if (onTap != null)
          IconButton(
            onPressed: onTap,
            icon: const Icon(Icons.phone),
            color: Colors.green,
            tooltip: 'Call',
          ),
        if (onCopy != null)
          IconButton(
            onPressed: onCopy,
            icon: const Icon(Icons.copy, size: 18),
            color: Colors.grey.shade600,
            tooltip: 'Copy',
          ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    
    if (diff.inDays < 30) {
      return '${diff.inDays} days ago';
    } else if (diff.inDays < 365) {
      final months = (diff.inDays / 30).floor();
      return '$months month${months > 1 ? 's' : ''} ago';
    } else {
      final years = (diff.inDays / 365).floor();
      return '$years year${years > 1 ? 's' : ''} ago';
    }
  }
}
