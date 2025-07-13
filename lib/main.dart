import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart';
import 'dart:ui' as ui;
import 'dart:io';
import 'register_lost_screen.dart';
import 'package:uuid/uuid.dart';

// Constants
const kTitleStyle =
    TextStyle(fontWeight: FontWeight.bold, fontSize: 48, color: Colors.black);
const kTaglineStyle = TextStyle(
    color: Colors.lightBlue,
    fontWeight: FontWeight.bold,
    fontSize: 20,
    letterSpacing: 1.2);
const kCardMargin = EdgeInsets.symmetric(vertical: 6, horizontal: 12);
const kCardPadding = EdgeInsets.all(8.0);
const kAppBarTitleStyle = TextStyle(fontWeight: FontWeight.bold, fontSize: 24);
const kBodyPadding = EdgeInsets.all(16);

// Models
class LostItem {
  final String id,
      photo,
      name,
      identity,
      description,
      location,
      category,
      itemType,
      countryCode;
  final bool isClaimed, isSample;
  final DateTime? claimedAt;

  const LostItem({
    required this.id,
    required this.photo,
    required this.name,
    required this.identity,
    required this.description,
    required this.location,
    required this.isClaimed,
    required this.category,
    this.isSample = false,
    this.claimedAt,
    required this.itemType,
    required this.countryCode,
  });

  factory LostItem.fromJson(Map<String, dynamic> json) => LostItem(
        id: json['id'],
        photo: json['photo'],
        name: json['name'],
        identity: json['identity'],
        description: json['description'],
        location: json['location'],
        isClaimed: json['isClaimed'],
        category: json['category'],
        isSample: json['isSample'] ?? false,
        claimedAt: json['claimedAt'] != null
            ? DateTime.parse(json['claimedAt'])
            : null,
        itemType: json['itemType'],
        countryCode: json['countryCode'],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'photo': photo,
        'name': name,
        'identity': identity,
        'description': description,
        'location': location,
        'isClaimed': isClaimed,
        'category': category,
        'isSample': isSample,
        'claimedAt': claimedAt?.toIso8601String(),
        'itemType': itemType,
        'countryCode': countryCode,
      };

  LostItem copyWith({
    String? id,
    String? photo,
    String? name,
    String? identity,
    String? description,
    String? location,
    bool? isClaimed,
    String? category,
    bool? isSample,
    DateTime? claimedAt,
    String? itemType,
    String? countryCode,
  }) =>
      LostItem(
        id: id ?? this.id,
        photo: photo ?? this.photo,
        name: name ?? this.name,
        identity: identity ?? this.identity,
        description: description ?? this.description,
        location: location ?? this.location,
        isClaimed: isClaimed ?? this.isClaimed,
        category: category ?? this.category,
        isSample: isSample ?? this.isSample,
        claimedAt: claimedAt ?? this.claimedAt,
        itemType: itemType ?? this.itemType,
        countryCode: countryCode ?? this.countryCode,
      );
}

// Mock User class
class MockUser {
  final String uid, email, role;
  final String? displayName;

  const MockUser({
    required this.uid,
    required this.email,
    this.displayName,
    this.role = 'user',
  });
}

// Providers
class AuthProvider extends ChangeNotifier {
  MockUser? _user;
  String? _countryCode;
  String? _error;

  MockUser? get user => _user;
  String? get countryCode => _countryCode;
  String? get error => _error;
  String get role => _user?.role ?? 'user';

  AuthProvider() {
    _user = const MockUser(
      uid: 'mock-user-id',
      email: 'test@example.com',
      displayName: 'Test User',
      role: 'user',
    );
    _countryCode = 'US';
    notifyListeners();
  }

