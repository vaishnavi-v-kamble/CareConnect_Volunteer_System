import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_constants.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final PageController _pageController = PageController();

  int currentPage = 0;

  final Color backgroundColor = const Color(0xFFDDF1EF);
  final Color primaryColor = const Color(0xFF008B83);
  final Color bottomColor = const Color(0xFF007A73);

  final List<Map<String, String>> onboardingData = [
    {
      'title': 'Discover a\nNetwork of Hope',
      'description':
          'Connect with nearby NGOs to help people in need and make donations.',
      'image': 'assets/images/slide1.png',
    },
    {
      'title': 'Extending Hearts\nTransforming Lives',
      'description':
          'Donate your time and resources to help people who are in need.',
      'image': 'assets/images/slide2.png',
    },
    {
      'title': 'Shape Tomorrows\nwith Your Generosity',
      'description':
          'Donate goods to make a meaningful impact on the individual’s life.',
      'image': 'assets/images/slide3.png',
    },
  ];

  // NEXT PAGE
 // NEXT PAGE / GET STARTED
void nextPage() {
  if (currentPage < 2) {
    _pageController.nextPage(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  } else {
    context.go(AppConstants.moduleSelectionRoute);
  }
}
  
  // SKIP PAGE
void skipPage() {
  if (currentPage < 2) {
    _pageController.animateToPage(
      2,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }
}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: PageView.builder(
          controller: _pageController,
          itemCount: onboardingData.length,
          onPageChanged: (index) {
            setState(() {
              currentPage = index;
            });
          },
          itemBuilder: (context, index) {
            return buildOnboardingPage(index);
          },
        ),
      ),
    );
  }

  Widget buildOnboardingPage(int index) {
    final data = onboardingData[index];

    return Column(
      children: [

        // TOP SECTION
        Expanded(
          child: Container(
            width: double.infinity,
            color: backgroundColor,
            child: Column(
              children: [

                const SizedBox(height: 15),

                // LOGO
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.volunteer_activism,
                      color: primaryColor,
                      size: 27,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'CareConnect',
                      style: TextStyle(
                        color: primaryColor,
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 25),

                // TITLE
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    data['title']!,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 21,
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                      height: 1.3,
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // DESCRIPTION
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25),
                  child: Text(
                    data['description']!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF36716D),
                      height: 1.5,
                    ),
                  ),
                ),

                const SizedBox(height: 15),

                // CLOUD DESIGN
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25),
                  child: Row(
                    mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,
                    children: const [
                      Icon(
                        Icons.cloud,
                        color: Colors.white,
                        size: 30,
                      ),
                      Icon(
                        Icons.cloud,
                        color: Colors.white,
                        size: 22,
                      ),
                    ],
                  ),
                ),

                // MAIN VOLUNTEER IMAGE
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 25,
                      vertical: 5,
                    ),
                    child: Image.asset(
                      data['image']!,
                      fit: BoxFit.contain,
                      width: double.infinity,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(
                          Icons.volunteer_activism,
                          size: 120,
                          color: primaryColor,
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // BOTTOM NAVIGATION
        Container(
          height: 68,
          width: double.infinity,
          color: bottomColor,
          padding: const EdgeInsets.symmetric(horizontal: 15),

          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [

              // SKIP
              TextButton(
                onPressed: skipPage,
                child: const Text(
                  'Skip',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
              ),

              // PAGE INDICATOR
              Row(
                children: List.generate(
                  3,
                  (dotIndex) => AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    margin: const EdgeInsets.symmetric(
                      horizontal: 3,
                    ),
                    height: 6,
                    width: currentPage == dotIndex ? 7 : 5,
                    decoration: BoxDecoration(
                      color: currentPage == dotIndex
                          ? Colors.white
                          : Colors.white54,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),

              // NEXT / GET STARTED
              TextButton(
                onPressed: nextPage,
                child: Text(
                  currentPage == 2 ? 'Get Started' : 'Next',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}