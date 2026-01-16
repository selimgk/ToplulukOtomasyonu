import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:derss1/database_helper.dart';

class NewsService {
  // Simulate fetching from an API
  Future<List<Map<String, dynamic>>> fetchLatestNews() async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));

    // Mock Data
    final mockNews = [
      {
        'title': 'Bahar Şenlikleri Başlıyor!',
        'summary': 'Bu yılki bahar şenlikleri 20-25 Mayıs tarihleri arasında kampüsümüzde gerçekleşecek. Ünlü sanatçılar ve sürpriz etkinlikler sizleri bekliyor.',
        'source': 'Rektörlük',
        'date': DateTime.now().toIso8601String(),
        'imageUrl': 'https://cdn-icons-png.flaticon.com/512/3135/3135715.png' // Festival icon
      },
      {
        'title': 'Kütüphane Çalışma Saatleri Güncellendi',
        'summary': 'Final haftası boyunca merkez kütüphanemiz 7/24 hizmet verecektir. Öğrencilerimize başarılar dileriz.',
        'source': 'Kütüphane Daire Bşk.',
        'date': DateTime.now().subtract(const Duration(days: 1)).toIso8601String(),
        'imageUrl': 'https://cdn-icons-png.flaticon.com/512/2232/2232688.png' // Library icon
      },
      {
        'title': 'Teknofest Başvuruları Başladı',
        'summary': 'Milli Teknoloji Hamlesi heyecanı başlıyor! Projelerini hazırla, takımı kur ve yarışmaya katıl.',
        'source': 'T3 Vakfı',
        'date': DateTime.now().subtract(const Duration(days: 2)).toIso8601String(),
        'imageUrl': 'https://cdn-icons-png.flaticon.com/512/2010/2010990.png' // Rocket icon
      },
      {
        'title': 'Yemekhane Menüleri Mobil Uygulamada',
        'summary': 'Artık haftalık yemek listesine mobil uygulamamız üzerinden kolayca erişebilirsiniz.',
        'source': 'SKS',
        'date': DateTime.now().subtract(const Duration(days: 5)).toIso8601String(),
        'imageUrl': 'https://cdn-icons-png.flaticon.com/512/1046/1046784.png' // Food icon
      }
    ];

    return mockNews;
  }

  // Fetch from DB (Offline)
  Future<List<Map<String, dynamic>>> getCachedNews() async {
    return await DatabaseHelper.instance.readAllNews();
  }

  // Sync: Try to fetch online, save to DB. If fails, return cached.
  Future<List<Map<String, dynamic>>> getNews(bool hasInternet) async {
    if (hasInternet) {
      try {
        final onlineNews = await fetchLatestNews();
        await DatabaseHelper.instance.syncNews(onlineNews);
        return onlineNews;
      } catch (e) {
        debugPrint('News fetch error: $e');
        return await getCachedNews();
      }
    } else {
      return await getCachedNews();
    }
  }
}
