// lib/main.dart - Updated for multi-session system

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:veloci_client/theme/theme.dart';
import 'screens/zen_connection_screen.dart';
import 'screens/multi_session_app.dart';

void main() {
  runApp(const VelociFTPApp());
}

class VelociFTPApp extends StatelessWidget {
  const VelociFTPApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Set system UI overlay style for a cohesive zen look
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
        systemNavigationBarColor: ZenColors.paperWhite,
        systemNavigationBarIconBrightness: Brightness.dark,
        systemNavigationBarDividerColor: ZenColors.softGray,
      ),
    );

    // Set preferred orientations for better UX
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    return MaterialApp(
      title: 'VelociFTP',
      debugShowCheckedModeBanner: false,
      theme: ZenTheme.lightTheme,
      initialRoute: '/',
      routes: {
        '/': (context) => const MultiSessionApp(),
        '/connect': (context) => const ZenConnectionScreen(),
        '/main': (context) => const MultiSessionApp(),
      },
      builder: (context, child) {
        // Ensure consistent text scaling and handle edge cases
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: TextScaler.linear(
              MediaQuery.of(context).textScaler.scale(1.0).clamp(0.8, 1.3),
            ),
          ),
          child: ScrollConfiguration(
            behavior: const ZenScrollBehavior(),
            child: child!,
          ),
        );
      },
    );
  }
}

// Custom scroll behavior for zen-like smooth scrolling
class ZenScrollBehavior extends ScrollBehavior {
  const ZenScrollBehavior();

  @override
  ScrollPhysics getScrollPhysics(BuildContext context) {
    switch (getPlatform(context)) {
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
        return const BouncingScrollPhysics();
      case TargetPlatform.android:
      case TargetPlatform.fuchsia:
      case TargetPlatform.linux:
      case TargetPlatform.windows:
        return const ClampingScrollPhysics();
    }
  }

  @override
  Widget buildScrollbar(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) {
    switch (getPlatform(context)) {
      case TargetPlatform.linux:
      case TargetPlatform.macOS:
      case TargetPlatform.windows:
        return Scrollbar(
          controller: details.controller,
          thumbVisibility: true,
          thickness: 8,
          radius: const Radius.circular(4),
          child: child,
        );
      case TargetPlatform.android:
      case TargetPlatform.fuchsia:
      case TargetPlatform.iOS:
        return child;
    }
  }
}

// Custom page route for zen-like transitions
class ZenPageRoute<T> extends PageRoute<T> {
  ZenPageRoute({
    required this.builder,
    super.settings,
    this.maintainState = true,
    super.fullscreenDialog,
    this.transitionDuration = const Duration(milliseconds: 400),
  });

  final WidgetBuilder builder;
  @override
  final Duration transitionDuration;

  @override
  final bool maintainState;

  @override
  Duration get reverseTransitionDuration => transitionDuration;

  @override
  Color? get barrierColor => null;

  @override
  String? get barrierLabel => null;

  @override
  bool get barrierDismissible => false;

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    final result = builder(context);
    return FadeTransition(
      opacity: Tween<double>(
        begin: 0.0,
        end: 1.0,
      ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
      child: SlideTransition(
        position:
            Tween<Offset>(
              begin: const Offset(0.0, 0.03),
              end: Offset.zero,
            ).animate(
              CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
            ),
        child: result,
      ),
    );
  }

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return child;
  }
}
