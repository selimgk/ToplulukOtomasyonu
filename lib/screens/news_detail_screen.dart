import 'package:flutter/material.dart';


class NewsDetailScreen extends StatelessWidget {
  final String title;
  final String summary;
  final String? imageUrl;
  final IconData icon;
  final String source;
  final String sourceUrl;

  const NewsDetailScreen({
    super.key,
    required this.title,
    required this.summary,
    required this.icon,
    this.imageUrl,
    this.source = 'Uludağ Üniversitesi',
    this.sourceUrl = 'https://uludag.edu.tr',
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Haber Detayı'),
        backgroundColor: const Color(0xFF1A237E),
        iconTheme: const IconThemeData(color: Colors.white),
        titleTextStyle: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero Image/Icon Section
            Container(
              width: double.infinity,
              height: 200,
              decoration: BoxDecoration(
                color: const Color(0xFF1A237E).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
                image: imageUrl != null 
                    ? DecorationImage(
                        image: NetworkImage(imageUrl!),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: imageUrl == null 
                  ? Center(child: Icon(icon, size: 80, color: const Color(0xFF1A237E))) 
                  : null,
            ),
            const SizedBox(height: 24),
            
            // Title
            Text(
              title,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A237E),
              ),
            ),
            const SizedBox(height: 16),
            
            // Summary Highlight
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.1),
                border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                summary,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
            const SizedBox(height: 24),
            
            // Detailed Content (Placeholder)
            const Text(
              "Detaylı İçerik:",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              "Bu haberin detayları yakında eklenecektir. Kampüsümüzdeki tüm gelişmelerden haberdar olmak için duyurularımızı takip etmeye devam edin. Öğrencilerimizin ve akademik personelimizin katılımıyla gerçekleşecek etkinlikler ve yenilikler hakkında daha fazla bilgiye web sitemizden de ulaşabilirsiniz.",
              style: TextStyle(fontSize: 16, height: 1.6, color: Colors.grey.shade800),
            ),
            const SizedBox(height: 16),
            Text(
              "Uludağ Üniversitesi Yönetimi olarak, kampüs yaşamını zenginleştirmek ve öğrencilerimize daha iyi olanaklar sunmak için çalışmalarımızı aralıksız sürdürüyoruz.",
              style: TextStyle(fontSize: 16, height: 1.6, color: Colors.grey.shade800),
            ),
            const SizedBox(height: 32),
            const Divider(),
            const SizedBox(height: 16),
            
            // Source Section
            Row(
              children: [
                const Icon(Icons.link, color: Colors.grey, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Kaynak: $source',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            InkWell(
              onTap: () {
                // In a real app, launch URL here
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('$sourceUrl adresine gidiliyor...')),
                );
              },
              child: Text(
                sourceUrl,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.blue,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
