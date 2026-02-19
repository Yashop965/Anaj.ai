import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'theme/app_theme.dart';
import 'main_dashboard_view.dart';
import 'onboarding_view.dart';
import '../logic/app_logger.dart';
import '../logic/performance_service.dart';

class SplashView extends StatefulWidget {
  @override
  _SplashViewState createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    // Fade animation
    _fadeController = AnimationController(
      duration: Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeIn),
    );

    // Scale animation
    _scaleController = AnimationController(
      duration: Duration(milliseconds: 1000),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeOut),
    );

    _fadeController.forward();
    _scaleController.forward();

    _navigateAfterDelay();
  }

  void _navigateAfterDelay() async {
    final monitor = PerformanceMonitor('App Initialization');
    try {
      AppLogger.info('Starting app initialization');
      
      // Reduced delay for faster app start (from 3s to 1.5s)
      await Future.delayed(Duration(milliseconds: 1500));

      final user = FirebaseAuth.instance.currentUser;
      AppLogger.info('Auth check: user=${user != null ? user.uid : "null"}');
      
      if (mounted) {
        if (user != null) {
          // User is logged in
          AppLogger.info('Navigating to MainDashboard');
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => MainDashboardView(),
            ),
          );
        } else {
          // User is not logged in, show onboarding
          AppLogger.info('Navigating to Onboarding');
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => OnboardingView(),
            ),
          );
        }
      }
      monitor.complete(tag: 'success');
    } catch (e, st) {
      AppLogger.error('Navigation error', e, st, tag: 'splash');
      monitor.complete(tag: 'error');
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => OnboardingView(),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppTheme.primaryColor, AppTheme.primaryLight],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // App Logo with Animation
              ScaleTransition(
                scale: _scaleAnimation,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.eco,
                    size: 60,
                    color: AppTheme.primaryColor,
                  ),
                ),
              ),

              SizedBox(height: 30),

              // App Title with Animation
              FadeTransition(
                opacity: _fadeAnimation,
                child: Column(
                  children: [
                    Text(
                      "Anaj.ai",
                      style: TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      "Crop Health Analysis",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white70,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      "फसल स्वास्थ्य विश्लेषण",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 60),

              // Loading indicator
              FadeTransition(
                opacity: _fadeAnimation,
                child: SizedBox(
                  width: 40,
                  height: 40,
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    strokeWidth: 3,
                  ),
                ),
              ),

              SizedBox(height: 20),

              // Loading text
              FadeTransition(
                opacity: _fadeAnimation,
                child: Text(
                  "Loading...",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white70,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