  Future<void> signInWithEmail(String email, String password) async {
    try {
      _user = MockUser(
        uid: 'mock-user-${DateTime.now().millisecondsSinceEpoch}',
        email: email,
        displayName: 'User',
        role: 'user',
      );
      _countryCode = ui.window.locale.countryCode ?? 'US';
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> signUpWithEmail(
      String email, String password, String name) async {
    try {
      _user = MockUser(
        uid: 'mock-user-${DateTime.now().millisecondsSinceEpoch}',
        email: email,
        displayName: name,
        role: 'user',
      );
      _countryCode = ui.window.locale.countryCode ?? 'US';
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> signInWithGoogle() async {
    try {
      _user = const MockUser(
        uid: 'mock-google-user',
        email: 'google@example.com',
        displayName: 'Google User',
        role: 'user',
      );
      _countryCode = ui.window.locale.countryCode ?? 'US';
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> signOut() async {
    _user = null;
    _countryCode = null;
    notifyListeners();
  }
}

class LostItemsProvider extends ChangeNotifier {
  final List<LostItem> _items = [];
  bool _isLoading = false;
  String? _error;

  List<LostItem> get items => List.unmodifiable(_items);
  bool get isLoading => _isLoading;
  String? get error => _error;

  LostItemsProvider() {
    _loadSampleItems();
  }

  void _loadSampleItems() {
    _items.addAll([
      const LostItem(
        id: 'sample1',
        photo: 'assets/default_id_card.png',
        name: 'Sample ID Card',
        identity: 'ID1001',
        description: 'Lost ID card with photo',
        location: 'Sample Location 1',
        isClaimed: false,
        category: 'ID Card',
        isSample: true,
        itemType: 'lost',
        countryCode: 'US',
      ),
      LostItem(
        id: 'sample2',
        photo: 'assets/default_wallet.png',
        name: 'Sample Wallet',
        identity: 'WALLET001',
        description: 'Brown leather wallet',
        location: 'Sample Location 2',
        isClaimed: true,
        category: 'Wallet',
        isSample: true,
        claimedAt: DateTime.now().subtract(const Duration(days: 5)),
        itemType: 'found',
        countryCode: 'US',
      ),
      const LostItem(
        id: 'sample3',
        photo: 'assets/default_phones.png',
        name: 'Sample Phone',
        identity: 'PHONE001',
        description: 'iPhone 13 with black case',
        location: 'Sample Location 3',
        isClaimed: false,
        category: 'Phone',
        isSample: true,
        itemType: 'lost',
        countryCode: 'US',
      ),
    ]);
    notifyListeners();
  }

  Future<void> fetchItems(String countryCode) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      await Future.delayed(const Duration(milliseconds: 500));
      removeOldClaimedItems();
    } catch (e) {
      _error = e.toString();
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> addItem(LostItem item, File? image) async {
    try {
      String photo = item.photo;
      if (image != null) {
        photo = 'assets/default_general_goods.png';
      }
      _items.add(item.copyWith(photo: photo));
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  void removeOldClaimedItems() {
    final now = DateTime.now();
    _items.removeWhere((item) =>
        item.isClaimed &&
        !item.isSample &&
        item.claimedAt != null &&
        now.difference(item.claimedAt!).inDays > 31);
    notifyListeners();
  }

  Future<void> updateClaimedStatus(
      String id, String countryCode, bool isClaimed) async {
    final index = _items.indexWhere((item) => item.id == id);
    if (index != -1) {
      final old = _items[index];
      final updated = old.copyWith(
        isClaimed: isClaimed,
        claimedAt: isClaimed ? DateTime.now() : null,
      );
      _items[index] = updated;
      removeOldClaimedItems();
      notifyListeners();
    }
  }
}

// Mock promotions data
final List<Map<String, String>> mockPromotions = [
  {
    'title': 'Premium Service',
    'description':
        'Get priority listing and enhanced visibility for your lost items',
    'label': 'Upgrade Now',
  },
];

// GoRouter Configuration
final GoRouter _router = GoRouter(
  initialLocation: '/',
  redirect: (context, state) async {
    final authProvider = context.read<AuthProvider>();
    if (authProvider.user == null && state.matchedLocation != '/login') {
      return '/login';
    }
    return null;
  },
  routes: [
    GoRoute(path: '/', builder: (context, state) => const SplashScreen()),
    GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
    GoRoute(path: '/home', builder: (context, state) => const HomeScreen()),
    GoRoute(
      path: '/item/:id',
      builder: (context, state) {
        final item = state.extra as LostItem?;
        return ItemDetailScreen(item: item);
      },
    ),
    GoRoute(path: '/policy', builder: (context, state) => const PolicyScreen()),
    GoRoute(
      path: '/register/:type',
      builder: (context, state) {
        final type = state.pathParameters['type']!;
        return RegisterLostScreen(itemType: type);
      },
    ),
    GoRoute(
        path: '/partner',
        builder: (context, state) => const PartnerDashboardScreen()),
    GoRoute(
        path: '/admin', builder: (context, state) => const AdminReviewScreen()),
  ],
);

// Main App
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => LostItemsProvider()),
      ],
      child: const LostAndFoundApp(),
    ),
  );
}

class LostAndFoundApp extends StatelessWidget {
  const LostAndFoundApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Lost & Found',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        useMaterial3: true,
      ),
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en', ''),
        Locale('sn', ''),
      ],
      routerConfig: _router,
    );
  }
}

