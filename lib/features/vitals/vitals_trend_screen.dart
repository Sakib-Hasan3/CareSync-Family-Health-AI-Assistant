import 'package:flutter/material.dart';
import '../../core/constants/app_strings.dart';
import '../../core/utils/app_utils.dart';

/// Vitals trend screen showing charts and analysis
class VitalsTrendScreen extends StatefulWidget {
  const VitalsTrendScreen({super.key});

  @override
  State<VitalsTrendScreen> createState() => _VitalsTrendScreenState();
}

class _VitalsTrendScreenState extends State<VitalsTrendScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedPeriod = '7D';
  final List<String> _periods = ['7D', '30D', '3M', '6M', '1Y'];

  // Mock data for demonstration
  final List<Map<String, dynamic>> _bloodPressureData = [
    {
      'date': DateTime.now().subtract(const Duration(days: 6)),
      'systolic': 120,
      'diastolic': 80,
    },
    {
      'date': DateTime.now().subtract(const Duration(days: 5)),
      'systolic': 125,
      'diastolic': 82,
    },
    {
      'date': DateTime.now().subtract(const Duration(days: 4)),
      'systolic': 118,
      'diastolic': 78,
    },
    {
      'date': DateTime.now().subtract(const Duration(days: 3)),
      'systolic': 122,
      'diastolic': 81,
    },
    {
      'date': DateTime.now().subtract(const Duration(days: 2)),
      'systolic': 119,
      'diastolic': 79,
    },
    {
      'date': DateTime.now().subtract(const Duration(days: 1)),
      'systolic': 121,
      'diastolic': 80,
    },
    {'date': DateTime.now(), 'systolic': 123, 'diastolic': 82},
  ];

  final List<Map<String, dynamic>> _heartRateData = [
    {'date': DateTime.now().subtract(const Duration(days: 6)), 'rate': 72},
    {'date': DateTime.now().subtract(const Duration(days: 5)), 'rate': 75},
    {'date': DateTime.now().subtract(const Duration(days: 4)), 'rate': 68},
    {'date': DateTime.now().subtract(const Duration(days: 3)), 'rate': 70},
    {'date': DateTime.now().subtract(const Duration(days: 2)), 'rate': 73},
    {'date': DateTime.now().subtract(const Duration(days: 1)), 'rate': 71},
    {'date': DateTime.now(), 'rate': 74},
  ];

  final List<Map<String, dynamic>> _weightData = [
    {'date': DateTime.now().subtract(const Duration(days: 30)), 'weight': 70.5},
    {'date': DateTime.now().subtract(const Duration(days: 20)), 'weight': 70.2},
    {'date': DateTime.now().subtract(const Duration(days: 10)), 'weight': 69.8},
    {'date': DateTime.now(), 'weight': 69.5},
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
        title: const Text(AppStrings.vitalsTrends),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.calendar_today),
            onSelected: (value) {
              setState(() {
                _selectedPeriod = value;
              });
            },
            itemBuilder: (context) => _periods.map((period) {
              return PopupMenuItem(
                value: period,
                child: Row(
                  children: [
                    if (_selectedPeriod == period)
                      const Icon(Icons.check, size: 20),
                    if (_selectedPeriod == period) const SizedBox(width: 8),
                    Text(period),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Blood Pressure'),
            Tab(text: 'Heart Rate'),
            Tab(text: 'Weight'),
            Tab(text: 'All Vitals'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildBloodPressureTab(),
          _buildHeartRateTab(),
          _buildWeightTab(),
          _buildAllVitalsTab(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).pushNamed('/vitals-input');
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildBloodPressureTab() {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        _buildSummaryCard(
          'Blood Pressure',
          '121/81 mmHg',
          'Normal',
          Colors.green,
          Icons.favorite,
        ),
        const SizedBox(height: 16),
        _buildChartCard(
          'Blood Pressure Trend',
          _buildMockChart('Blood Pressure', Colors.red),
        ),
        const SizedBox(height: 16),
        _buildInsightsCard([
          'Your blood pressure has been stable over the last week',
          'Average: 121/80 mmHg (Normal range)',
          'Recommendation: Continue current lifestyle',
        ]),
        const SizedBox(height: 16),
        _buildDataTable(
          ['Date', 'Systolic', 'Diastolic', 'Status'],
          _bloodPressureData
              .map(
                (data) => [
                  AppUtils.formatDate(data['date']),
                  '${data['systolic']}',
                  '${data['diastolic']}',
                  'Normal',
                ],
              )
              .toList(),
        ),
      ],
    );
  }

  Widget _buildHeartRateTab() {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        _buildSummaryCard(
          'Heart Rate',
          '72 bpm',
          'Normal',
          Colors.pink,
          Icons.monitor_heart,
        ),
        const SizedBox(height: 16),
        _buildChartCard(
          'Heart Rate Trend',
          _buildMockChart('Heart Rate', Colors.pink),
        ),
        const SizedBox(height: 16),
        _buildInsightsCard([
          'Your resting heart rate is in the normal range',
          'Average: 72 bpm (Normal: 60-100 bpm)',
          'Lowest: 68 bpm, Highest: 75 bpm',
        ]),
        const SizedBox(height: 16),
        _buildDataTable(
          ['Date', 'Heart Rate', 'Status'],
          _heartRateData
              .map(
                (data) => [
                  AppUtils.formatDate(data['date']),
                  '${data['rate']} bpm',
                  'Normal',
                ],
              )
              .toList(),
        ),
      ],
    );
  }

  Widget _buildWeightTab() {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        _buildSummaryCard(
          'Weight',
          '69.5 kg',
          'Healthy',
          Colors.blue,
          Icons.monitor_weight,
        ),
        const SizedBox(height: 16),
        _buildChartCard('Weight Trend', _buildMockChart('Weight', Colors.blue)),
        const SizedBox(height: 16),
        _buildInsightsCard([
          'You\'ve lost 1.0 kg over the last month',
          'Current BMI: 22.7 (Normal range)',
          'Goal: Maintain current weight',
        ]),
        const SizedBox(height: 16),
        _buildDataTable(
          ['Date', 'Weight', 'Change'],
          _weightData.asMap().entries.map((entry) {
            final index = entry.key;
            final data = entry.value;
            final change = index > 0
                ? (data['weight'] - _weightData[index - 1]['weight'])
                      .toStringAsFixed(1)
                : '0.0';
            return [
              AppUtils.formatDate(data['date']),
              '${data['weight']} kg',
              '${change.startsWith('-') ? '' : '+'}$change kg',
            ];
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildAllVitalsTab() {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        Row(
          children: [
            Expanded(
              child: _buildMiniSummaryCard(
                'BP',
                '121/81',
                Colors.red,
                Icons.favorite,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildMiniSummaryCard(
                'HR',
                '72 bpm',
                Colors.pink,
                Icons.monitor_heart,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _buildMiniSummaryCard(
                'Weight',
                '69.5 kg',
                Colors.blue,
                Icons.monitor_weight,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildMiniSummaryCard(
                'Temp',
                '36.5°C',
                Colors.orange,
                Icons.thermostat,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildChartCard('Overall Health Score', _buildHealthScoreChart()),
        const SizedBox(height: 16),
        _buildInsightsCard([
          'Overall health status: Excellent',
          'All vitals are within normal ranges',
          'Consistent monitoring shows stable health',
          'Keep up the good work!',
        ]),
      ],
    );
  }

  Widget _buildSummaryCard(
    String title,
    String value,
    String status,
    Color color,
    IconData icon,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 32),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Text(
                        value,
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(color: color, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMiniSummaryCard(
    String title,
    String value,
    Color color,
    IconData icon,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(title, style: Theme.of(context).textTheme.bodySmall),
            Text(value, style: Theme.of(context).textTheme.titleSmall),
          ],
        ),
      ),
    );
  }

  Widget _buildChartCard(String title, Widget chart) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 16),
            chart,
          ],
        ),
      ),
    );
  }

  Widget _buildMockChart(String type, Color color) {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.show_chart, size: 48, color: color),
            const SizedBox(height: 8),
            Text(
              '$type Chart',
              style: TextStyle(color: color, fontWeight: FontWeight.bold),
            ),
            Text(
              'Data for last $_selectedPeriod',
              style: TextStyle(color: color.withOpacity(0.7)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHealthScoreChart() {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.green.withOpacity(0.1), Colors.blue.withOpacity(0.1)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '95',
              style: TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            Text(
              'Health Score',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            Text('Excellent', style: TextStyle(color: Colors.green)),
          ],
        ),
      ),
    );
  }

  Widget _buildInsightsCard(List<String> insights) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.lightbulb, color: Colors.amber),
                const SizedBox(width: 8),
                Text(
                  'Insights',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...insights.map(
              (insight) => Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('• ', style: TextStyle(color: Colors.amber)),
                    Expanded(child: Text(insight)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDataTable(List<String> headers, List<List<String>> rows) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Recent Readings',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: headers
                    .map(
                      (header) => DataColumn(
                        label: Text(
                          header,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    )
                    .toList(),
                rows: rows
                    .map(
                      (row) => DataRow(
                        cells: row.map((cell) => DataCell(Text(cell))).toList(),
                      ),
                    )
                    .toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}
