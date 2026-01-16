import 'package:flutter/material.dart';
import 'package:derss1/models/user_role.dart';


import 'package:derss1/screens/news_detail_screen.dart';
import 'package:derss1/services/news_service.dart';

class RoleSelectionScreen extends StatefulWidget {
  const RoleSelectionScreen({super.key});

  @override
  State<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen> {

  late Future<List<Map<String, dynamic>>> _newsFuture;
  final NewsService _newsService = NewsService();

  @override
  void initState() {
    super.initState();

    _newsFuture = _newsService.getNews(true); // Simulate internet = true
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Uludağ Üniversitesi Topluluk Otomasyonu'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        titleTextStyle: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1A237E), Color(0xFF283593), Color(0xFF3949AB)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Top Section (Logo + Buttons)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: () {
                        // Logo click action if needed
                      },
                      child: Container(
                         padding: const EdgeInsets.all(12),
                         decoration: BoxDecoration(
                           color: Colors.white.withValues(alpha: 0.1),
                           shape: BoxShape.circle,
                           border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                         ),
                         child: Image.asset(
                          'assets/logo.png',
                          height: 100,
                          errorBuilder: (context, error, stackTrace) {
                            return const Column(
                              children: [
                                Icon(Icons.school, size: 60, color: Colors.white),
                              ],
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: _buildCompactRoleCard(
                            context,
                            title: 'Yönetici',
                            icon: Icons.admin_panel_settings,
                            color: const Color(0xFF1A237E), // Navy for text
                            role: UserRole.admin,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildCompactRoleCard(
                            context,
                            title: 'Öğrenci',
                            icon: Icons.person_outline,
                            color: Colors.orange.shade800,
                            role: UserRole.student,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 8),
              
              // News Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Row(
                    children: [
                      const Icon(Icons.newspaper, color: Colors.white, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Kampüsten Güncel Haberler',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white.withValues(alpha: 0.9)),
                      ),
                    ],
                  ),
                ),
              ),
              
              Expanded(
                child: FutureBuilder<List<Map<String, dynamic>>>(
                  future: _newsFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator(color: Colors.white));
                    }
                    
                    final newsList = snapshot.data ?? [];
                    if (newsList.isEmpty) {
                       return Center(child: Text('Haber bulunamadı.', style: TextStyle(color: Colors.white.withValues(alpha: 0.7))));
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: newsList.length,
                      itemBuilder: (context, index) {
                        final news = newsList[index];
                        return _buildNewsCard(
                          news['title'],
                          news['summary'],
                          imageUrl: news['imageUrl'],
                          source: news['source'] ?? 'Uludağ Üniversitesi',
                          date: news['date'],
                        );
                      },
                    );
                  },
                ),
              ),

              // Bottom copyright
              Padding(
                padding: const EdgeInsets.only(top: 16.0, bottom: 24.0),
                child: Text(
                  '© 2026 Uludağ Üniversitesi',
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 12),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCompactRoleCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color color,
    required UserRole role,
  }) {
    return InkWell(
      onTap: () => Navigator.pushNamed(context, '/login', arguments: role),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 32, color: color),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNewsCard(
    String title,
    String summary, {
    String? imageUrl,
    String source = 'Uludağ Üniversitesi',
    String? date,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: ListTile(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => NewsDetailScreen(
                title: title,
                summary: summary,
                imageUrl: imageUrl, // Pass image url
                icon: Icons.newspaper, 
                source: source,
                sourceUrl: 'https://uludag.edu.tr',
              ),
            ),
          );
        },
        leading: Container(
          width: 48,
          height: 48,
          padding: imageUrl != null ? EdgeInsets.zero : const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            shape: BoxShape.circle,
            image: imageUrl != null 
                ? DecorationImage(image: NetworkImage(imageUrl), fit: BoxFit.cover)
                : null,
          ),
          child: imageUrl == null ? const Icon(Icons.newspaper, color: Colors.white, size: 24) : null,
        ),
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                summary,
                style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 13),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              if (date != null)
                Padding(
                  padding: const EdgeInsets.only(top: 4.0),
                  child: Text(
                    source,
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 11),
                  ),
                ),
            ],
          ),
        ),
        trailing: Icon(Icons.arrow_forward_ios, color: Colors.white.withValues(alpha: 0.5), size: 16),
      ),
    );
  }
}