// Screens
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () => context.go('/home'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue, Colors.lightBlue],
          ),
        ),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.search, size: 100, color: Colors.white),
              SizedBox(height: 20),
              Text('Lost & Found', style: kTitleStyle),
              SizedBox(height: 10),
              Text('Find what you lost, return what you found',
                  style: kTaglineStyle),
            ],
          ),
        ),
      ),
    );
  }
}

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    final nameController = TextEditingController();

    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: passwordController,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Name (for sign-up)',
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                try {
                  await authProvider.signInWithEmail(
                    emailController.text,
                    passwordController.text,
                  );
                  context.go('/home');
                } catch (e) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text('Login failed: $e')));
                }
              },
              child: const Text('Sign In'),
            ),
            ElevatedButton(
              onPressed: () async {
                try {
                  await authProvider.signUpWithEmail(
                    emailController.text,
                    passwordController.text,
                    nameController.text,
                  );
                  context.go('/home');
                } catch (e) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text('Sign-up failed: $e')));
                }
              },
              child: const Text('Sign Up'),
            ),
            ElevatedButton(
              onPressed: () async {
                try {
                  await authProvider.signInWithGoogle();
                  context.go('/home');
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Google Sign-In failed: $e')),
                  );
                }
              },
              child: const Text('Sign In with Google'),
            ),
          ],
        ),
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String searchQuery = '';
  // BannerAd? _bannerAd; // Commented out for local testing
  // bool _isBannerAdReady = false; // Commented out for local testing

  @override
  void initState() {
    super.initState();
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    Provider.of<LostItemsProvider>(
      context,
      listen: false,
    ).fetchItems(authProvider.countryCode ?? 'US');
    // Banner ad code commented out for local testing
  }

  @override
  void dispose() {
    // _bannerAd?.dispose(); // Commented out for local testing
    super.dispose();
  }

  String getCountryName(String code) {
    const names = {
      'US': 'United States',
      'GB': 'United Kingdom',
      'FR': 'France',
      'DE': 'Germany',
      'CA': 'Canada',
      'AU': 'Australia',
    };
    return names[code] ?? 'Unknown';
  }

  String getCountryFlag(String code) {
    const flags = {
      'US': '🇺🇸',
      'GB': '🇬🇧',
      'FR': '🇫🇷',
      'DE': '🇩🇪',
      'CA': '🇨🇦',
      'AU': '🇦🇺',
    };
    return flags[code] ?? '🏳️';
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final lostItemsProvider = Provider.of<LostItemsProvider>(context);
    final filteredItems = lostItemsProvider.items.where((item) {
      final q = searchQuery.toLowerCase();
      return item.name.toLowerCase().contains(q) ||
          item.description.toLowerCase().contains(q) ||
          item.location.toLowerCase().contains(q) ||
          item.identity.toLowerCase().contains(q);
    }).toList();
    final lostSection =
        filteredItems.where((item) => item.itemType == 'lost').toList();
    final foundSection =
        filteredItems.where((item) => item.itemType == 'found').toList();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: Row(
          children: [
            const Text('Lost & Found', style: kTitleStyle),
            const SizedBox(width: 24),
            if (authProvider.countryCode != null) ...[
              Text(
                getCountryFlag(authProvider.countryCode!),
                style: const TextStyle(fontSize: 32),
              ),
              const SizedBox(width: 8),
              Text(
                getCountryName(authProvider.countryCode!),
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 22,
                ),
              ),
            ],
            const Spacer(),
            ElevatedButton.icon(
              icon: const Icon(Icons.add, size: 22),
              label: const Text(
                'Register Lost Item',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
              ),
              onPressed: () => context.go('/register/lost'),
            ),
            ElevatedButton.icon(
              icon: const Icon(Icons.dashboard),
              label: const Text('Partner Dashboard'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueGrey,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
              ),
              onPressed: () => context.go('/partner'),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.policy),
            onPressed: () => context.go('/policy'),
            color: Colors.black,
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await Provider.of<AuthProvider>(context, listen: false).signOut();
              context.go('/login');
            },
            color: Colors.black,
          ),
        ],
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 16, top: 16, bottom: 8),
            child: const Text('TonGuy Platforms', style: kTaglineStyle),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Search by name, description, location, or identity',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (val) => setState(() => searchQuery = val),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Card(
              color: Colors.yellow[100],
              child: const Padding(
                padding: EdgeInsets.all(8),
                child: Text(
                  "Important: Only authorized entities (Police, Registered Businesses, Post Office, Government Departments, Religious Institutions) can register found items. Individuals must leave found items at these locations. Violations may result in suspension.",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
          if (mockPromotions.isNotEmpty)
            PromotionCard(
              title: mockPromotions[0]['title']!,
              description: mockPromotions[0]['description']!,
              label: mockPromotions[0]['label']!,
            ),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 8,
                        ),
                        child: Row(
                          children: const [
                            Icon(Icons.list, color: Colors.deepPurple),
                            SizedBox(width: 8),
                            Text(
                              'Lost Items',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                                color: Colors.deepPurple,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                            side: const BorderSide(
                              color: Colors.deepPurple,
                              width: 1,
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: lostItemsProvider.isLoading
                                ? const Center(
                                    child: CircularProgressIndicator(),
                                  )
                                : lostSection.isEmpty
                                    ? const Center(
                                        child: Text('No lost items found.'),
                                      )
                                    : Scrollbar(
                                        thumbVisibility: true,
                                        thickness: 10,
                                        radius: const Radius.circular(8),
                                        child: GridView.builder(
                                          gridDelegate:
                                              const SliverGridDelegateWithMaxCrossAxisExtent(
                                            maxCrossAxisExtent: 350,
                                            mainAxisSpacing: 8,
                                            crossAxisSpacing: 8,
                                            childAspectRatio: 0.95,
                                          ),
                                          itemCount: lostSection.length,
                                          itemBuilder: (context, index) {
                                            final item = lostSection[index];
                                            return LostItemCard(
                                              item: item,
                                              isSample: item.isSample,
                                              compact: true,
                                              onTap: () => context.go(
                                                '/item/${item.id}',
                                                extra: item,
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 8,
                        ),
                        child: Row(
                          children: const [
                            Icon(Icons.list_alt, color: Colors.green),
                            SizedBox(width: 8),
                            Text(
                              'Found Items',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                                color: Colors.green,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                            side: const BorderSide(
                              color: Colors.green,
                              width: 1,
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: lostItemsProvider.isLoading
                                ? const Center(
                                    child: CircularProgressIndicator(),
                                  )
                                : foundSection.isEmpty
                                    ? const Center(
                                        child:
                                            Text('No found items registered.'),
                                      )
                                    : Scrollbar(
                                        thumbVisibility: true,
                                        thickness: 10,
                                        radius: const Radius.circular(8),
                                        child: GridView.builder(
                                          gridDelegate:
                                              const SliverGridDelegateWithMaxCrossAxisExtent(
                                            maxCrossAxisExtent: 350,
                                            mainAxisSpacing: 8,
                                            crossAxisSpacing: 8,
                                            childAspectRatio: 0.95,
                                          ),
                                          itemCount: foundSection.length,
                                          itemBuilder: (context, index) {
                                            final item = foundSection[index];
                                            return LostItemCard(
                                              item: item,
                                              isSample: item.isSample,
                                              compact: true,
                                              onTap: () => context.go(
                                                '/item/${item.id}',
                                                extra: item,
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Banner ad code commented out for local testing
        ],
      ),
    );
  }
}

// Widgets
class LostItemCard extends StatelessWidget {
  final LostItem item;
  final bool isSample;
  final bool compact;
  final VoidCallback? onTap;

  const LostItemCard({
    super.key,
    required this.item,
    this.isSample = false,
    this.compact = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: kCardMargin,
      elevation: isSample ? 2 : 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: item.isClaimed ? Colors.green : Colors.blue,
          width: isSample ? 1 : 2,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: kCardPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 3,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: item.photo.startsWith('assets/')
                      ? Image.asset(
                          item.photo,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.grey[300],
                              child: const Icon(Icons.image, size: 50),
                            );
                          },
                        )
                      : CachedNetworkImage(
                          imageUrl: item.photo,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            color: Colors.grey[300],
                            child: const Center(
                              child: CircularProgressIndicator(),
                            ),
                          ),
                          errorWidget: (context, url, error) => Container(
                            color: Colors.grey[300],
                            child: const Icon(Icons.image, size: 50),
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'ID: ${item.identity}',
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                    if (!compact) ...[
                      const SizedBox(height: 4),
                      Text(
                        item.description,
                        style: TextStyle(color: Colors.grey[700], fontSize: 12),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Location: ${item.location}',
                        style: TextStyle(color: Colors.grey[600], fontSize: 11),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: item.isClaimed ? Colors.green : Colors.blue,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            item.isClaimed
                                ? 'Claimed'
                                : item.itemType.toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        if (isSample)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.orange,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              'SAMPLE',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 8,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PromotionCard extends StatelessWidget {
  final String title;
  final String description;
  final String label;

  const PromotionCard({
    super.key,
    required this.title,
    required this.description,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8),
      color: Colors.purple[50],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(description),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: () {
                // Handle promotion action
              },
              child: Text(label),
            ),
          ],
        ),
      ),
    );
  }
}

// Placeholder screens for navigation
class ItemDetailScreen extends StatelessWidget {
  final LostItem? item;

  const ItemDetailScreen({super.key, this.item});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(item?.name ?? 'Item Details')),
      body: Center(child: Text('Details for ${item?.name ?? 'Unknown Item'}')),
    );
  }
}

class PolicyScreen extends StatelessWidget {
  const PolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Policy')),
      body: const Center(
        child: Text('Policy information will be displayed here.'),
      ),
    );
  }
}

class PartnerDashboardScreen extends StatelessWidget {
  const PartnerDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Partner Dashboard')),
      body: const Center(
        child: Text('Partner dashboard will be displayed here.'),
      ),
    );
  }
}

class AdminReviewScreen extends StatelessWidget {
  const AdminReviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Admin Review')),
      body: const Center(
        child: Text('Admin review panel will be displayed here.'),
      ),
    );
  }
}
