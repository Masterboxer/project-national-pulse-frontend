import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:project_micro_journal/authentication/pages/signup_page.dart';
import 'package:project_micro_journal/authentication/services/authentication_token_storage_service.dart';
import 'package:project_micro_journal/buddies/page/buddies_page.dart';
import 'package:project_micro_journal/firebase_options.dart';
import 'package:project_micro_journal/home/pages/home_page.dart';
import 'package:project_micro_journal/posts/pages/create_post_page.dart';
import 'package:project_micro_journal/profile/pages/profile_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  print('🚀 [MAIN] App starting...');

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  print('✅ [MAIN] Firebase initialized');

  runApp(ProjectMicroJournalApp());
}

class ProjectMicroJournalApp extends StatelessWidget {
  ProjectMicroJournalApp({super.key});
  final authenticationTokenStorageService = AuthenticationTokenStorageService();

  @override
  Widget build(BuildContext context) {
    print('📱 [APP] Building MaterialApp');

    // Set edge-to-edge here, after MaterialApp context is available
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarContrastEnforced: false,
      ),
    );

    return MaterialApp(
      title: 'Project Micro Journal',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.light,
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.dark,
        ),
      ),
      themeMode: ThemeMode.system,
      home: AuthWrapper(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    print('🔐 [AUTH] Building AuthWrapper');

    return FutureBuilder<String?>(
      future: AuthenticationTokenStorageService().getAccessToken(),
      builder: (context, snapshot) {
        print('🔐 [AUTH] Connection state: ${snapshot.connectionState}');
        print('🔐 [AUTH] Has data: ${snapshot.hasData}');
        print('🔐 [AUTH] Data: ${snapshot.data}');

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            body: SafeArea(child: Center(child: CircularProgressIndicator())),
          );
        } else if (snapshot.hasData && snapshot.data != null) {
          print('✅ [AUTH] User authenticated, showing MainAppTabs');
          return const MainAppTabs();
        } else {
          print('❌ [AUTH] No token, showing SignupPage');
          return const SignupPage();
        }
      },
    );
  }
}

class MainAppTabs extends StatefulWidget {
  const MainAppTabs({super.key});

  @override
  State<MainAppTabs> createState() => _MainAppTabsState();
}

class _MainAppTabsState extends State<MainAppTabs> {
  int _currentIndex = 0;

  final List<Widget> _tabs = [
    const HomePage(),
    const BuddiesPage(),
    const ProfilePage(),
  ];

  @override
  void initState() {
    super.initState();
    print('🏠 [TABS] MainAppTabs initState');

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _logMediaQueryInfo();
    });
  }

  void _logMediaQueryInfo() {
    if (!mounted) return;

    final mediaQuery = MediaQuery.of(context);
    print('📐 [TABS] === MediaQuery Info ===');
    print('📐 [TABS] Screen size: ${mediaQuery.size}');
    print('📐 [TABS] Padding: ${mediaQuery.padding}');
    print('📐 [TABS] ViewPadding: ${mediaQuery.viewPadding}');
    print('📐 [TABS] ViewInsets: ${mediaQuery.viewInsets}');
    print('📐 [TABS] Status bar height: ${mediaQuery.padding.top}');
    print('📐 [TABS] Bottom safe area: ${mediaQuery.padding.bottom}');
  }

  @override
  Widget build(BuildContext context) {
    print('🏠 [TABS] Building MainAppTabs (currentIndex: $_currentIndex)');

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness:
            isDark ? Brightness.light : Brightness.dark,
        systemNavigationBarContrastEnforced: false,
      ),
      child: Scaffold(
        body: SafeArea(
          child: IndexedStack(index: _currentIndex, children: _tabs),
        ),
        bottomNavigationBar: SafeArea(
          top: false,
          child: NavigationBar(
            selectedIndex: _currentIndex,
            onDestinationSelected: (int index) {
              print('📍 [NAV] Tab changed: $_currentIndex -> $index');
              setState(() {
                _currentIndex = index;
              });
            },
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.home_outlined),
                selectedIcon: Icon(Icons.home_filled),
                label: 'Home',
              ),
              NavigationDestination(
                icon: Icon(Icons.people_outlined),
                selectedIcon: Icon(Icons.people),
                label: 'Buddies',
              ),
              NavigationDestination(
                icon: Icon(Icons.person_outlined),
                selectedIcon: Icon(Icons.person),
                label: 'Profile',
              ),
            ],
          ),
        ),
        floatingActionButton:
            _currentIndex == 0
                ? FloatingActionButton.extended(
                  onPressed: () {
                    print('➕ [FAB] New Post button pressed');
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const CreatePostPage(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('New Post'),
                )
                : null,
      ),
    );
  }
}
