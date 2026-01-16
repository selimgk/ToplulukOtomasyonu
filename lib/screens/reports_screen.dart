import 'package:flutter/material.dart';
import 'package:derss1/database_helper.dart';
import 'package:derss1/models.dart';
import 'package:derss1/widgets/common_app_bar.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  int _totalEvents = 0;
  int _totalRsvps = 0;
  List<Map<String, dynamic>> _popularEvents = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    final events = await DatabaseHelper.instance.readAllEvents();
    final rsvps = await DatabaseHelper.instance.readAllRsvps();

    // Calculate popularity
    Map<int, int> counts = {}; // eventId -> count
    for (var rsvp in rsvps) {
      counts[rsvp.eventId] = (counts[rsvp.eventId] ?? 0) + 1;
    }

    List<Map<String, dynamic>> popular = [];
    for (var event in events) {
      if (counts.containsKey(event.id)) {
        popular.add({
          'event': event,
          'count': counts[event.id],
        });
      }
    }

    popular.sort((a, b) => (b['count'] as int).compareTo(a['count'] as int));

    setState(() {
      _totalEvents = events.length;
      _totalRsvps = rsvps.length;
      _popularEvents = popular;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CommonAppBar(title: 'Reports', showHome: true),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    children: [
                      _buildStatCard('Total Events', '$_totalEvents', Icons.event),
                      const SizedBox(width: 16),
                      _buildStatCard('Total RSVPs', '$_totalRsvps', Icons.people),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Most Popular Events',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (_popularEvents.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text('No RSVP data yet.'),
                    )
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _popularEvents.length,
                      itemBuilder: (context, index) {
                        final item = _popularEvents[index];
                        final event = item['event'] as Event;
                        final count = item['count'] as int;
                        return Card(
                          child: ListTile(
                            title: Text(event.title),
                            trailing: CircleAvatar(
                              backgroundColor: Colors.blue,
                              child: Text(
                                '$count',
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                ],
              ),
            ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon) {
    return Expanded(
      child: Card(
        color: Colors.blue.shade50,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Icon(icon, size: 32, color: Colors.blue),
              const SizedBox(height: 8),
              Text(
                value,
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blue),
              ),
              const SizedBox(height: 4),
              Text(title, style: const TextStyle(color: Colors.grey)),
            ],
          ),
        ),
      ),
    );
  }
}
