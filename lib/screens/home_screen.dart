import 'package:flutter/material.dart';
import 'package:derss1/database_helper.dart';
import 'package:derss1/models.dart';
import 'package:derss1/models/user_role.dart';
import 'package:intl/intl.dart';
import 'package:derss1/widgets/common_app_bar.dart';
import 'package:derss1/screens/qr_scanner_screen.dart';
import 'package:derss1/screens/communities_screen.dart';
import 'package:derss1/screens/community_detail_screen.dart';
import 'package:derss1/screens/my_tickets_screen.dart';

class HomeScreen extends StatefulWidget {
  final UserRole userRole;
  final String? username;
  final String? studentNumber;

  const HomeScreen({super.key, required this.userRole, this.username, this.studentNumber});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<Event>> _eventsFuture;

  Community? _myCommunity;

  @override
  void initState() {
    super.initState();
    _refreshEvents();
    _checkMembership();
  }

  Future<void> _checkMembership() async {
    final communities = await DatabaseHelper.instance.readAllCommunities();
    
    if (widget.userRole == UserRole.admin && widget.username != null) {
      // Admin Logic: Find community where president name contains username (simplified match)
      try {
        final myCom = communities.firstWhere(
          (c) => c.president != null && 
                 c.president!.toLowerCase().contains(widget.username!.toLowerCase()),
        );
        if (mounted) {
          setState(() {
            _myCommunity = myCom;
          });
        }
      } catch (e) {
        // No community found for this admin
      }
    } else if (widget.studentNumber != null) {
      // Student Logic
      final mem = await DatabaseHelper.instance.getMembership(widget.studentNumber!);
      if (mem != null) {
        try {
          final myCom = communities.firstWhere((c) => c.id == mem['community_id']);
          if (mounted) {
            setState(() {
              _myCommunity = myCom;
            });
          }
        } catch (e) {
           // Community might have been deleted
        }
      }
    }
  }

  void _refreshEvents() {
    setState(() {
      _eventsFuture = DatabaseHelper.instance.readAllEvents();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar(
        title: 'Uludağ Üniversitesi Topluluk Otomasyonu',
        showHome: true,
        actions: [
          if (widget.userRole == UserRole.student && widget.username != null)
             IconButton(
               icon: const Icon(Icons.confirmation_number),
               tooltip: 'Biletlerim',
               onPressed: () {
                 Navigator.push(
                   context,
                   MaterialPageRoute(
                     builder: (context) => MyTicketsScreen(username: widget.username!),
                   ),
                 );
               },
             ),
          if (widget.userRole == UserRole.admin)
            IconButton(
              icon: const Icon(Icons.qr_code_scanner),
              tooltip: 'QR Tara',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const QRScannerScreen()),
                );
              },
            ),
          IconButton(
            icon: const Icon(Icons.people),
            tooltip: 'Topluluklar',
            onPressed: () {
               Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CommunitiesScreen(
                    username: widget.username,
                    studentNumber: widget.studentNumber,
                  ),
                ),
              ).then((_) => _checkMembership());
            },
          ),
          IconButton(
            icon: const Icon(Icons.bar_chart),
            tooltip: 'Raporlar',
            onPressed: () {
              Navigator.pushNamed(context, '/reports');
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Çıkış Yap',
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
      body: FutureBuilder<List<Event>>(
        future: _eventsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
           // We can show the categories even if events are loading, but for simplicity let's wait or show static.
           // To keep it simple, we'll build the layout with data.
          
          final events = snapshot.data ?? [];
          final hasError = snapshot.hasError;

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // My Community Section (Moved Up)
                if (_myCommunity != null) ...[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    child: Text(
                      widget.userRole == UserRole.admin ? 'Yönetici Paneli' : 'Üyesi Olduğunuz Topluluk',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Card(
                      color: Colors.blue.shade50,
                      elevation: 4,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                        leading: (_myCommunity!.image != null && _myCommunity!.image!.isNotEmpty)
                            ? CircleAvatar(
                                radius: 24,
                                backgroundImage: _myCommunity!.image!.startsWith('assets/')
                                    ? AssetImage(_myCommunity!.image!)
                                    : NetworkImage(_myCommunity!.image!) as ImageProvider,
                              )
                            : const CircleAvatar(radius: 24, child: Icon(Icons.group)),
                        title: Text(_myCommunity!.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        subtitle: Text(widget.userRole == UserRole.admin ? 'Yönettiğiniz Topluluk' : 'Üyesi Olduğunuz Topluluk'),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                        onTap: () {
                           Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => CommunityDetailScreen(
                                  community: _myCommunity!,
                                  username: widget.username,
                                  studentNumber: widget.studentNumber,
                                ),
                              ),
                            ).then((_) => _checkMembership());
                        },
                      ),
                    ),
                  ),
                  const Divider(height: 32),
                ],

                // Categories Section
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Text(
                    'Kategoriler',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ),
                SizedBox(
                  height: 100,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    children: [
                       _buildCategoryPill(context, 'Bilim', Icons.science, Colors.blue),
                       _buildCategoryPill(context, 'Kültür', Icons.theater_comedy, Colors.red),
                       _buildCategoryPill(context, 'Spor', Icons.sports_basketball, Colors.green),
                       _buildCategoryPill(context, 'Mesleki', Icons.work, Colors.orange),
                       _buildCategoryPill(context, null, Icons.groups, Colors.purple, label: 'Tümü'),
                    ],
                  ),
                ),



                const Divider(height: 32),

