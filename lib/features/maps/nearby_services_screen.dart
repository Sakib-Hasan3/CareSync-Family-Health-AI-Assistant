import 'package:flutter/material.dart';
import '../../core/constants/app_strings.dart';
import '../../core/utils/app_utils.dart';
import '../../widgets/custom_button.dart';

/// Nearby services screen showing hospitals, pharmacies, and clinics
class NearbyServicesScreen extends StatefulWidget {
  const NearbyServicesScreen({super.key});

  @override
  State<NearbyServicesScreen> createState() => _NearbyServicesScreenState();
}

class _NearbyServicesScreenState extends State<NearbyServicesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedFilter = 'All';
  bool _isMapView = false;

  // Mock data for nearby services
  final List<Map<String, dynamic>> _hospitals = [
    {
      'name': 'City General Hospital',
      'type': 'Hospital',
      'distance': '0.8 km',
      'rating': 4.5,
      'phone': '+1 (555) 123-4567',
      'address': '123 Medical Center Dr, City, State 12345',
      'specialties': ['Emergency', 'Cardiology', 'Neurology'],
      'isOpen': true,
      'waitTime': '15 min',
    },
    {
      'name': 'St. Mary\'s Medical Center',
      'type': 'Hospital',
      'distance': '1.2 km',
      'rating': 4.7,
      'phone': '+1 (555) 987-6543',
      'address': '456 Health Ave, City, State 12345',
      'specialties': ['Emergency', 'Pediatrics', 'Oncology'],
      'isOpen': true,
      'waitTime': '25 min',
    },
  ];

  final List<Map<String, dynamic>> _pharmacies = [
    {
      'name': 'MediCare Pharmacy',
      'type': 'Pharmacy',
      'distance': '0.3 km',
      'rating': 4.3,
      'phone': '+1 (555) 456-7890',
      'address': '789 Main St, City, State 12345',
      'services': ['Prescription', 'Vaccination', '24/7'],
      'isOpen': true,
      'hours': 'Open 24 hours',
    },
    {
      'name': 'Quick Health Pharmacy',
      'type': 'Pharmacy',
      'distance': '0.5 km',
      'rating': 4.1,
      'phone': '+1 (555) 321-0987',
      'address': '321 Health St, City, State 12345',
      'services': ['Prescription', 'Health Screening'],
      'isOpen': true,
      'hours': '8 AM - 10 PM',
    },
  ];

  final List<Map<String, dynamic>> _clinics = [
    {
      'name': 'Family Care Clinic',
      'type': 'Clinic',
      'distance': '0.6 km',
      'rating': 4.4,
      'phone': '+1 (555) 654-3210',
      'address': '654 Family Way, City, State 12345',
      'specialties': ['Family Medicine', 'Pediatrics'],
      'isOpen': true,
      'nextAvailable': 'Today 2:30 PM',
    },
    {
      'name': 'Urgent Care Plus',
      'type': 'Urgent Care',
      'distance': '0.9 km',
      'rating': 4.2,
      'phone': '+1 (555) 789-0123',
      'address': '987 Urgent Blvd, City, State 12345',
      'specialties': ['Urgent Care', 'X-Ray', 'Lab Services'],
      'isOpen': true,
      'nextAvailable': 'Walk-in available',
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.nearbyServices),
        actions: [
          IconButton(
            icon: Icon(_isMapView ? Icons.list : Icons.map),
            onPressed: () {
              setState(() {
                _isMapView = !_isMapView;
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.my_location),
            onPressed: _getCurrentLocation,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'All'),
            Tab(text: 'Hospitals'),
            Tab(text: 'Pharmacies'),
            Tab(text: 'Clinics'),
          ],
        ),
      ),
      body: _isMapView ? _buildMapView() : _buildListView(),
    );
  }

  Widget _buildListView() {
    return TabBarView(
      controller: _tabController,
      children: [
        _buildAllServicesTab(),
        _buildServicesList(_hospitals),
        _buildServicesList(_pharmacies),
        _buildServicesList(_clinics),
      ],
    );
  }

  Widget _buildMapView() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.map, size: 64, color: Colors.grey),
                    SizedBox(height: 16),
                    Text(
                      'Interactive Map View',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Map integration with Google Maps/Apple Maps',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: CustomButton(
                  text: 'Find Directions',
                  onPressed: () {
                    AppUtils.showSuccessSnackBar(
                      context,
                      'Opening navigation app...',
                    );
                  },
                  icon: Icons.directions,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: CustomButton(
                  text: 'Filter Services',
                  onPressed: _showFilterDialog,
                  icon: Icons.filter_list,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAllServicesTab() {
    final allServices = [..._hospitals, ..._pharmacies, ..._clinics];
    allServices.sort((a, b) => a['distance'].compareTo(b['distance']));
    return _buildServicesList(allServices);
  }

  Widget _buildServicesList(List<Map<String, dynamic>> services) {
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: services.length,
      itemBuilder: (context, index) {
        final service = services[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: InkWell(
            onTap: () => _showServiceDetails(service),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _getServiceIcon(service['type']),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              service['name'],
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              service['type'],
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            service['distance'],
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.star,
                                color: Colors.amber,
                                size: 16,
                              ),
                              Text(
                                service['rating'].toString(),
                                style: const TextStyle(fontSize: 12),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(
                        service['isOpen'] ? Icons.check_circle : Icons.cancel,
                        color: service['isOpen'] ? Colors.green : Colors.red,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        service['isOpen'] ? 'Open' : 'Closed',
                        style: TextStyle(
                          color: service['isOpen'] ? Colors.green : Colors.red,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const Spacer(),
                      if (service.containsKey('waitTime'))
                        Text(
                          'Wait: ${service['waitTime']}',
                          style: const TextStyle(fontSize: 12),
                        )
                      else if (service.containsKey('hours'))
                        Text(
                          service['hours'],
                          style: const TextStyle(fontSize: 12),
                        )
                      else if (service.containsKey('nextAvailable'))
                        Text(
                          service['nextAvailable'],
                          style: const TextStyle(fontSize: 12),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: CustomButton(
                          text: 'Call',
                          onPressed: () => _makeCall(service['phone']),
                          icon: Icons.phone,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: CustomButton(
                          text: 'Directions',
                          onPressed: () => _getDirections(service),
                          icon: Icons.directions,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _getServiceIcon(String type) {
    IconData icon;
    Color color;

    switch (type.toLowerCase()) {
      case 'hospital':
        icon = Icons.local_hospital;
        color = Colors.red;
        break;
      case 'pharmacy':
        icon = Icons.local_pharmacy;
        color = Colors.green;
        break;
      case 'clinic':
      case 'urgent care':
        icon = Icons.medical_services;
        color = Colors.blue;
        break;
      default:
        icon = Icons.location_on;
        color = Colors.grey;
    }

    return CircleAvatar(
      backgroundColor: color.withOpacity(0.1),
      child: Icon(icon, color: color),
    );
  }

  void _showServiceDetails(Map<String, dynamic> service) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        expand: false,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _getServiceIcon(service['type']),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            service['name'],
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            service['type'],
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildDetailRow(
                  Icons.location_on,
                  'Address',
                  service['address'],
                ),
                _buildDetailRow(Icons.phone, 'Phone', service['phone']),
                _buildDetailRow(
                  Icons.drive_eta,
                  'Distance',
                  service['distance'],
                ),
                if (service.containsKey('specialties'))
                  _buildSpecialtiesRow(service['specialties']),
                if (service.containsKey('services'))
                  _buildServicesRow(service['services']),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: CustomButton(
                        text: 'Call Now',
                        onPressed: () => _makeCall(service['phone']),
                        icon: Icons.phone,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: CustomButton(
                        text: 'Get Directions',
                        onPressed: () => _getDirections(service),
                        icon: Icons.directions,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey[600], size: 20),
          const SizedBox(width: 12),
          Text('$label: ', style: const TextStyle(fontWeight: FontWeight.w500)),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Widget _buildSpecialtiesRow(List<String> specialties) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.medical_services, color: Colors.grey[600], size: 20),
              const SizedBox(width: 12),
              const Text(
                'Specialties: ',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: specialties
                .map(
                  (specialty) => Chip(
                    label: Text(specialty),
                    backgroundColor: Colors.blue.withOpacity(0.1),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildServicesRow(List<String> services) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.room_service, color: Colors.grey[600], size: 20),
              const SizedBox(width: 12),
              const Text(
                'Services: ',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: services
                .map(
                  (service) => Chip(
                    label: Text(service),
                    backgroundColor: Colors.green.withOpacity(0.1),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }

  void _makeCall(String phoneNumber) {
    AppUtils.showSuccessSnackBar(context, 'Calling $phoneNumber...');
  }

  void _getDirections(Map<String, dynamic> service) {
    AppUtils.showSuccessSnackBar(
      context,
      'Opening directions to ${service['name']}...',
    );
  }

  void _getCurrentLocation() {
    AppUtils.showSuccessSnackBar(context, 'Getting your current location...');
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter Services'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CheckboxListTile(
              title: const Text('Open Now'),
              value: true,
              onChanged: (value) {},
            ),
            CheckboxListTile(
              title: const Text('Within 5km'),
              value: true,
              onChanged: (value) {},
            ),
            CheckboxListTile(
              title: const Text('4+ Star Rating'),
              value: false,
              onChanged: (value) {},
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
              AppUtils.showSuccessSnackBar(context, 'Filters applied');
            },
            child: const Text('Apply'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}
