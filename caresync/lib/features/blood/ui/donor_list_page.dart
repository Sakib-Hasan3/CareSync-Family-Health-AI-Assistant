import 'package:flutter/material.dart';
import '../donor_repository.dart';
import '../models/donor.dart';
import 'donor_detail_page.dart';

class DonorListPage extends StatefulWidget {
  const DonorListPage({super.key});

  @override
  State<DonorListPage> createState() => _DonorListPageState();
}

class _DonorListPageState extends State<DonorListPage> {
  final DonorRepository _repo = DonorRepository();
  List<Donor> _donors = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    await _repo.init();
    setState(() {
      _donors = _repo.getAll();
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('All Donors'),
        backgroundColor: const Color(0xFFDC143C),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _load,
              color: const Color(0xFFDC143C),
              child: ListView.separated(
                padding: const EdgeInsets.all(12),
                itemCount: _donors.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, i) {
                  final d = _donors[i];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: _getBloodGroupColor(d.bloodGroup),
                      child: Text(
                        d.bloodGroup,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    title: Text(d.name),
                    subtitle: Text('${d.city} • ${d.phone}'),
                    trailing: Text(
                      d.available ? 'Available' : 'Unavailable',
                      style: TextStyle(
                        color: d.available ? Colors.green : Colors.grey,
                      ),
                    ),
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => DonorDetailPage(donor: d),
                        ),
                      );
                      if (!mounted) return;
                      _load();
                    },
                  );
                },
              ),
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