                // Events Section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'Yaklaşan Etkinlikler',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ),
                
                if (hasError)
                   Padding(
                     padding: const EdgeInsets.all(16.0),
                     child: Text('Hata: ${snapshot.error}'),
                   )
                else if (events.isEmpty)
                   const Padding(
                    padding: EdgeInsets.all(32.0),
                    child: Center(
                      child: Column(
                        children: [
                          Icon(Icons.event_busy, size: 64, color: Colors.grey),
                          SizedBox(height: 16),
                          Text(
                            'Etkinlik bulunamadı',
                            style: TextStyle(fontSize: 18, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    itemCount: events.length,
                    itemBuilder: (context, index) {
                      final event = events[index];
                      return InteractiveEventCard(
                        event: event,
                        onTap: () async {
                          await Navigator.pushNamed(
                            context,
                            '/event_detail',
                            arguments: {
                              'event': event,
                              'userRole': widget.userRole,
                              'username': widget.username,
                            },
                          );
                          _refreshEvents();
                        },
                      );
                    },
                  ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: widget.userRole == UserRole.admin
          ? FloatingActionButton(
              onPressed: () async {
                await Navigator.pushNamed(context, '/add_event');
                _refreshEvents();
              },
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  Widget _buildCategoryPill(BuildContext context, String? category, IconData icon, Color color, {String? label}) {
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: InkWell(
        onTap: () {
            Navigator.push(
            context,
            MaterialPageRoute(
               builder: (context) => CommunitiesScreen(
                 category: category == 'Tümü' ? null : category,
                 username: widget.username,
                 studentNumber: widget.studentNumber,
               ),
            ),
          ).then((_) => _checkMembership());
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 80,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withValues(alpha: 0.3)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 32),
              const SizedBox(height: 8),
              Text(
                label ?? category ?? '',
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}


class InteractiveEventCard extends StatefulWidget {
  final Event event;
  final VoidCallback onTap;

  const InteractiveEventCard({
    super.key,
    required this.event,
    required this.onTap,
  });

  @override
  State<InteractiveEventCard> createState() => _InteractiveEventCardState();
}

class _InteractiveEventCardState extends State<InteractiveEventCard> {
  bool _isTapped = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isTapped = true),
      onTapUp: (_) => setState(() => _isTapped = false),
      onTapCancel: () => setState(() => _isTapped = false),
      onTap: () async {
        setState(() => _isTapped = true);
        await Future.delayed(const Duration(milliseconds: 150));
        if (mounted) {
           setState(() => _isTapped = false);
           widget.onTap();
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        margin: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: _isTapped ? const Color(0xFF1A237E) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              _buildCategoryImage(widget.event.category),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.event.title,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: _isTapped ? Colors.white : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.calendar_today, size: 14, color: _isTapped ? Colors.white70 : Colors.grey),
                        const SizedBox(width: 4),
                        Text(
                          DateFormat('dd MMM yyyy', 'tr').format(widget.event.date),
                          style: TextStyle(color: _isTapped ? Colors.white70 : Colors.grey[700]),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Icon(Icons.location_on, size: 14, color: _isTapped ? Colors.white70 : Colors.grey),
                        const SizedBox(width: 4),
                        Text(
                          widget.event.location,
                          style: TextStyle(color: _isTapped ? Colors.white70 : Colors.grey[700]),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, size: 16, color: _isTapped ? Colors.white : Colors.grey),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryImage(String category) {
    String assetPath; // Now strictly using assets, no network URLs
    
    // Normalize: Trim whitespace and convert to lowercase for reliable matching
    final normalizedCategory = category.trim().toLowerCase();

    switch (normalizedCategory) {
      // 1. Specific Custom Assets (User Uploaded)
      case 'quiz night':
      case 'quiz':
      case 'yarışma':
      case 'eğlence':
      case 'entertainment':
      case 'festival':
      case 'parti':
      case 'konser':
      case 'concert':
      case 'müzik':
        assetPath = 'assets/images/cat_entertainment.png';
        break;

      case 'proje sergisi':
      case 'project exhibition':
      case 'teknofest':
      case 'sergi':
      case 'bilim':
      case 'teknoloji':
      case 'yazılım':
      case 'mühendislik':
        assetPath = 'assets/images/cat_science.png';
        break;

      case 'toplantı':
      case 'meeting':
      case 'topluluk toplantısı':
      case 'seminer':
      case 'konferans':
      case 'panel':
      case 'söyleşi':
      case 'sunum':
      case 'eğitim':
      case 'workshop':
      case 'atölye':
      case 'çalıştay':
      case 'mesleki':
      case 'kariyer':
      case 'staj':
      case 'iş':
      case 'mesleki gelişim':
        assetPath = 'assets/images/cat_career.png';
        break;

      case 'spor':
      case 'turnuva':
      case 'futbol':
      case 'basketbol':
      case 'voleybol':
      case 'maç':
        assetPath = 'assets/images/cat_sports.png';
        break;

      case 'kültür':
      case 'sanat':
      case 'kültür ve sanat':
      case 'tiyatro':
      case 'sinema':
        assetPath = 'assets/images/cat_culture.png';
        break;

      default: 
        assetPath = 'assets/images/uludag_logo.png'; // Default fallback
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Image.asset(
        assetPath,
        width: 80,
        height: 80,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Image.asset(
            'assets/images/uludag_logo.png',
            width: 80,
            height: 80,
            fit: BoxFit.cover,
          );
        },
      ),
    );
  }
}
