import 'package:flutter/material.dart';
import 'package:derss1/screens/communities_screen.dart';

class CommunityCategoryScreen extends StatelessWidget {
  const CommunityCategoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Topluluk Kategorileri'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildCategoryCard(context, 'Bilim', Icons.science, Colors.blue),
            const SizedBox(height: 16),
            _buildCategoryCard(context, 'Kültür', Icons.theater_comedy, Colors.red),
            const SizedBox(height: 16),
            _buildCategoryCard(context, 'Spor', Icons.sports_basketball, Colors.green),
            const SizedBox(height: 16),
            _buildCategoryCard(context, 'Mesleki', Icons.work, Colors.orange),
             const SizedBox(height: 16),
            _buildCategoryCard(context, 'Tümü', Icons.list, Colors.grey, isAll: true),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryCard(BuildContext context, String title, IconData icon, Color color, {bool isAll = false}) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CommunitiesScreen(category: isAll ? null : title),
            ),
          );
        },
        child: Container(
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withValues(alpha: 0.3), width: 2),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 40, color: color),
              const SizedBox(width: 16),
              Text(
                title,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: color.withValues(alpha: 0.8),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
