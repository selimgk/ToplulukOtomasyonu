import 'package:flutter/material.dart';
import 'package:derss1/database_helper.dart';
import 'package:derss1/models.dart';
import 'package:derss1/widgets/common_app_bar.dart';
import 'package:derss1/screens/community_detail_screen.dart';

class CommunitiesScreen extends StatefulWidget {
  final String? category;
  final String? username;
  final String? studentNumber;
  const CommunitiesScreen({super.key, this.category, this.username, this.studentNumber});

  @override
  State<CommunitiesScreen> createState() => _CommunitiesScreenState();
}

class _CommunitiesScreenState extends State<CommunitiesScreen> {
  late Future<List<Community>> _communitiesFuture;

  @override
  void initState() {
    super.initState();
    _communitiesFuture = DatabaseHelper.instance.readAllCommunities();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar(
        title: widget.category != null ? '${widget.category} Toplulukları' : 'Tüm Topluluklar',
        showHome: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.event),
            tooltip: 'Etkinlikler',
            onPressed: () {
              Navigator.pushNamed(context, '/events');
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
      body: FutureBuilder<List<Community>>(
        future: _communitiesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Hata: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Topluluk bulunamadı.'));
          }

          final allCommunities = snapshot.data!;
          final displayedCommunities = widget.category == null 
              ? allCommunities 
              : allCommunities.where((c) => c.category == widget.category).toList();

          if (displayedCommunities.isEmpty) {
             return const Center(child: Text('Bu kategoride topluluk bulunamadı.'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: displayedCommunities.length,
            itemBuilder: (context, index) {
              final community = displayedCommunities[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CommunityDetailScreen(
                          community: community,
                          username: widget.username,
                          studentNumber: widget.studentNumber,
                        ),
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(12), // Match card shape
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (community.image != null && community.image!.isNotEmpty)
                          Container(
                            width: 80,
                            height: 80,
                            margin: const EdgeInsets.only(right: 16),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              image: DecorationImage(
                                image: community.image!.startsWith('assets/')
                                    ? AssetImage(community.image!) as ImageProvider
                                    : NetworkImage(community.image!),
                                fit: BoxFit.cover,
                                onError: (e, s) {}, // Handle error silently
                              ),
                            ),
                          )
                        else
                          Container(
                             width: 80,
                             height: 80,
                             margin: const EdgeInsets.only(right: 16),
                             decoration: BoxDecoration(
                               borderRadius: BorderRadius.circular(8),
                               image: const DecorationImage(
                                 image: AssetImage('assets/images/uludag_logo.png'),
                                 fit: BoxFit.cover,
                               )
                             ),
                          ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                community.name,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                community.description,
                                style: const TextStyle(fontSize: 14),
                                maxLines: 2, // Limit lines in list view
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
