import 'package:sqflite/sqflite.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:derss1/models.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('campus_events.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 18, // Incremented version to 18
      onCreate: _createDB,
      onUpgrade: _onUpgrade,
    );
  }

  Future _createDB(Database db, int version) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT NOT NULL';
    const integerType = 'INTEGER NOT NULL';

    await db.execute('''
CREATE TABLE events (
  id $idType,
  title $textType,
  description $textType,
  category $textType,
  date $textType,
  location $textType
)
''');

    await db.execute('''
CREATE TABLE rsvps (
  id $idType,
  eventId $integerType,
  name $textType,
  department $textType,
  grade $textType,
  timestamp $textType,
  status $textType,
  FOREIGN KEY (eventId) REFERENCES events (id) ON DELETE CASCADE
)
''');
    // Ensure all tables and seed data are populated by running upgrade logic
    await _onUpgrade(db, 0, version);
  }

  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      try {
        await db.execute('ALTER TABLE rsvps ADD COLUMN department TEXT DEFAULT ""');
      } catch (e) { /* Ignore */ }
      try {
        await db.execute('ALTER TABLE rsvps ADD COLUMN grade TEXT DEFAULT ""');
      } catch (e) { /* Ignore */ }
    }
    if (oldVersion < 3) {
      try {
        await db.execute('ALTER TABLE rsvps ADD COLUMN status TEXT DEFAULT "pending"');
      } catch (e) { /* Ignore */ }
    }
    if (oldVersion < 4) {
      await db.execute('''
        CREATE TABLE communities (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL,
          description TEXT NOT NULL,
          image TEXT
        )
      ''');
      // Seed data with REAL Uludağ University Communities
      final communities = [
        {'name': 'Yazılım ve Bilişim Topluluğu', 'desc': 'Yazılım ve teknoloji dünyasındaki gelişmeleri takip eden topluluk.'},
        {'name': 'Tiyatro Topluluğu', 'desc': 'Sahne sanatları ve tiyatro oyunları sergileyen ekip.'},
        {'name': 'Müzik Topluluğu', 'desc': 'Konserler ve müzik etkinlikleri düzenleyen topluluk.'},
        {'name': 'Fotoğrafçılık Topluluğu', 'desc': 'Fotoğraf sanatı üzerine eğitimler ve geziler.'},
        {'name': 'Robot Topluluğu', 'desc': 'Robotik sistemler ve otomasyon üzerine çalışmalar.'},
        {'name': 'Yapay Zeka Topluluğu', 'desc': 'AI ve makine öğrenmesi üzerine akademik çalışmalar.'},
        {'name': 'E-Spor Topluluğu', 'desc': 'Elektronik spor turnuvaları ve etkinlikleri.'},
        {'name': 'Dans Topluluğu', 'desc': 'Modern ve halk dansları üzerine eğitimler.'},
        {'name': 'Sinema Topluluğu', 'desc': 'Film gösterimleri ve sinema sanatı üzerine söyleşiler.'},
        {'name': 'Genç Girişimciler Topluluğu', 'desc': 'Girişimcilik ekosistemi ve kariyer etkinlikleri.'},
        {'name': 'Dağcılık Topluluğu (UDAK)', 'desc': 'Dağcılık eğitimleri, tırmanış ve doğa yürüyüşleri.'},
        {'name': 'Kızılay Topluluğu', 'desc': 'Sosyal sorumluluk ve yardımlaşma faaliyetleri.'},
        {'name': 'Havacılık Topluluğu', 'desc': 'Havacılık tarihi ve model uçak çalışmaları.'},
        {'name': 'Satranç Topluluğu', 'desc': 'Zeka oyunları ve satranç turnuvaları.'},
        {'name': 'Matematik Topluluğu', 'desc': 'Matematiksel düşünce ve bilimsel seminerler.'},
      ];

      for (var c in communities) {
        await db.insert('communities', {
          'name': c['name'],
          'description': c['desc'],
          'image': null // Using default icon for consistency
        });
      }
    }
    if (oldVersion < 5) {
       await db.delete('communities');
       final communities = [
        {'name': 'Yazılım ve Bilişim Topluluğu', 'desc': 'Yazılım ve teknoloji dünyasındaki gelişmeleri takip eden topluluk.'},
        {'name': 'Tiyatro Topluluğu', 'desc': 'Sahne sanatları ve tiyatro oyunları sergileyen ekip.'},
        {'name': 'Müzik Topluluğu', 'desc': 'Konserler ve müzik etkinlikleri düzenleyen topluluk.'},
        {'name': 'Fotoğrafçılık Topluluğu', 'desc': 'Fotoğraf sanatı üzerine eğitimler ve geziler.'},
        {'name': 'Robot Topluluğu', 'desc': 'Robotik sistemler ve otomasyon üzerine çalışmalar.'},
        {'name': 'Yapay Zeka Topluluğu', 'desc': 'AI ve makine öğrenmesi üzerine akademik çalışmalar.'},
        {'name': 'E-Spor Topluluğu', 'desc': 'Elektronik spor turnuvaları ve etkinlikleri.'},
        {'name': 'Dans Topluluğu', 'desc': 'Modern ve halk dansları üzerine eğitimler.'},
        {'name': 'Sinema Topluluğu', 'desc': 'Film gösterimleri ve sinema sanatı üzerine söyleşiler.'},
        {'name': 'Genç Girişimciler Topluluğu', 'desc': 'Girişimcilik ekosistemi ve kariyer etkinlikleri.'},
        {'name': 'Dağcılık Topluluğu (UDAK)', 'desc': 'Dağcılık eğitimleri, tırmanış ve doğa yürüyüşleri.'},
        {'name': 'Kızılay Topluluğu', 'desc': 'Sosyal sorumluluk ve yardımlaşma faaliyetleri.'},
        {'name': 'Havacılık Topluluğu', 'desc': 'Havacılık tarihi ve model uçak çalışmaları.'},
        {'name': 'Satranç Topluluğu', 'desc': 'Zeka oyunları ve satranç turnuvaları.'},
        {'name': 'Matematik Topluluğu', 'desc': 'Matematiksel düşünce ve bilimsel seminerler.'},
      ];
      for (var c in communities) {
        await db.insert('communities', {
          'name': c['name'],
          'description': c['desc'],
          'image': null
        });
      }
    }
    if (oldVersion < 6) {
      // Re-create table to add new columns (president, memberCount)
      await db.execute('DROP TABLE IF EXISTS communities');
      await db.execute('''
        CREATE TABLE communities (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL,
          description TEXT NOT NULL,
          image TEXT,
          president TEXT,
          memberCount INTEGER DEFAULT 0
        )
      ''');
      
      final communities = [
        {'name': 'Yazılım ve Bilişim Topluluğu', 'desc': 'Yazılım ve teknoloji dünyasındaki gelişmeleri takip eden topluluk.', 'pres': 'Ahmet Yılmaz', 'count': 145},
        {'name': 'Tiyatro Topluluğu', 'desc': 'Sahne sanatları ve tiyatro oyunları sergileyen ekip.', 'pres': 'Ayşe Demir', 'count': 82},
        {'name': 'Müzik Topluluğu', 'desc': 'Konserler ve müzik etkinlikleri düzenleyen topluluk.', 'pres': 'Caner Ozan', 'count': 210},
        {'name': 'Fotoğrafçılık Topluluğu', 'desc': 'Fotoğraf sanatı üzerine eğitimler ve geziler.', 'pres': 'Elif Çelik', 'count': 65},
        {'name': 'Robot Topluluğu', 'desc': 'Robotik sistemler ve otomasyon üzerine çalışmalar.', 'pres': 'Mehmet Öz', 'count': 90},
        {'name': 'Yapay Zeka Topluluğu', 'desc': 'AI ve makine öğrenmesi üzerine akademik çalışmalar.', 'pres': 'Zeynep Kaya', 'count': 120},
        {'name': 'E-Spor Topluluğu', 'desc': 'Elektronik spor turnuvaları ve etkinlikleri.', 'pres': 'Burak Şen', 'count': 300},
        {'name': 'Dans Topluluğu', 'desc': 'Modern ve halk dansları üzerine eğitimler.', 'pres': 'Selin Yurt', 'count': 75},
        {'name': 'Sinema Topluluğu', 'desc': 'Film gösterimleri ve sinema sanatı üzerine söyleşiler.', 'pres': 'Deniz Aras', 'count': 55},
        {'name': 'Genç Girişimciler Topluluğu', 'desc': 'Girişimcilik ekosistemi ve kariyer etkinlikleri.', 'pres': 'Kaan Yıldız', 'count': 110},
        {'name': 'Dağcılık Topluluğu (UDAK)', 'desc': 'Dağcılık eğitimleri, tırmanış ve doğa yürüyüşleri.', 'pres': 'Murat Dağlı', 'count': 40},
        {'name': 'Kızılay Topluluğu', 'desc': 'Sosyal sorumluluk ve yardımlaşma faaliyetleri.', 'pres': 'Fatma Nur', 'count': 180},
        {'name': 'Havacılık Topluluğu', 'desc': 'Havacılık tarihi ve model uçak çalışmaları.', 'pres': 'Emre Gök', 'count': 60},
        {'name': 'Satranç Topluluğu', 'desc': 'Zeka oyunları ve satranç turnuvaları.', 'pres': 'Ali Vural', 'count': 35},
        {'name': 'Matematik Topluluğu', 'desc': 'Matematiksel düşünce ve bilimsel seminerler.', 'pres': 'Gülşen Ece', 'count': 45},
      ];

      for (var c in communities) {
        await db.insert('communities', {
          'name': c['name'],
          'description': c['desc'],
          'image': null,
          'president': c['pres'],
          'memberCount': c['count']
        });
      }
    }
    if (oldVersion < 7) {
      // Update images for communities
      final updates = {
        'Yazılım ve Bilişim Topluluğu': 'https://cdn-icons-png.flaticon.com/512/2010/2010990.png',
        'Tiyatro Topluluğu': 'https://cdn-icons-png.flaticon.com/512/3079/3079140.png',
        'Müzik Topluluğu': 'https://cdn-icons-png.flaticon.com/512/2907/2907253.png',
        'Fotoğrafçılık Topluluğu': 'https://cdn-icons-png.flaticon.com/512/685/685655.png',
        'Robot Topluluğu': 'https://cdn-icons-png.flaticon.com/512/1693/1693746.png',
        'Yapay Zeka Topluluğu': 'https://cdn-icons-png.flaticon.com/512/1693/1693761.png',
        'E-Spor Topluluğu': 'https://cdn-icons-png.flaticon.com/512/686/686589.png',
        'Dans Topluluğu': 'https://cdn-icons-png.flaticon.com/512/2460/2460461.png',
        'Sinema Topluluğu': 'https://cdn-icons-png.flaticon.com/512/2809/2809590.png',
        'Genç Girişimciler Topluluğu': 'https://cdn-icons-png.flaticon.com/512/1553/1553979.png',
        'Dağcılık Topluluğu (UDAK)': 'https://cdn-icons-png.flaticon.com/512/2847/2847119.png',
        'Kızılay Topluluğu': 'https://cdn-icons-png.flaticon.com/512/9308/9308976.png', 
        'Havacılık Topluluğu': 'https://cdn-icons-png.flaticon.com/512/10542/10542526.png',
        'Satranç Topluluğu': 'https://cdn-icons-png.flaticon.com/512/4609/4609214.png',
        'Matematik Topluluğu': 'https://cdn-icons-png.flaticon.com/512/3067/3067332.png',
      };

      for (var entry in updates.entries) {
        await db.update(
          'communities',
          {'image': entry.value},
          where: 'name = ?',
          whereArgs: [entry.key],
        );
      }
    }
    if (oldVersion < 8) {
      await db.delete('communities');
      final allCommunities = [
        {'name': 'Yazılım ve Bilişim Topluluğu', 'desc': 'Teknoloji ve kodlama dünyası.', 'pres': 'Ahmet Yılmaz', 'count': 150},
        {'name': 'Robot Topluluğu', 'desc': 'Robotik ve otonom sistemler.', 'pres': 'Mehmet Öz', 'count': 95},
        {'name': 'Yapay Zeka Topluluğu', 'desc': 'AI ve makine öğrenmesi.', 'pres': 'Zeynep Kaya', 'count': 130},
        {'name': 'Bilim ve Doğa Topluluğu', 'desc': 'Bilimsel araştırmalar ve doğa gözlemi.', 'pres': 'Ali Vural', 'count': 45},
        {'name': 'Arkeoloji Topluluğu', 'desc': 'Kazı bilimi ve tarih.', 'pres': 'Selin Yurt', 'count': 40},
        {'name': 'Astronomi Topluluğu', 'desc': 'Uzay ve gökyüzü gözlemi.', 'pres': 'Caner Ozan', 'count': 60},
        {'name': 'Biyoloji Topluluğu', 'desc': 'Canlı bilimi ve araştırmalar.', 'pres': 'Elif Çelik', 'count': 70},
        {'name': 'Fizik Topluluğu', 'desc': 'Teorik ve uygulamalı fizik.', 'pres': 'Burak Şen', 'count': 55},
        {'name': 'Matematik Topluluğu', 'desc': 'Matematiksel düşünce.', 'pres': 'Gülşen Ece', 'count': 50},
        {'name': 'Kimya Topluluğu', 'desc': 'Laboratuvar ve kimya bilimi.', 'pres': 'Deniz Aras', 'count': 65},
        {'name': 'Otomotiv Topluluğu', 'desc': 'Araç teknolojileri ve tasarımı.', 'pres': 'Kaan Yıldız', 'count': 110},
        {'name': 'Elektrik Elektronik Müh. (IEEE)', 'desc': 'Teknoloji ve mühendislik ağı.', 'pres': 'Murat Dağlı', 'count': 200},
        {'name': 'Makina Topluluğu', 'desc': 'Makine mühendisliği ve mekanik.', 'pres': 'Emre Gök', 'count': 140},
        {'name': 'Genç Girişimciler Topluluğu', 'desc': 'Girişimcilik ve iş dünyası.', 'pres': 'Fatma Nur', 'count': 180},
        {'name': 'Altın Kepçe Topluluğu', 'desc': 'Gastronomi ve mutfak sanatları.', 'pres': 'Ayşe Demir', 'count': 90},
        {'name': 'Biyosistem Mühendisliği Top.', 'desc': 'Mühendislik ve biyolojik sistemler.', 'pres': 'Hasan Yılmaz', 'count': 55},
        {'name': 'Dünya Dilleri Topluluğu', 'desc': 'Yabancı dil ve kültürler.', 'pres': 'Pelin Can', 'count': 75},
        {'name': 'Fizyoterapi ve Rehabilitasyon', 'desc': 'Sağlık ve fizik tedavi.', 'pres': 'Onur Alp', 'count': 120},
        {'name': 'Genç Veteriner Hekimler', 'desc': 'Veteriner hekimliği ve hayvan sağlığı.', 'pres': 'Buse Naz', 'count': 100},
        {'name': 'Hukuk Topluluğu', 'desc': 'Adalet ve hukuk sistemi.', 'pres': 'Kemal Soylu', 'count': 250},
        {'name': 'İşletme Topluluğu', 'desc': 'Yönetim ve organizasyon.', 'pres': 'Leyla Şahin', 'count': 160},
        {'name': 'İnsan Kaynakları Topluluğu', 'desc': 'İK yönetimi ve kariyer.', 'pres': 'Merve Koç', 'count': 95},
        {'name': 'Uluslararası İlişkiler Top.', 'desc': 'Diplomasi ve küresel siyaset.', 'pres': 'Cem Uslu', 'count': 140},
        {'name': 'Ziraat Topluluğu', 'desc': 'Tarım ve ziraat mühendisliği.', 'pres': 'Tarık Ak', 'count': 85},
        {'name': 'Psikoloji Topluluğu', 'desc': 'İnsan psikolojisi ve davranışları.', 'pres': 'Seda Er', 'count': 210},
        {'name': 'Tiyatro Topluluğu', 'desc': 'Sahne sanatları ve oyunculuk.', 'pres': 'Okan Bayülgen (Temsili)', 'count': 85},
        {'name': 'Müzik Topluluğu', 'desc': 'Enstrüman ve koro çalışmaları.', 'pres': 'Fazıl Say (Temsili)', 'count': 220},
        {'name': 'Fotoğrafçılık Topluluğu', 'desc': 'Fotoğraf sanatı ve sergiler.', 'pres': 'Ara Güler (Temsili)', 'count': 65},
        {'name': 'Sinema Topluluğu', 'desc': 'Film analizi ve gösterimler.', 'pres': 'Nuri Bilge (Temsili)', 'count': 60},
        {'name': 'Dans Topluluğu', 'desc': 'Latin, modern ve halk dansları.', 'pres': 'Tan Sağtürk (Temsili)', 'count': 110},
        {'name': 'Kitap Topluluğu', 'desc': 'Edebiyat ve kitap okuma.', 'pres': 'Orhan Pamuk (Temsili)', 'count': 90},
        {'name': 'Resim ve Sanat Topluluğu', 'desc': 'Görsel sanatlar ve atölyeler.', 'pres': 'Bedri Rahmi (Temsili)', 'count': 50},
        {'name': 'Dağcılık Topluluğu (UDAK)', 'desc': 'Zirve tırmanışları ve kamp.', 'pres': 'Nasuh Mahruki (Temsili)', 'count': 45},
        {'name': 'E-Spor Topluluğu', 'desc': 'League of Legends, Valorant turnuvaları.', 'pres': 'Faker (Temsili)', 'count': 350},
        {'name': 'Havacılık Topluluğu', 'desc': 'Yamaç paraşütü ve model uçak.', 'pres': 'Vecihi Hürkuş (Temsili)', 'count': 70},
        {'name': 'Satranç Topluluğu', 'desc': 'Strateji ve turnuvalar.', 'pres': 'Magnus (Temsili)', 'count': 40},
        {'name': 'Bisiklet Topluluğu', 'desc': 'Kampüs içi ve dışı turlar.', 'pres': 'Lance (Temsili)', 'count': 80},
        {'name': 'Atlı Spor Topluluğu', 'desc': 'Binicilik ve at bakımı.', 'pres': 'Cemal (Temsili)', 'count': 30},
        {'name': 'Sualtı Topluluğu (USAT)', 'desc': 'Dalış ve su altı araştırmaları.', 'pres': 'Jacques (Temsili)', 'count': 55},
      ];

      for (var c in allCommunities) {
        String? image;
        if (c['name'].toString().contains('Yazılım') || c['name'].toString().contains('Robot') || c['name'].toString().contains('IEEE')) {
           image = 'https://cdn-icons-png.flaticon.com/512/2010/2010990.png'; 
        } else if (c['name'].toString().contains('Tiyatro')) {
           image = 'https://cdn-icons-png.flaticon.com/512/3079/3079140.png'; 
        } else if (c['name'].toString().contains('Müzik')) {
           image = 'https://cdn-icons-png.flaticon.com/512/2907/2907253.png'; 
        } else if (c['name'].toString().contains('Spor') || c['name'].toString().contains('Dağ') || c['name'].toString().contains('Bisiklet')) {
           image = 'https://cdn-icons-png.flaticon.com/512/2847/2847119.png'; 
        } else if (c['name'].toString().contains('Sağlık') || c['name'].toString().contains('Tıp') || c['name'].toString().contains('Fizyo')) {
           image = 'https://cdn-icons-png.flaticon.com/512/2966/2966327.png'; 
        } else if (c['name'].toString().contains('Hukuk')) {
           image = 'https://cdn-icons-png.flaticon.com/512/2643/2643503.png'; 
        } else {
           image = null; 
        }

        await db.insert('communities', {
          'name': c['name'],
          'description': c['desc'],
          'image': image, 
          'president': c['pres'],
          'memberCount': c['count']
        });
      }
    }
    if (oldVersion < 9) {
      await db.execute('DROP TABLE IF EXISTS communities');
      await db.execute('''
        CREATE TABLE communities (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL,
          description TEXT NOT NULL,
          image TEXT,
          president TEXT,
          memberCount INTEGER DEFAULT 0,
          category TEXT
        )
      ''');

      final categorizedCommunities = [
        {'cat': 'Bilim', 'name': 'Yazılım ve Bilişim Topluluğu', 'desc': 'Teknoloji ve kodlama.', 'pres': 'Ahmet Yılmaz', 'count': 150},
        {'cat': 'Bilim', 'name': 'Robot Topluluğu', 'desc': 'Robotik sistemler.', 'pres': 'Mehmet Öz', 'count': 95},
        {'cat': 'Bilim', 'name': 'Yapay Zeka Topluluğu', 'desc': 'AI çalışmaları.', 'pres': 'Zeynep Kaya', 'count': 130},
        {'cat': 'Bilim', 'name': 'Astronomi Topluluğu', 'desc': 'Uzay gözlemi.', 'pres': 'Caner Ozan', 'count': 60},
        {'cat': 'Bilim', 'name': 'Matematik Topluluğu', 'desc': 'Matematiksel düşünce.', 'pres': 'Gülşen Ece', 'count': 50},
        {'cat': 'Bilim', 'name': 'Elektrik Elektronik Müh. (IEEE)', 'desc': 'Mühendislik ağı.', 'pres': 'Murat Dağlı', 'count': 200},
        {'cat': 'Mesleki', 'name': 'Genç Girişimciler Topluluğu', 'desc': 'İş dünyası.', 'pres': 'Fatma Nur', 'count': 180},
        {'cat': 'Mesleki', 'name': 'Hukuk Topluluğu', 'desc': 'Hukuk ve adalet.', 'pres': 'Kemal Soylu', 'count': 250},
        {'cat': 'Mesleki', 'name': 'Tıp Öğrencileri Birliği', 'desc': 'Tıp eğitimi ve sosyal.', 'pres': 'Dr. Adayı Ali', 'count': 300},
        {'cat': 'Mesleki', 'name': 'Genç Veteriner Hekimler', 'desc': 'Veterinerlik.', 'pres': 'Buse Naz', 'count': 100},
        {'cat': 'Mesleki', 'name': 'Psikoloji Topluluğu', 'desc': 'Psikoloji ilmi.', 'pres': 'Seda Er', 'count': 210},
        {'cat': 'Mesleki', 'name': 'Altın Kepçe Topluluğu', 'desc': 'Gastronomi.', 'pres': 'Ayşe Demir', 'count': 90},
        {'cat': 'Kültür', 'name': 'Tiyatro Topluluğu', 'desc': 'Sahne sanatları.', 'pres': 'Okan Bayülgen', 'count': 85},
        {'cat': 'Kültür', 'name': 'Müzik Topluluğu', 'desc': 'Koro ve enstrüman.', 'pres': 'Fazıl Say', 'count': 220},
        {'cat': 'Kültür', 'name': 'Fotoğrafçılık Topluluğu', 'desc': 'Fotoğraf sanatı.', 'pres': 'Ara Güler', 'count': 65},
        {'cat': 'Kültür', 'name': 'Sinema Topluluğu', 'desc': 'Film kültürü.', 'pres': 'Nuri Bilge', 'count': 60},
        {'cat': 'Kültür', 'name': 'Dans Topluluğu', 'desc': 'Halk ve modern dans.', 'pres': 'Tan Sağtürk', 'count': 110},
        {'cat': 'Kültür', 'name': 'Resim ve Sanat Topluluğu', 'desc': 'Görsel sanatlar.', 'pres': 'Bedri Rahmi', 'count': 50},
        {'cat': 'Spor', 'name': 'Dağcılık Topluluğu (UDAK)', 'desc': 'Tırmanış ve kamp.', 'pres': 'Nasuh Mahruki', 'count': 45},
        {'cat': 'Spor', 'name': 'E-Spor Topluluğu', 'desc': 'League of Legends turnuvaları.', 'pres': 'Faker', 'count': 350},
        {'cat': 'Spor', 'name': 'Havacılık Topluluğu', 'desc': 'Yamaç paraşütü.', 'pres': 'Vecihi Hürkuş', 'count': 70},
        {'cat': 'Spor', 'name': 'Satranç Topluluğu', 'desc': 'Zeka oyunları.', 'pres': 'Magnus', 'count': 40},
        {'cat': 'Spor', 'name': 'Sualtı Topluluğu (USAT)', 'desc': 'Dalış sporu.', 'pres': 'Jacques', 'count': 55},
        {'cat': 'Spor', 'name': 'Atlı Spor Topluluğu', 'desc': 'Binicilik.', 'pres': 'Cemal', 'count': 30},
      ];

      for (var c in categorizedCommunities) {
        String? image;
        if (c['cat'] == 'Bilim') image = 'https://cdn-icons-png.flaticon.com/512/2010/2010990.png';
        if (c['cat'] == 'Mesleki') image = 'https://cdn-icons-png.flaticon.com/512/1553/1553979.png';
        if (c['cat'] == 'Kültür') image = 'https://cdn-icons-png.flaticon.com/512/3079/3079140.png';
        if (c['cat'] == 'Spor') image = 'https://cdn-icons-png.flaticon.com/512/2847/2847119.png';
        if (c['name'].toString().contains('Müzik')) image = 'https://cdn-icons-png.flaticon.com/512/2907/2907253.png';
        if (c['name'].toString().contains('E-Spor')) image = 'https://cdn-icons-png.flaticon.com/512/686/686589.png';

        await db.insert('communities', {
          'name': c['name'],
          'description': c['desc'],
          'image': image,
          'president': c['pres'],
          'memberCount': c['count'],
          'category': c['cat']
        });
      }
    }
    if (oldVersion < 10) {
      await db.delete('communities');

      final fullList = [
        {'cat': 'Kültür', 'name': 'Akademik Gelişim Topluluğu', 'desc': 'Kişisel ve akademik gelişim.', 'pres': 'Ahmet Y.', 'count': 80},
        {'cat': 'Kültür', 'name': 'Anadolu Mektebi Kültür ve Edebiyat', 'desc': 'Anadolu kültürü ve okumalar.', 'pres': 'Ayşe K.', 'count': 60},
        {'cat': 'Kültür', 'name': 'Asım Kocabıyık Yerleşkesi Tiyatro', 'desc': 'Meslek yüksekokulu tiyatro ekibi.', 'pres': 'Mehmet T.', 'count': 45},
        {'cat': 'Kültür', 'name': 'Dans Topluluğu', 'desc': 'Modern ve eşli danslar.', 'pres': 'Selin D.', 'count': 120},
        {'cat': 'Kültür', 'name': 'Diriliş Öğrenci Topluluğu', 'desc': 'Milli ve manevi değerler.', 'pres': 'Ali V.', 'count': 90},
        {'cat': 'Kültür', 'name': 'Diş Hekimleri Müzik Topluluğu', 'desc': 'Diş hekimliği öğrencilerinden müzik.', 'pres': 'Dt. Can', 'count': 55},
        {'cat': 'Kültür', 'name': 'Düşünce ve Hareket Topluluğu', 'desc': 'Fikir ve aksiyon.', 'pres': 'Burak S.', 'count': 70},
        {'cat': 'Kültür', 'name': 'Düşünce ve Medeniyet Topluluğu', 'desc': 'Medeniyet tasavvuru.', 'pres': 'Zeynep A.', 'count': 65},
        {'cat': 'Kültür', 'name': 'Erasmus Topluluğu (ESN)', 'desc': 'Değişim öğrencileri ve entegrasyon.', 'pres': 'Elif E.', 'count': 150},
        {'cat': 'Kültür', 'name': 'Fikir ve Aksiyon Topluluğu', 'desc': 'Toplumsal farkındalık.', 'pres': 'Kemal F.', 'count': 60},
        {'cat': 'Kültür', 'name': 'Fotoğraf Amatörleri Topluluğu', 'desc': 'Fotoğraf sanatı ve geziler.', 'pres': 'Ara G.', 'count': 110},
        {'cat': 'Kültür', 'name': 'Geçerken Topluluğu', 'desc': 'Edebiyat ve sanat.', 'pres': 'Yusuf G.', 'count': 50},
        {'cat': 'Kültür', 'name': 'Genç Düşünce Topluluğu', 'desc': 'Gençlik ve gelecek vizyonu.', 'pres': 'Hakan D.', 'count': 85},
        {'cat': 'Kültür', 'name': 'Genç Kalemler Topluluğu', 'desc': 'Yazarlık ve şiir.', 'pres': 'Nur K.', 'count': 75},
        {'cat': 'Kültür', 'name': 'Genç Kızılay Topluluğu', 'desc': 'İnsani yardım ve dayanışma.', 'pres': 'Fatma K.', 'count': 200},
        {'cat': 'Kültür', 'name': 'Genç Tema Topluluğu', 'desc': 'Doğa ve çevre koruma.', 'pres': 'Toprak T.', 'count': 180},
        {'cat': 'Kültür', 'name': 'Halk Oyunları Topluluğu', 'desc': 'Yöresel halk dansları.', 'pres': 'Efe H.', 'count': 130},
        {'cat': 'Kültür', 'name': 'Kızılay Topluluğu', 'desc': 'Kan bağışı ve ilk yardım.', 'pres': 'Dr. Kaan', 'count': 160},
        {'cat': 'Kültür', 'name': 'Kitap Topluluğu', 'desc': 'Kitap tahlilleri ve okuma günleri.', 'pres': 'Seda O.', 'count': 95},
        {'cat': 'Kültür', 'name': 'Mevlanayı Tanıma Ve Tanıtma', 'desc': 'Mevlana felsefesi.', 'pres': 'Can M.', 'count': 40},
        {'cat': 'Kültür', 'name': 'Mozaik Topluluğu', 'desc': 'Kültürel çeşitlilik.', 'pres': 'Deniz M.', 'count': 55},
        {'cat': 'Kültür', 'name': 'Müzik Topluluğu', 'desc': 'Üniversite orkestrası ve gruplar.', 'pres': 'Ozan M.', 'count': 250},
        {'cat': 'Kültür', 'name': 'Radyo ve Televizyon Topluluğu', 'desc': 'Yayıncılık ve medya.', 'pres': 'Pelin R.', 'count': 80},
        {'cat': 'Kültür', 'name': 'Renkli Gülücükler Topluluğu', 'desc': 'Sosyal sorumluluk projeleri.', 'pres': 'Gamze G.', 'count': 120},
        {'cat': 'Kültür', 'name': 'Sinema Topluluğu', 'desc': 'Film gösterimleri.', 'pres': 'Cem S.', 'count': 90},
        {'cat': 'Kültür', 'name': 'Tiyatro Topluluğu', 'desc': 'Üniversite tiyatro ekibi.', 'pres': 'Haluk B.', 'count': 110},
        {'cat': 'Kültür', 'name': 'Türk Dünyası ve Kültürleri', 'desc': 'Türk tarihi ve kültürü.', 'pres': 'Alp T.', 'count': 140},
        {'cat': 'Kültür', 'name': 'Yoga Topluluğu', 'desc': 'Yoga ve meditasyon.', 'pres': 'Ece Y.', 'count': 70},
        {'cat': 'Kültür', 'name': 'Yurt Dışı Eğitim ve Kültür', 'desc': 'Yurtdışı fırsatları.', 'pres': 'Mert Y.', 'count': 100},
        {'cat': 'Kültür', 'name': 'Çok Sesli Müzik Topluluğu', 'desc': 'Koro ve çok sesli müzik.', 'pres': 'Soprano S.', 'count': 60},
        {'cat': 'Mesleki', 'name': 'Adalet Topluluğu', 'desc': 'Hukuk ve adalet sistemi.', 'pres': 'Hakim A.', 'count': 110},
        {'cat': 'Mesleki', 'name': 'Altın Kepçe Topluluğu', 'desc': 'Gastronomi ve mutfak.', 'pres': 'Şef A.', 'count': 95},
        {'cat': 'Bilim', 'name': 'Arkeoloji Topluluğu', 'desc': 'Arkeolojik kazılar.', 'pres': 'Kazı B.', 'count': 50},
        {'cat': 'Bilim', 'name': 'Astronomi Topluluğu', 'desc': 'Gökyüzü gözlemi.', 'pres': 'Uzay C.', 'count': 65},
        {'cat': 'Kültür', 'name': 'Atatürkçü Düşünce Topluluğu', 'desc': 'Atatürk ilke ve inkılapları.', 'pres': 'Mustafa K.', 'count': 300},
        {'cat': 'Mesleki', 'name': 'Avrupa Tıp Öğrencileri Birliği', 'desc': 'Uluslararası tıp ağı.', 'pres': 'Dr. Emsa', 'count': 150},
        {'cat': 'Bilim', 'name': 'Bilgi Teknolojileri Topluluğu', 'desc': 'IT ve sistem yönetimi.', 'pres': 'Admin B.', 'count': 130},
        {'cat': 'Bilim', 'name': 'Bilim ve Doğa Topluluğu', 'desc': 'Doğa bilimleri.', 'pres': 'Doğa B.', 'count': 75},
        {'cat': 'Bilim', 'name': 'Bilim Teknoloji Gençleri', 'desc': 'İnovasyon ve Ar-Ge.', 'pres': 'Tekno T.', 'count': 90},
        {'cat': 'Bilim', 'name': 'Bilimsel Araştırmalar Top.', 'desc': 'Akademik araştırmalar.', 'pres': 'Prof. A.', 'count': 40},
        {'cat': 'Bilim', 'name': 'Biyoloji Topluluğu', 'desc': 'Canlı bilimi.', 'pres': 'Bio C.', 'count': 80},
        {'cat': 'Mesleki', 'name': 'Biyosistem Mühendisliği Top.', 'desc': 'Tarım ve teknoloji.', 'pres': 'Müh. B.', 'count': 60},
        {'cat': 'Bilim', 'name': 'Biyoteknoloji ve Genetik', 'desc': 'Genetik bilimleri.', 'pres': 'Gen G.', 'count': 100},
        {'cat': 'Mesleki', 'name': 'Bursa Uludağ Tıp Öğrencileri', 'desc': 'Tıp fakültesi birliği.', 'pres': 'Stj. Dr. T.', 'count': 350},
        {'cat': 'Bilim', 'name': 'Bursa Uludağ Yazılım Top.', 'desc': 'Yazılım geliştirme.', 'pres': 'Dev Y.', 'count': 220},
        {'cat': 'Kültür', 'name': 'Çevre Topluluğu', 'desc': 'Çevre bilinci.', 'pres': 'Yeşil Ç.', 'count': 110},
        {'cat': 'Kültür', 'name': 'Çiftlik Gönüllüleri Topluluğu', 'desc': 'Hayvan bakımı.', 'pres': 'Vet. Ç.', 'count': 70},
        {'cat': 'Mesleki', 'name': 'Diş Hekimi Topluluğu', 'desc': 'Diş hekimliği mesleği.', 'pres': 'Dt. D.', 'count': 140},
        {'cat': 'Bilim', 'name': 'Dijital Oyun Tasarım Top.', 'desc': 'Oyun geliştirme.', 'pres': 'Game D.', 'count': 180},
        {'cat': 'Bilim', 'name': 'Doğa Gözlem Topluluğu', 'desc': 'Kuş ve doğa gözlemi.', 'pres': 'Gözlem G.', 'count': 55},
        {'cat': 'Kültür', 'name': 'Dünya Dilleri Topluluğu', 'desc': 'Yabancı diller.', 'pres': 'Polyglot D.', 'count': 85},
        {'cat': 'Mesleki', 'name': 'Ekonometri Topluluğu', 'desc': 'İstatistik ve ekonomi.', 'pres': 'Eko E.', 'count': 90},
        {'cat': 'Bilim', 'name': 'Elektrik-Elektronik Müh. Top.', 'desc': 'EEM öğrencileri.', 'pres': 'Müh. E.', 'count': 230},
        {'cat': 'Bilim', 'name': 'Elektronik Mühendisliği Top.', 'desc': 'Devre ve sistemler.', 'pres': 'Müh. El.', 'count': 120},
        {'cat': 'Bilim', 'name': 'Elektromobil Topluluğu', 'desc': 'Elektrikli araçlar.', 'pres': 'Tesla E.', 'count': 100},
        {'cat': 'Mesleki', 'name': 'Endüstri Mühendisliği Top.', 'desc': 'Verimlilik ve yönetim.', 'pres': 'End. M.', 'count': 210},
        {'cat': 'Mesleki', 'name': 'Entellektüel Tıp Topluluğu', 'desc': 'Tıp ve felsefe.', 'pres': 'Dr. F.', 'count': 60},
        {'cat': 'Mesleki', 'name': 'Evrensel Sağlık Topluluğu', 'desc': 'Global sağlık.', 'pres': 'Health E.', 'count': 90},
        {'cat': 'Kültür', 'name': 'Felsefe Topluluğu', 'desc': 'Düşünce tarihi.', 'pres': 'Sokrates F.', 'count': 50},
        {'cat': 'Bilim', 'name': 'Fizik Topluluğu', 'desc': 'Fizik bilimi.', 'pres': 'Newton F.', 'count': 55},
        {'cat': 'Mesleki', 'name': 'Fizyoterapi ve Rehabilitasyon', 'desc': 'FTR öğrencileri.', 'pres': 'Fzt. R.', 'count': 130},
        {'cat': 'Mesleki', 'name': 'Futuristik Tıp Topluluğu', 'desc': 'Geleceğin tıbbı.', 'pres': 'Future T.', 'count': 75},
        {'cat': 'Mesleki', 'name': 'Geleneksel ve Tamamlayıcı Tıp', 'desc': 'Alternatif tıp.', 'pres': 'Dr. G.', 'count': 65},
        {'cat': 'Mesleki', 'name': 'Gemlik Denizcilik Topluluğu', 'desc': 'Denizcilik mesleği.', 'pres': 'Kaptan G.', 'count': 80},
        {'cat': 'Bilim', 'name': 'Genç Coğrafyacılar Topluluğu', 'desc': 'Coğrafya bilimi.', 'pres': 'Geo G.', 'count': 60},
        {'cat': 'Mesleki', 'name': 'Genç Eğitimciler Topluluğu', 'desc': 'Öğretmen adayları.', 'pres': 'Muallim E.', 'count': 150},
        {'cat': 'Bilim', 'name': 'Genç Fizikçiler Topluluğu', 'desc': 'Amatör fizikçiler.', 'pres': 'Einstein G.', 'count': 45},
        {'cat': 'Mesleki', 'name': 'Genç Girişimciler Topluluğu', 'desc': 'Startup ekosistemi.', 'pres': 'Elon G.', 'count': 200},
        {'cat': 'Mesleki', 'name': 'Genç Mühendisler Topluluğu', 'desc': 'Mühendislik projeleri.', 'pres': 'Müh. G.', 'count': 180},
        {'cat': 'Mesleki', 'name': 'Genç Veteriner Hekimler', 'desc': 'Veteriner adayları.', 'pres': 'Vet. H.', 'count': 160},
        {'cat': 'Bilim', 'name': 'GENIN Yenilikçi Nesil Top.', 'desc': 'İnovasyon.', 'pres': 'İno Y.', 'count': 70},
        {'cat': 'Mesleki', 'name': 'Gıda Topluluğu', 'desc': 'Gıda mühendisliği.', 'pres': 'Chef G.', 'count': 100},
        {'cat': 'Spor', 'name': 'Havacılık Topluluğu', 'desc': 'Model uçak ve paraşüt.', 'pres': 'Pilot H.', 'count': 90},
        {'cat': 'Mesleki', 'name': 'Hür Eğitimciler Topluluğu', 'desc': 'Özgür eğitim.', 'pres': 'Hür E.', 'count': 55},
        {'cat': 'Bilim', 'name': 'IEEE Öğrenci Topluluğu', 'desc': 'Teknoloji liderliği.', 'pres': 'Başkan I.', 'count': 300},
        {'cat': 'Mesleki', 'name': 'İktisat Topluluğu', 'desc': 'Ekonomi.', 'pres': 'Eko İ.', 'count': 120},
        {'cat': 'Mesleki', 'name': 'İlahiyat Akademi Topluluğu', 'desc': 'İlahiyat çalışmaları.', 'pres': 'Akademik İ.', 'count': 140},
        {'cat': 'Mesleki', 'name': 'İnsan Kaynakları Topluluğu', 'desc': 'HR yönetimi.', 'pres': 'İK Müdürü', 'count': 110},
        {'cat': 'Mesleki', 'name': 'İşletme Topluluğu', 'desc': 'Business management.', 'pres': 'CEO Adayı', 'count': 190},
        {'cat': 'Bilim', 'name': 'Kafkasya Bilimsel Araştırma', 'desc': 'Kafkasya çalışmaları.', 'pres': 'Kafkas K.', 'count': 40},
        {'cat': 'Mesleki', 'name': 'Kalite Elçileri Topluluğu', 'desc': 'Kalite yönetimi.', 'pres': 'Kalite K.', 'count': 60},
        {'cat': 'Mesleki', 'name': 'Kamu Yönetimi Topluluğu', 'desc': 'İdare ve siyaset.', 'pres': 'Vali Adayı', 'count': 130},
        {'cat': 'Bilim', 'name': 'Kimya Topluluğu', 'desc': 'Kimya bilimi.', 'pres': 'Kimyager K.', 'count': 85},
        {'cat': 'Kültür', 'name': 'Kurgusal Evren Topluluğu', 'desc': 'Fantastik kurgu.', 'pres': 'Gandalf K.', 'count': 95},
        {'cat': 'Mesleki', 'name': 'Makina Topluluğu', 'desc': 'Makine mühendisliği.', 'pres': 'Müh. M.', 'count': 240},
        {'cat': 'Mesleki', 'name': 'Maliye Topluluğu', 'desc': 'Finans ve maliye.', 'pres': 'Mali M.', 'count': 115},
        {'cat': 'Bilim', 'name': 'Matematik Topluluğu', 'desc': 'Matematik.', 'pres': 'Euler M.', 'count': 70},
        {'cat': 'Bilim', 'name': 'Mobilite ve İnovasyon Top.', 'desc': 'Ulaşım teknolojileri.', 'pres': 'Mobil M.', 'count': 80},
        {'cat': 'Bilim', 'name': 'Moleküler Biyoloji ve Genetik', 'desc': 'MBG öğrencileri.', 'pres': 'Genetik M.', 'count': 125},
        {'cat': 'Bilim', 'name': 'Otomotiv Topluluğu', 'desc': 'Otomotiv teknolojileri.', 'pres': 'Oto O.', 'count': 160},
        {'cat': 'Bilim', 'name': 'Otonom Sistemler Geliştirme', 'desc': 'İHA ve SİHA.', 'pres': 'Drone O.', 'count': 110},
        {'cat': 'Mesleki', 'name': 'Psikoloji Topluluğu', 'desc': 'Psikoloji öğrencileri.', 'pres': 'Psikolog P.', 'count': 220},
        {'cat': 'Mesleki', 'name': 'PDR Topluluğu', 'desc': 'Rehberlik ve danışmanlık.', 'pres': 'PDR P.', 'count': 180},
        {'cat': 'Bilim', 'name': 'Robot Topluluğu', 'desc': 'Robotik yarışmalar.', 'pres': 'Robot R.', 'count': 145},
        {'cat': 'Mesleki', 'name': 'Sağlık ve Etik Düşünce', 'desc': 'Sağlık etiği.', 'pres': 'Etik S.', 'count': 70},
        {'cat': 'Kültür', 'name': 'Sanat Tarihi Topluluğu', 'desc': 'Sanat tarihi incelemeleri.', 'pres': 'Sanat S.', 'count': 50},
        {'cat': 'Mesleki', 'name': 'Siyaset Bilimi Topluluğu', 'desc': 'Politika.', 'pres': 'Siyaset S.', 'count': 100},
        {'cat': 'Mesleki', 'name': 'Sosyoloji Topluluğu', 'desc': 'Toplum bilimi.', 'pres': 'Sosyolog S.', 'count': 90},
        {'cat': 'Bilim', 'name': 'Sürdürülebilirlik Topluluğu', 'desc': 'Yeşil gelecek.', 'pres': 'Doğa S.', 'count': 85},
        {'cat': 'Mesleki', 'name': 'Süt Topluluğu', 'desc': 'Süt teknolojisi.', 'pres': 'Süt S.', 'count': 40},
        {'cat': 'Kültür', 'name': 'Tarih ve Kültür Topluluğu', 'desc': 'Tarih araştırmaları.', 'pres': 'Tarih T.', 'count': 80},
        {'cat': 'Mesleki', 'name': 'Tekstil Mühendisliği Top.', 'desc': 'Tekstil teknolojileri.', 'pres': 'Moda T.', 'count': 130},
        {'cat': 'Mesleki', 'name': 'Temyiz Topluluğu', 'desc': 'Hukuk münazaraları.', 'pres': 'Av. T.', 'count': 60},
        {'cat': 'Mesleki', 'name': 'Turizm Elçileri Topluluğu', 'desc': 'Turizm ve tanıtım.', 'pres': 'Rehber T.', 'count': 100},
        {'cat': 'Mesleki', 'name': 'Türk Tıp Öğrencileri Top.', 'desc': 'Ulusal tıp birliği.', 'pres': 'Dr. Turk', 'count': 200},
        {'cat': 'Mesleki', 'name': 'Türkçe Eğitimi Topluluğu', 'desc': 'Türkçe öğretmenliği.', 'pres': 'Öğrt. T.', 'count': 110},
        {'cat': 'Mesleki', 'name': 'Uludağ Diş Hekimliği Top.', 'desc': 'Diş hekimliği.', 'pres': 'Dt. U.', 'count': 150},
        {'cat': 'Mesleki', 'name': 'Uludağ Hukuk Topluluğu', 'desc': 'Hukuk fakültesi.', 'pres': 'Hukuk U.', 'count': 260},
        {'cat': 'Mesleki', 'name': 'Uludağ Teknofest Topluluğu', 'desc': 'Teknofest projeleri.', 'pres': 'Tekno U.', 'count': 190},
        {'cat': 'Mesleki', 'name': 'Uluslararası Doktorlar (AID)', 'desc': 'Gönüllü doktorlar.', 'pres': 'Dr. AID', 'count': 80},
        {'cat': 'Mesleki', 'name': 'Uluslararası İlahiyatçılar', 'desc': 'Global ilahiyat.', 'pres': 'İlahiyat U.', 'count': 70},
        {'cat': 'Mesleki', 'name': 'Uluslararası İlişkiler Top.', 'desc': 'Diplomasi.', 'pres': 'Diplomat U.', 'count': 160},
        {'cat': 'Kültür', 'name': 'Uluslararası Öğrenci Top.', 'desc': 'Misafir öğrenciler.', 'pres': 'Global U.', 'count': 250},
        {'cat': 'Bilim', 'name': 'Ulujen Yenilenebilir Enerji', 'desc': 'Temiz enerji.', 'pres': 'Enerji U.', 'count': 85},
        {'cat': 'Bilim', 'name': 'Veri Bilimi Topluluğu', 'desc': 'Data science.', 'pres': 'Data V.', 'count': 140},
        {'cat': 'Mesleki', 'name': 'Veteriner Topluluğu', 'desc': 'Hayvan sağlığı.', 'pres': 'Vet. V.', 'count': 170},
        {'cat': 'Bilim', 'name': 'Yapay Zeka Topluluğu', 'desc': 'Yapay zeka teknolojileri.', 'pres': 'AI Y.', 'count': 210},
        {'cat': 'Bilim', 'name': 'Yazılım Topluluğu', 'desc': 'Bilgisayar ve yazılım.', 'pres': 'Soft Y.', 'count': 300},
        {'cat': 'Mesleki', 'name': 'Zeytin Topluluğu', 'desc': 'Zeytincilik.', 'pres': 'Zeytin Z.', 'count': 35},
        {'cat': 'Mesleki', 'name': 'Ziraat Topluluğu', 'desc': 'Tarım bilimi.', 'pres': 'Ziraat Z.', 'count': 120},
        {'cat': 'Spor', 'name': 'Amatör Balıkçılık Topluluğu', 'desc': 'Olta balıkçılığı.', 'pres': 'Balıkçı A.', 'count': 45},
        {'cat': 'Spor', 'name': 'Atlı Spor Topluluğu', 'desc': 'Binicilik sporu.', 'pres': 'Jokey A.', 'count': 60},
        {'cat': 'Spor', 'name': 'Basketbol Topluluğu', 'desc': 'Basketbol takımı.', 'pres': 'Coach B.', 'count': 80},
        {'cat': 'Spor', 'name': 'Bisiklet Topluluğu', 'desc': 'Bisiklet turları.', 'pres': 'Pedal B.', 'count': 110},
        {'cat': 'Spor', 'name': 'Briç Topluluğu', 'desc': 'Zeka ve strateji.', 'pres': 'Briç B.', 'count': 40},
        {'cat': 'Spor', 'name': 'Dağcılık Topluluğu (UDAK)', 'desc': 'Zirve tırmanışı.', 'pres': 'Dağ D.', 'count': 75},
        {'cat': 'Spor', 'name': 'Motorsporları Topluluğu', 'desc': 'Yarış ve hız.', 'pres': 'Racer M.', 'count': 95},
        {'cat': 'Spor', 'name': 'Su Altı Topluluğu (USAT)', 'desc': 'Scuba diving.', 'pres': 'Diver S.', 'count': 65},
        {'cat': 'Spor', 'name': 'Uludağ Oryantiring Topluluğu', 'desc': 'Yön bulma sporu.', 'pres': 'Compass U.', 'count': 50},
        {'cat': 'Spor', 'name': 'Voleybol Topluluğu', 'desc': 'Voleybol takımı.', 'pres': 'Smash V.', 'count': 85},
      ];

      for (var c in fullList) {
        String? image;
        if (c['cat'] == 'Bilim') image = 'https://cdn-icons-png.flaticon.com/512/2010/2010990.png';
        if (c['cat'] == 'Mesleki') image = 'https://cdn-icons-png.flaticon.com/512/1553/1553979.png';
        if (c['cat'] == 'Kültür') image = 'https://cdn-icons-png.flaticon.com/512/3079/3079140.png';
        if (c['cat'] == 'Spor') image = 'https://cdn-icons-png.flaticon.com/512/2847/2847119.png';
        if (c['name'].toString().contains('Müzik')) image = 'https://cdn-icons-png.flaticon.com/512/2907/2907253.png';
        if (c['name'].toString().contains('E-Spor')) image = 'https://cdn-icons-png.flaticon.com/512/686/686589.png';

        await db.insert('communities', {
          'name': c['name'],
          'description': c['desc'],
          'image': image,
          'president': c['pres'],
          'memberCount': c['count'],
          'category': c['cat']
        });
      }
    }
    if (oldVersion < 11) {
      final missingCommunities = [
        {'cat': 'Bilim', 'name': 'Yönetim Bilişim Sistemleri Topluluğu', 'desc': 'Teknoloji, bilişim ve yönetim süreçleri.', 'pres': 'Selim Gök', 'count': 120},
        {'cat': 'Mesleki', 'name': 'Uluslararası Ticaret Topluluğu', 'desc': 'Küresel ticaret, lojistik ve ekonomi.', 'pres': 'Sabri Can Sever', 'count': 110},
      ];

      for (var c in missingCommunities) {
        String? image;
        if (c['cat'] == 'Bilim') image = 'https://cdn-icons-png.flaticon.com/512/3094/3094918.png';
        if (c['cat'] == 'Mesleki') image = 'https://cdn-icons-png.flaticon.com/512/2230/2230460.png';

        await db.insert('communities', {
          'name': c['name'],
          'description': c['desc'],
          'image': image,
          'president': c['pres'],
          'memberCount': c['count'],
          'category': c['cat']
        });
      }
    }
    if (oldVersion < 12) {
      // Version 12: Add communityName to events and update YBS member count
      await db.execute('ALTER TABLE events ADD COLUMN communityName TEXT');
      
      // Update YBS Member Count
      await db.update(
        'communities', 
        {'memberCount': 477}, 
        where: 'name = ?', 
        whereArgs: ['Yönetim Bilişim Sistemleri Topluluğu']
      );
    }
    if (oldVersion < 13) {
      // Version 13: Fix missing status column
      try {
        await db.execute("ALTER TABLE events ADD COLUMN status TEXT DEFAULT 'pending'");
      } catch (e) {
        // Column might already exist if previously attempted
        debugPrint('Error adding status column: $e');
      }
      }
    if (oldVersion < 14) {
      // Version 14: Update logos and UT community details
      
      // Update YBS Logo
      await db.update(
        'communities',
        {'image': 'assets/ybs_logo.jpg'},
        where: 'name = ?',
        whereArgs: ['Yönetim Bilişim Sistemleri Topluluğu'],
      );

      // Update UT Logo and Details
      await db.update(
        'communities',
        {
          'image': 'assets/ut_logo.png',
          'president': 'Berra Kan',
          'memberCount': 441,
        },
        where: 'name = ?',
        whereArgs: ['Uluslararası Ticaret Topluluğu'],
      );

      // Set default logo for others (excluding YBS and UT)
      // Note: We use a raw query to handle the NOT IN clause effectively or just update all where image is NULL or not one of the above.
      // But simpler: Update all others to logo.png if they don't have a specific one. 
      // Actually, plan said "assign 'Uludağ University' logo to all other communities".
      // Let's do a bulk update excluding the two we just set.
      
      await db.rawUpdate('''
        UPDATE communities 
        SET image = 'assets/logo.png' 
        WHERE name NOT IN ('Yönetim Bilişim Sistemleri Topluluğu', 'Uluslararası Ticaret Topluluğu')
      ''');
    }
    if (oldVersion < 15) {
      await db.update(
        'communities', 
        {'image': 'assets/images/ybs_logo.jpg'}, 
        where: 'name LIKE ?', 
        whereArgs: ['%Yönetim Bilişim%']
      );
    }
    if (oldVersion < 16) {
      await db.update(
        'communities', 
        {
          'image': 'assets/images/ut_logo.png',
          'president': 'Berra Kan'
        }, 
        where: 'name LIKE ?', 
        whereArgs: ['%Uluslararası Ticaret%']
      );
    }
    if (oldVersion < 17) {
      // Version 17: Memberships and News tables
      
      // Membership Table
      await db.execute('''
        CREATE TABLE memberships (
          student_number TEXT PRIMARY KEY,
          student_name TEXT,
          community_id INTEGER,
          join_date TEXT,
          FOREIGN KEY (community_id) REFERENCES communities (id) ON DELETE CASCADE
        )
      ''');

      // News Table
      await db.execute('''
        CREATE TABLE news (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          title TEXT,
          summary TEXT,
          source TEXT,
          date TEXT,
          imageUrl TEXT
        )
      ''');
       
       // Seed News Data
       final mockNews = [
        {
          'title': 'Bahar Şenlikleri Başlıyor!',
          'summary': 'Bu yılki bahar şenlikleri 20-25 Mayıs tarihleri arasında kampüsümüzde gerçekleşecek. Ünlü sanatçılar ve sürpriz etkinlikler sizleri bekliyor.',
          'source': 'Rektörlük',
          'date': DateTime.now().toIso8601String(),
          'imageUrl': 'https://cdn-icons-png.flaticon.com/512/3135/3135715.png' 
        },
        {
          'title': 'Kütüphane Çalışma Saatleri Güncellendi',
          'summary': 'Final haftası boyunca merkez kütüphanemiz 7/24 hizmet verecektir. Öğrencilerimize başarılar dileriz.',
          'source': 'Kütüphane Daire Bşk.',
          'date': DateTime.now().subtract(const Duration(days: 1)).toIso8601String(),
          'imageUrl': 'https://cdn-icons-png.flaticon.com/512/2232/2232688.png' 
        },
        {
          'title': 'Teknofest Başvuruları Başladı',
          'summary': 'Milli Teknoloji Hamlesi heyecanı başlıyor! Projelerini hazırla, takımı kur ve yarışmaya katıl.',
          'source': 'T3 Vakfı',
          'date': DateTime.now().subtract(const Duration(days: 2)).toIso8601String(),
          'imageUrl': 'https://cdn-icons-png.flaticon.com/512/2010/2010990.png' 
        },
        {
          'title': 'Yemekhane Menüleri Mobil Uygulamada',
          'summary': 'Artık haftalık yemek listesine mobil uygulamamız üzerinden kolayca erişebilirsiniz.',
          'source': 'SKS',
          'date': DateTime.now().subtract(const Duration(days: 5)).toIso8601String(),
          'imageUrl': 'https://cdn-icons-png.flaticon.com/512/1046/1046784.png' 
        }
      ];

      for (var news in mockNews) {
        await db.insert('news', news);
      }
    }
    if (oldVersion < 18) {
      // Version 18: Add admin credentials to communities
      try {
        await db.execute('ALTER TABLE communities ADD COLUMN admin_username TEXT');
        await db.execute('ALTER TABLE communities ADD COLUMN admin_password TEXT');
      } catch (e) { /* Ignore if exists */ }
      
      // Migrate existing hardcoded admin 'selim' to 'Yönetim Bilişim Sistemleri Topluluğu'
      await db.update(
        'communities',
        {
          'admin_username': 'selim',
          'admin_password': '1907'
        },
        where: 'name LIKE ?',
        whereArgs: ['%Yönetim Bilişim%']
      );
    }
  }

  Future<Event> createEvent(Event event) async {
    final db = await instance.database;
    await db.insert('events', {
      'title': event.title,
      'description': event.description,
      'category': event.category,
      'date': event.date.toIso8601String(),
      'location': event.location,
      'status': event.status ?? 'pending',
      'communityName': event.communityName, 
    });
    return event; 
  }

  Future<Event> readEvent(int id) async {
    final db = await instance.database;
    final maps = await db.query(
      'events',
      columns: ['id', 'title', 'description', 'category', 'date', 'location', 'status', 'communityName'], 
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Event.fromMap(maps.first);
    } else {
      throw Exception('ID $id not found');
    }
  }

  Future<List<Event>> readAllEvents() async {
    final db = await instance.database;
    final result = await db.query('events', orderBy: 'date DESC');
    return result.map((json) => Event.fromMap(json)).toList();
  }

  Future<int> updateEvent(Event event) async {
    final db = await instance.database;
    return db.update(
      'events',
      {
        'title': event.title,
        'description': event.description,
        'category': event.category,
        'date': event.date.toIso8601String(),
        'location': event.location,
        'status': event.status,
        'communityName': event.communityName, 
      },
      where: 'id = ?',
      whereArgs: [event.id],
    );
  }

  Future<int> deleteEvent(int id) async {
    final db = await instance.database;
    return await db.delete(
      'events',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<Rsvp> createRsvp(Rsvp rsvp) async {
    final db = await instance.database;
    final id = await db.insert('rsvps', rsvp.toMap());
    return Rsvp(
      id: id,
      eventId: rsvp.eventId,
      name: rsvp.name,
      department: rsvp.department,
      grade: rsvp.grade,
      timestamp: rsvp.timestamp,
      status: rsvp.status,
    );
  }

  Future<List<Rsvp>> readRsvpsForEvent(int eventId) async {
    final db = await instance.database;
    final result = await db.query(
      'rsvps',
      where: 'eventId = ?',
      whereArgs: [eventId],
    );
    return result.map((json) => Rsvp.fromMap(json)).toList();
  }

  Future<List<Rsvp>> readAllRsvps() async {
    final db = await instance.database;
    final result = await db.query('rsvps');
    return result.map((json) => Rsvp.fromMap(json)).toList();
  }

  Future<int> deleteRsvp(int id) async {
    final db = await instance.database;
    return await db.delete(
      'rsvps',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> updateRsvpStatus(int id, String status) async {
    final db = await instance.database;
    return await db.update(
      'rsvps',
      {'status': status},
      where: 'id = ?',
      whereArgs: [id],
    );
  }
  
  Future<List<Map<String, dynamic>>> readConfirmedRsvpsForStudent(String studentName) async {
    final db = await instance.database;
    // Join rsvps and events to get full details
    // Assuming 'name' in rsvps matches the student's username
    // We want events where user has 'confirmed' RSVP
    final result = await db.rawQuery('''
      SELECT e.*, r.status as rsvp_status
      FROM events e
      INNER JOIN rsvps r ON e.id = r.eventId
      WHERE r.name = ? AND r.status = 'confirmed'
      ORDER BY e.date ASC
    ''', [studentName]);
    
    return result;
  }
  
  Future<List<Community>> readAllCommunities() async {
    final db = await instance.database;
    final result = await db.query('communities');
    return result.map((json) => Community.fromMap(json)).toList();
  }

  // --- Membership Methods ---
  Future<int> addMembership(String studentNumber, String studentName, int communityId) async {
    final db = await instance.database;
    return await db.insert('memberships', {
      'student_number': studentNumber,
      'student_name': studentName,
      'community_id': communityId,
      'join_date': DateTime.now().toIso8601String(),
    });
  }

  Future<Map<String, dynamic>?> getMembership(String studentNumber) async {
    final db = await instance.database;
    final maps = await db.query(
      'memberships',
      where: 'student_number = ?',
      whereArgs: [studentNumber],
    );
    if (maps.isNotEmpty) {
      return maps.first;
    }
    return null;
  }
  
  Future<int> deleteMembership(String studentNumber) async {
    final db = await instance.database;
    return await db.delete(
      'memberships',
      where: 'student_number = ?',
      whereArgs: [studentNumber],
    );
  }
  
  // --- News Methods ---
  Future<void> syncNews(List<Map<String, dynamic>> newsList) async {
    final db = await instance.database;
    await db.transaction((txn) async {
      await txn.delete('news'); // Clear old cache
      for (var news in newsList) {
        await txn.insert('news', news);
      }
    });
  }

  Future<List<Map<String, dynamic>>> readAllNews() async {
    final db = await instance.database;
    return await db.query('news', orderBy: 'id DESC');
  }

  // --- Admin Methods ---
  
  // Get all communities that don't have an admin yet (or all, if we allow overwriting/multiple admins? 
  // Requirement implies assigning an admin *to* a community. Let's return all, but UI can show status.
  Future<List<Community>> readCommunitiesForRegistration() async {
    final db = await instance.database;
    final result = await db.query('communities', orderBy: 'name ASC');
    return result.map((json) => Community.fromMap(json)).toList();
  }

  Future<bool> registerAdmin(int communityId, String username, String password) async {
    final db = await instance.database;
    
    // Check if username already exists
    final result = await db.query(
      'communities',
      where: 'admin_username = ?',
      whereArgs: [username],
    );
    
    if (result.isNotEmpty) {
      return false; // Username taken
    }

    final count = await db.update(
      'communities',
      {
        'admin_username': username,
        'admin_password': password,
      },
      where: 'id = ?',
      whereArgs: [communityId],
    );
    return count > 0;
  }

  Future<Community?> checkAdminLogin(String username, String password) async {
    final db = await instance.database;
    final result = await db.query(
      'communities',
      where: 'admin_username = ? AND admin_password = ?',
      whereArgs: [username, password],
    );

    if (result.isNotEmpty) {
      return Community.fromMap(result.first);
    }
    return null;
  }
}
