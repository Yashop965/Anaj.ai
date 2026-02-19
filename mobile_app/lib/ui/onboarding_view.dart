import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'login_view.dart';

class OnboardingView extends StatefulWidget {
  @override
  _OnboardingViewState createState() => _OnboardingViewState();
}

class _OnboardingViewState extends State<OnboardingView> {
  late PageController _pageController;
  int _currentPage = 0;

  final List<OnboardingPage> pages = [
    OnboardingPage(
      title: "Welcome to Anaj.ai",
      subtitle: "आपकी खेती के लिए AI",
      description: "Instant AI diagnosis of crop pests and diseases",
      icon: Icons.eco,
      color: Color(0xFF009B77),
    ),
    OnboardingPage(
      title: "Scan Your Crops",
      subtitle: "अपनी फसल की जांच करें",
      description: "Take a photo or upload from gallery for instant analysis",
      icon: Icons.camera_alt,
      color: Color(0xFF4CAF9F),
    ),
    OnboardingPage(
      title: "Get Diagnosis",
      subtitle: "तुरंत परिणाम प्राप्त करें",
      description: "Receive detailed analysis and recommended treatments",
      icon: Icons.insights,
      color: Color(0xFF00C853),
    ),
    OnboardingPage(
      title: "Track & Learn",
      subtitle: "ट्रैक करें और सीखें",
      description: "Monitor crop health over time and improve productivity",
      icon: Icons.trending_up,
      color: Color(0xFF009B77),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Page View
          PageView.builder(
            controller: _pageController,
            onPageChanged: (int page) {
              setState(() {
                _currentPage = page;
              });
            },
            itemCount: pages.length,
            itemBuilder: (context, index) {
              return OnboardingPageWidget(page: pages[index]);
            },
          ),

          // Navigation
          Positioned(
            bottom: 30,
            left: 0,
            right: 0,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  // Page Indicators
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      pages.length,
                      (index) => Container(
                        margin: EdgeInsets.symmetric(horizontal: 4),
                        width: _currentPage == index ? 24 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          color: _currentPage == index
                              ? AppTheme.primaryColor
                              : AppTheme.dividerColor,
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: 30),

                  // Action Buttons
                  Row(
                    children: [
                      if (_currentPage > 0)
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              _pageController.previousPage(
                                duration: Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                              );
                            },
                            child: Text("Previous"),
                          ),
                        ),
                      if (_currentPage > 0) SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            if (_currentPage == pages.length - 1) {
                              Navigator.of(context).pushReplacement(
                                MaterialPageRoute(
                                  builder: (context) => LoginView(),
                                ),
                              );
                            } else {
                              _pageController.nextPage(
                                duration: Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                              );
                            }
                          },
                          child: Text(
                            _currentPage == pages.length - 1
                                ? "Get Started"
                                : "Next",
                          ),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 10),

                  // Skip Button
                  if (_currentPage < pages.length - 1)
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (context) => LoginView(),
                          ),
                        );
                      },
                      child: Text(
                        "Skip",
                        style: TextStyle(color: AppTheme.textSecondary),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class OnboardingPage {
  final String title;
  final String subtitle;
  final String description;
  final IconData icon;
  final Color color;

  OnboardingPage({
    required this.title,
    required this.subtitle,
    required this.description,
    required this.icon,
    required this.color,
  });
}

class OnboardingPageWidget extends StatelessWidget {
  final OnboardingPage page;

  const OnboardingPageWidget({required this.page});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [page.color.withOpacity(0.1), Colors.white],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: page.color.withOpacity(0.2),
            ),
            child: Icon(
              page.icon,
              size: 70,
              color: page.color,
            ),
          ),

          SizedBox(height: 40),

          // Title
          Text(
            page.title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),

          SizedBox(height: 8),

          // Subtitle
          Text(
            page.subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: page.color,
              fontWeight: FontWeight.w600,
            ),
          ),

          SizedBox(height: 16),

          // Description
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 30),
            child: Text(
              page.description,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: AppTheme.textSecondary,
                height: 1.6,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
