import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import 'screens/version_gallery.dart';

void main() => runApp(const NeonTimelineExampleApp());

class NeonTimelineExampleApp extends StatelessWidget {
  const NeonTimelineExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    const seed = Color(0xFF625BF6);
    final scheme = ColorScheme.fromSeed(
      seedColor: seed,
      brightness: Brightness.light,
      surface: const Color(0xFFFFFFFF),
    );

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Neon Timeline Flutter · Version Gallery',
      scrollBehavior: const _ExampleScrollBehavior(),
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorScheme: scheme,
        scaffoldBackgroundColor: const Color(0xFFF5F7FB),
        visualDensity: VisualDensity.standard,
        splashFactory: InkSparkle.splashFactory,
        appBarTheme: const AppBarTheme(
          centerTitle: false,
          elevation: 0,
          scrolledUnderElevation: 0,
          backgroundColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
          titleTextStyle: TextStyle(
            color: Color(0xFF111827),
            fontSize: 18,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.35,
          ),
        ),
        cardTheme: CardThemeData(
          elevation: 0,
          color: Colors.white,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
            side: const BorderSide(color: Color(0xFFE8ECF3)),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          hintStyle: const TextStyle(
            color: Color(0xFF8A94A6),
            fontWeight: FontWeight.w600,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: const BorderSide(color: Color(0xFFE4E9F2)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: const BorderSide(color: Color(0xFFE4E9F2)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: const BorderSide(color: seed, width: 1.6),
          ),
        ),
        textTheme: const TextTheme(
          headlineLarge: TextStyle(
            color: Color(0xFF101828),
            fontWeight: FontWeight.w900,
            letterSpacing: -1.1,
          ),
          titleLarge: TextStyle(
            color: Color(0xFF101828),
            fontWeight: FontWeight.w900,
            letterSpacing: -0.45,
          ),
          bodyMedium: TextStyle(
            color: Color(0xFF5D6678),
            height: 1.45,
          ),
        ),
      ),
      home: const VersionGallery(),
    );
  }
}

class _ExampleScrollBehavior extends MaterialScrollBehavior {
  const _ExampleScrollBehavior();

  @override
  Set<PointerDeviceKind> get dragDevices => const <PointerDeviceKind>{
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        PointerDeviceKind.trackpad,
        PointerDeviceKind.stylus,
        PointerDeviceKind.unknown,
      };
}
