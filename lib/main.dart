import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:firebase_core/firebase_core.dart';
import 'splash_screen.dart';
import 'login_screen.dart';
import 'main_screen.dart';
import 'userflow-main_screen.dart';
import 'app_data.dart';
import 'notification_service.dart';

List<CameraDescription> cameras = [];

Future<void> main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();
    
    // 1. Initialize Firebase
    await Firebase.initializeApp();
    
    // 2. Initialize Notification Service
    await NotificationService().init();
    
    // 3. Initialize Camera & Data
    cameras = await availableCameras();
    await AppData().loadData();
    
  } catch (e) {
    debugPrint('Initialization Error: $e');
  }
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AppData(),
      builder: (context, child) {
        final isDark = AppData().isDarkMode;
        
        return MaterialApp(
          title: 'Plant Classification System',
          debugShowCheckedModeBanner: false,
          themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
          
          scrollBehavior: const MaterialScrollBehavior().copyWith(
            physics: const BouncingScrollPhysics(),
          ),

          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF0D7A57),
              brightness: Brightness.light,
              primary: const Color(0xFF0D7A57),
              surface: const Color(0xFFFBFDFB),
            ),
            useMaterial3: true,
            fontFamily: 'Roboto',
            scaffoldBackgroundColor: const Color(0xFFF5F7F6),
            
            // Modern Global Input Style
            inputDecorationTheme: InputDecorationTheme(
              filled: true,
              fillColor: const Color(0xFFE8ECEB),
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: Color(0xFF0D7A57), width: 1.5),
              ),
              hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 14),
            ),

            cardTheme: CardThemeData(
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              color: Colors.white,
            ),
            appBarTheme: const AppBarTheme(
              backgroundColor: Colors.transparent,
              elevation: 0,
              centerTitle: true,
            ),
            pageTransitionsTheme: const PageTransitionsTheme(
              builders: {
                TargetPlatform.android: CupertinoPageTransitionsBuilder(),
                TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
              },
            ),
          ),

          darkTheme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF0D7A57),
              brightness: Brightness.dark,
              surface: const Color(0xFF121212),
            ),
            useMaterial3: true,
            fontFamily: 'Roboto',
            scaffoldBackgroundColor: const Color(0xFF0A0A0A),
            
            // Modern Dark Input Style
            inputDecorationTheme: InputDecorationTheme(
              filled: true,
              fillColor: Colors.white.withAlpha(8),
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: Colors.greenAccent, width: 1.5),
              ),
              hintStyle: TextStyle(color: Colors.white30, fontSize: 14),
            ),

            cardTheme: CardThemeData(
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              color: const Color(0xFF1E1E1E),
            ),
            pageTransitionsTheme: const PageTransitionsTheme(
              builders: {
                TargetPlatform.android: CupertinoPageTransitionsBuilder(),
                TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
              },
            ),
          ),
          
          home: const SplashScreen(),
          routes: {
            '/login': (context) => const LoginScreen(),
            '/main': (context) => const MainScreen(),
            '/main_employee': (context) => const MainScreenEmployee(),
          },
        );
      },
    );
  }
}
