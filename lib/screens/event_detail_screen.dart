import 'package:flutter/material.dart';
import 'package:derss1/database_helper.dart';
import 'package:derss1/models.dart';
import 'package:derss1/models/user_role.dart';
import 'package:intl/intl.dart';
import 'package:derss1/screens/add_event_screen.dart';
import 'package:derss1/services/notification_service.dart';
import 'package:derss1/screens/ticket_screen.dart';
import 'package:derss1/widgets/common_app_bar.dart';

class EventDetailScreen extends StatefulWidget {
  const EventDetailScreen({super.key});

  @override
  State<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends State<EventDetailScreen> {
  late Event _event;
  late UserRole _userRole;
  String? _username;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _departmentController = TextEditingController();
  final TextEditingController _gradeController = TextEditingController();
  List<Rsvp> _rsvps = [];


  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    _event = args['event'] as Event;
    _userRole = args['userRole'] as UserRole;
    _username = args['username'] as String?;
    
    // Auto-fill name if available and empty
    if (_username != null && _nameController.text.isEmpty) {
      _nameController.text = _username!;
    }
    
    _refreshRsvps();
  }

  String _getStatusLabel(String status) {
    switch (status) {
      case 'confirmed': return 'Onaylandı';
      case 'rejected': return 'Reddedildi';
      case 'pending': return 'Onay Bekliyor';
      default: return 'Bilinmiyor';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _departmentController.dispose();
    _gradeController.dispose();
    super.dispose();
  }

  Future<void> _refreshRsvps() async {
    final rsvps = await DatabaseHelper.instance.readRsvpsForEvent(_event.id!);
    setState(() {
      _rsvps = rsvps;
      _rsvps = rsvps;
    });
  }

  Future<void> _addRsvp() async {
    if (_nameController.text.isEmpty ||
        _departmentController.text.isEmpty ||
        _gradeController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lütfen tüm alanları doldurun')),
      );
      return;
    }

    final rsvp = Rsvp(
      eventId: _event.id!,
      name: _nameController.text,
      department: _departmentController.text,
      grade: _gradeController.text,
      timestamp: DateTime.now(),
    );

    await DatabaseHelper.instance.createRsvp(rsvp);
    _nameController.clear();
    _departmentController.clear();
    _gradeController.clear();
    if (!mounted) return;
    _refreshRsvps();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Katılımınız alındı!')),
    );
  }

  Future<void> _deleteRsvp(int id) async {
    await DatabaseHelper.instance.deleteRsvp(id);
    if (!mounted) return;
    _refreshRsvps();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Katılımcı silindi')),
    );
  }

  Future<void> _deleteEvent() async {
    await DatabaseHelper.instance.deleteEvent(_event.id!);
    if (mounted) Navigator.pop(context); // Go back to home
  }

  Future<void> _editEvent() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddEventScreen(event: _event),
      ),
    );
    final updatedEvent = await DatabaseHelper.instance.readEvent(_event.id!);
    setState(() {
      _event = updatedEvent;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar(
        title: _event.title,
        showHome: true,
        actions: _userRole == UserRole.admin
            ? [
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: _editEvent,
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('Etkinliği Sil?'),
                        content: const Text('Bu işlem geri alınamaz.'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx),
                            child: const Text('İptal'),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pop(ctx);
                              _deleteEvent();
                            },
                            child: const Text('Sil', style: TextStyle(color: Colors.red)),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ]
            : null,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Event Details Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _event.title,
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            color: Colors.blue,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                        const SizedBox(width: 8),
                        Text(
                          DateFormat('EEEE, d MMM, yyyy', 'tr').format(_event.date),
                          style: const TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.location_on, size: 16, color: Colors.grey),
                        const SizedBox(width: 8),
                        Text(
                          _event.location,
                          style: const TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Chip(label: Text(_event.category), backgroundColor: Colors.blue.shade50),
                    const SizedBox(height: 16),
                    Text(
                      _event.description,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // RSVP Status for Student
            // Find RSVP for current user if logged in
            if (_userRole == UserRole.student) ...[
              Builder(
                builder: (context) {
                  Rsvp? myRsvp;
                  if (_username != null && _username!.isNotEmpty) {
                    try {
                      myRsvp = _rsvps.firstWhere((r) => r.name.toLowerCase().trim() == _username!.toLowerCase().trim());
                    } catch (e) {
                      // No RSVP found
                    }
                  }

                  if (myRsvp != null) {
                    return Column(
                      children: [
                        Card(
                          color: _getStatusColor(myRsvp.status).withValues(alpha: 0.1),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Row(
                              children: [
                                Icon(
                                  myRsvp.status == 'confirmed' ? Icons.check_circle : 
                                  myRsvp.status == 'rejected' ? Icons.cancel : Icons.hourglass_empty,
                                  color: _getStatusColor(myRsvp.status),
                                  size: 32,
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Başvuru Durumu: ${_getStatusLabel(myRsvp.status)}',
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                      ),
                                      if (myRsvp.status == 'confirmed')
                                        const Text('Giriş için biletinizi görüntüleyebilirsiniz.')
                                      else if (myRsvp.status == 'pending')
                                        const Text('Başvurunuz yönetici onayı bekliyor.')
                                      else
                                        const Text('Başvurunuz maalesef onaylanmadı.'),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        if (myRsvp.status == 'confirmed')
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              onPressed: _openTicket,
                              icon: const Icon(Icons.qr_code),
                              label: const Text('Biletini Gör'),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.all(16),
                              ),
                            ),
                          ),
                        const SizedBox(height: 24),
                      ],
                    );
                  } else {
                    // Show RSVP Form
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Etkinliğe Katıl',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 16),
                        Card(
                          elevation: 2,
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              children: [
                                TextField(
                                  controller: _nameController,
                                  decoration: const InputDecoration(
                                    hintText: 'Ad Soyad',
                                    prefixIcon: Icon(Icons.person),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                TextField(
                                  controller: _departmentController,
                                  decoration: const InputDecoration(
                                    hintText: 'Bölüm',
                                    prefixIcon: Icon(Icons.school),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                TextField(
                                  controller: _gradeController,
                                  decoration: const InputDecoration(
                                    hintText: 'Sınıf',
                                    prefixIcon: Icon(Icons.class_),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: _addRsvp,
                                    child: const Text('Katıl (Onay Gerektirir)'),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                    );
                  }
                }
              ),
            ],

            // Participants Sections
            if (_userRole == UserRole.admin) ...[
              _buildSectionTitle('Onay Bekleyenler'),
              _buildRsvpList(_rsvps.where((r) => r.status == 'pending').toList(), showActions: true),
              const SizedBox(height: 24),
              _buildSectionTitle('Katılımcı Listesi'),
              _buildRsvpList(_rsvps.where((r) => r.status == 'confirmed').toList(), showDelete: true),
              const SizedBox(height: 24),
              _buildSectionTitle('Reddedilenler'),
              _buildRsvpList(_rsvps.where((r) => r.status == 'rejected').toList(), showDelete: true),
            ] else ...[
              // Student View: Show confirmed and maybe their own status?
              // For simplicity, showing confirmed list to everyone
              _buildSectionTitle('Katılımcılar'),
              _buildRsvpList(_rsvps.where((r) => r.status == 'confirmed').toList()),
               // Show a small note if they have pending requests?
               // Ideally we'd filter for "my" requests but simple auth doesn't track ID perfectly.
               // Just showing list is fine per requirements.
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildRsvpList(List<Rsvp> rsvps, {bool showActions = false, bool showDelete = false}) {
    if (rsvps.isEmpty) {
      return const Padding(
        padding: EdgeInsets.only(bottom: 8.0),
        child: Text('Liste boş.', style: TextStyle(color: Colors.grey)),
      );
    }
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: rsvps.length,
      itemBuilder: (context, index) {
        final rsvp = rsvps[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: _getStatusColor(rsvp.status),
              child: Text(rsvp.name.isNotEmpty ? rsvp.name[0].toUpperCase() : '?', style: const TextStyle(color: Colors.white)),
            ),
            title: Text(rsvp.name),
            subtitle: Text('${rsvp.department} - ${rsvp.grade}. Sınıf\n${DateFormat('d MMM, HH:mm', 'tr').format(rsvp.timestamp)}'),
            isThreeLine: true,
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (showActions) ...[
                  IconButton(
                    icon: const Icon(Icons.check_circle, color: Colors.green),
                    onPressed: () => _updateStatus(rsvp.id!, 'confirmed'),
                  ),
                  IconButton(
                    icon: const Icon(Icons.cancel, color: Colors.red),
                    onPressed: () => _updateStatus(rsvp.id!, 'rejected'),
                  ),
                ],
                if (showDelete)
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.grey),
                    onPressed: () => _deleteRsvp(rsvp.id!),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'confirmed': return Colors.green;
      case 'rejected': return Colors.red;
      case 'pending': return Colors.orange;
      default: return Colors.blue;
    }
  }

  Future<void> _updateStatus(int id, String status) async {
    await DatabaseHelper.instance.updateRsvpStatus(id, status);
    if (status == 'confirmed') {
      await NotificationService().scheduleEventReminder(_event);
    }
    _refreshRsvps();
  }

  void _openTicket() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => TicketScreen(event: _event)),
    );
  }
}
