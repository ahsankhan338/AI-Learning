import 'package:aieducator/constants/constants.dart';
import 'package:aieducator/provider/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class BottomNavigationBarScreen extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const BottomNavigationBarScreen({
    super.key,
    required this.navigationShell,
  });

  @override
  Widget build(BuildContext context) {
    final AuthProvider authProvider = context.read<AuthProvider>();
    final location = GoRouterState.of(context).uri.path;

    // Check if we're on a main route or child route
    final isMainRoute = location == '/home' ||
        location == '/eBook' ||
        location == '/certificate' ||
        location == '/profile';

    // Determine the title based on the route
    String getTitle() {
      if (location.startsWith('/home/course/')) {
        final courseName = GoRouterState.of(context).pathParameters['name'] ??
            'Course Details';
        if (location.endsWith('/lectures')) {
          return "Personal Trainer";
        } else if (location.endsWith('/nearbyInstitute')) {
          return "Nearby Institute";
        } else if (location.endsWith('/availableCourses')) {
          return "Available Courses";
        }
        return courseName;
      } else if (location.startsWith('/eBook/')) {
        return 'eBook Details';
      } else if (location.startsWith('/certificate/')) {
        return 'Certificate Details';
      } else if (location.startsWith('/profile/')) {
        return 'Profile Settings';
      }
      return '';
    }

    return Container(
      decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(100.0),
          child: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            flexibleSpace: Padding(
              padding: EdgeInsets.only(
                left: isMainRoute ? 24 : 10,
                right: 24,
                bottom: 0,
                top: 24,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (isMainRoute) ...[
                    if (location == '/home') ...[
                      Text(
                        "Welcome!",
                        style: AppTextStyles.largeTitle(),
                      ),
                      Text(
                        authProvider.user!.name.toString(),
                        style: AppTextStyles.mediumTitle(),
                      ),
                    ] else ...[
                      Text(
                        location.split('/').last,
                        style: AppTextStyles.largeTitle(),
                      )
                    ],
                  ] else ...[
                    Row(
                      children: [
                        if (!isMainRoute)
                          IconButton(
                            icon: const Icon(Icons.arrow_back,
                                color: Colors.white),
                            onPressed: () => context.pop(),
                            padding: EdgeInsets.zero,
                          ),
                        const SizedBox(width: 8),
                        Text(
                          getTitle(),
                          style: AppTextStyles.largeTitle(),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
        backgroundColor: Colors.transparent,
        body: navigationShell,
        bottomNavigationBar: Container(
          margin: const EdgeInsets.only(left: 40,right: 40 ,top: 5, bottom: 20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            // Remove color from here
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: BottomNavigationBar(
              type: BottomNavigationBarType.fixed,
              elevation: 0,
              currentIndex: navigationShell.currentIndex,
              selectedItemColor: Colors.black,
              unselectedItemColor: Colors.grey,
              showSelectedLabels: false,
              showUnselectedLabels: false,
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.home_outlined),
                  activeIcon: Icon(Icons.home),
                  label: 'Home',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.my_library_books_outlined),
                  activeIcon: Icon(Icons.library_books_rounded),
                  label: 'eBook',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.verified_outlined),
                  activeIcon: Icon(Icons.verified),
                  label: 'Certificates',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.person_outlined),
                  activeIcon: Icon(Icons.person),
                  label: 'Profile',
                ),
              ],
              onTap: (index) => _onItemTapped(index, context),
            ),
          ),
        ),
      ),
    );
  }

  void _onItemTapped(int index, BuildContext context) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }
}
