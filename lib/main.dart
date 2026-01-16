import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:derss1/database_helper.dart';
import 'package:derss1/screens/home_screen.dart';
import 'package:derss1/screens/add_event_screen.dart';
import 'package:derss1/screens/reports_screen.dart';
import 'package:derss1/screens/login_screen.dart';
import 'package:derss1/screens/role_selection_screen.dart';
import 'package:derss1/models/user_role.dart';
import 'package:derss1/screens/event_detail_screen.dart';
import 'package:derss1/screens/communities_screen.dart';

import 'package:derss1/services/notification_service.dart';

import 'package:intl/date_symbol_data_local.dart';

import 'dart:io';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  if (Platform.isWindows || Platform.isLinux) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  await initializeDateFormatting('tr', null);
  await DatabaseHelper.instance.database; // Initialize DB
  await NotificationService().init(); // Initialize Notifications
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Topluluk Otomasyonu',
      debugShowCheckedModeBanner: false,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('tr', 'TR'),
      ],
      theme: ThemeData(
        brightness: Brightness.light,
        primaryColor: const Color(0xFF1A237E), // Navy Blue
        scaffoldBackgroundColor: Colors.white,
        cardColor: Colors.white,
        colorScheme: const ColorScheme.light(
          primary: Color(0xFF1A237E),
          secondary: Color(0xFF283593),
          surface: Colors.white,

          onPrimary: Colors.white,
          onSecondary: Colors.white,
          onSurface: Colors.black87,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1A237E),
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          iconTheme: IconThemeData(color: Colors.white),
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Color(0xFF1A237E),
          foregroundColor: Colors.white,
          elevation: 4,
        ),
        cardTheme: const CardThemeData(
          color: Colors.white,
          elevation: 4,
          margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF1A237E),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFFF3F4F6), // Greyish White
          hintStyle: TextStyle(color: Colors.grey.shade600),
          labelStyle: const TextStyle(color: Color(0xFF1A237E)),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF1A237E), width: 2),
          ),
          contentPadding: const EdgeInsets.all(20),
        ),
        useMaterial3: true,
      ),
      initialRoute: '/home',
      routes: {
        '/home': (context) => const RoleSelectionScreen(),
        '/login': (context) => const LoginScreen(),
        '/communities': (context) => const CommunitiesScreen(),
        '/events': (context) {
          final args = ModalRoute.of(context)?.settings.arguments;
          UserRole role = UserRole.admin;
          String? username;
          String? studentNumber;
          
          if (args is Map) {
            role = args['role'] as UserRole;
            username = args['username'] as String?;
            studentNumber = args['studentNumber'] as String?;
          } else if (args is UserRole) {
            role = args;
          }
          
          return HomeScreen(userRole: role, username: username, studentNumber: studentNumber);
        },
        '/add_event': (context) => const AddEventScreen(),
        '/reports': (context) => const ReportsScreen(),
        '/event_detail': (context) => const EventDetailScreen(),
      },
    );
  }
}
