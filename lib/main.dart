import 'package:flutter/material.dart';
import 'register_lost_screen.dart';
import 'dart:ui' as ui;

void main() {
  runApp(const LostAndFoundApp());
}

class LostAndFoundApp extends StatelessWidget {
  const LostAndFoundApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lost & Found',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/home': (context) => const HomeScreen(),
        '/itemDetail': (context) => const ItemDetailScreen(),
        '/policy': (context) => const PolicyScreen(),
        '/registerLost': (context) => const RegisterLostScreen(),
      },
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pushReplacementNamed(context, '/home');
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search, size: 80, color: Colors.blue),
            SizedBox(height: 20),
            Text(
              'Lost & Found',
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
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
  String? countryCode;
  String? countryName;
  String? countryFlag;

  // Sample data for 20 lost items with all required fields
  final List<Map<String, dynamic>> sampleItems = List.generate(
    20,
    (i) => {
      'photo': null, // Replace with image URL if available
      'name': 'Lost Item #${i + 1}',
      'identity': i % 2 == 0 ? 'ID${1000 + i}' : null,
      'description': 'Description for lost item #${i + 1}',
      'location': 'Business Address ${((i % 5) + 1)}, City',
      'isClaimed': i % 3 == 0, // Every third item is claimed
    },
  );

  @override
  void initState() {
    super.initState();
    _detectCountry();
  }

  void _detectCountry() {
    final locale = ui.window.locale;
    final code = locale.countryCode ?? 'ZW';
    setState(() {
      countryCode = code;
      countryName = _countryNames[code] ?? 'Unknown';
      countryFlag = _countryFlags[code] ?? '🏳️';
    });
  }

  static const Map<String, String> _countryNames = {
    'ZW': 'Zimbabwe',
    'ZA': 'South Africa',
    'NG': 'Nigeria',
    'KE': 'Kenya',
    'US': 'United States',
    'GB': 'United Kingdom',
    // Add more as needed
  };
  static const Map<String, String> _countryFlags = {
    'ZW': '🇿🇼',
    'ZA': '🇿🇦',
    'NG': '🇳🇬',
    'KE': '🇰🇪',
    'US': '🇺🇸',
    'GB': '🇬🇧',
    // Add more as needed
  };

  @override
  Widget build(BuildContext context) {
    final filteredItems = sampleItems.where((item) {
      final q = searchQuery.toLowerCase();
      return item['name'].toLowerCase().contains(q) ||
          (item['description'] as String).toLowerCase().contains(q) ||
          (item['location'] as String).toLowerCase().contains(q) ||
          (item['identity']?.toLowerCase() ?? '').contains(q);
    }).toList();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: Row(
          children: [
            // App name
            const Text(
              'Lost & Found',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black,
                fontSize: 48,
              ),
            ),
            const SizedBox(width: 24),
            // Country flag and name
            if (countryFlag != null && countryName != null) ...[
              Text(countryFlag!, style: const TextStyle(fontSize: 32)),
              const SizedBox(width: 8),
              Text(
                countryName!,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                  fontSize: 22,
                ),
              ),
            ],
            const Spacer(),
            // Register Lost Item button
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
              onPressed: () => Navigator.pushNamed(context, '/registerLost'),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.policy),
            onPressed: () => Navigator.pushNamed(context, '/policy'),
            color: Colors.black,
          ),
        ],
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Column(
        children: [
          // Tagline for parent company, right-aligned, sky blue
          Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 16, top: 16, bottom: 8),
            child: const Text(
              'TonGuy Platforms',
              style: TextStyle(
                color: Colors.lightBlue,
                fontWeight: FontWeight.bold,
                fontSize: 20,
                letterSpacing: 1.2,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Search by name, description, location, or identity',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (val) {
                setState(() {
                  searchQuery = val;
                });
              },
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
          Expanded(
            child: filteredItems.isEmpty
                ? const Center(child: Text('No items found.'))
                : ListView.builder(
                    itemCount: filteredItems.length,
                    itemBuilder: (context, index) {
                      final item = filteredItems[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                          vertical: 6,
                          horizontal: 12,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Photo
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: item['photo'] != null
                                    ? Image.network(
                                        item['photo'],
                                        width: 64,
                                        height: 64,
                                        fit: BoxFit.cover,
                                      )
                                    : Container(
                                        width: 64,
                                        height: 64,
                                        color: Colors.grey[300],
                                        child: const Icon(
                                          Icons.image,
                                          size: 40,
                                          color: Colors.grey,
                                        ),
                                      ),
                              ),
                              const SizedBox(width: 12),
                              // Details
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item['name'],
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    if (item['identity'] != null)
                                      Padding(
                                        padding: const EdgeInsets.only(
                                          top: 2,
                                          bottom: 2,
                                        ),
                                        child: Text(
                                          'Identity: ${item['identity']}',
                                          style: const TextStyle(
                                            color: Colors.black87,
                                          ),
                                        ),
                                      ),
                                    Text(item['description']),
                                    Padding(
                                      padding: const EdgeInsets.only(top: 4),
                                      child: Row(
                                        children: [
                                          const Icon(
                                            Icons.location_on,
                                            size: 16,
                                            color: Colors.blueGrey,
                                          ),
                                          const SizedBox(width: 4),
                                          Expanded(
                                            child: Text(
                                              item['location'],
                                              style: const TextStyle(
                                                color: Colors.blueGrey,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(top: 4),
                                      child: Row(
                                        children: [
                                          const Icon(
                                            Icons.verified_user,
                                            size: 16,
                                            color: Colors.green,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            item['isClaimed']
                                                ? 'Collected'
                                                : 'Available',
                                            style: TextStyle(
                                              color: item['isClaimed']
                                                  ? Colors.red
                                                  : Colors.green,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class ItemDetailScreen extends StatelessWidget {
  const ItemDetailScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Item Details')),
      body: const Center(child: Text('Item details will appear here.')),
    );
  }
}

class PolicyScreen extends StatelessWidget {
  const PolicyScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Policy')),
      body: const Padding(
        padding: EdgeInsets.all(16),
        child: Text(
          'Lost & Found Item Registration Policy\n\n'
          'Important: For safety and verification, only authorized entities are permitted to register lost and found items. These include Police Departments, Registered Businesses, Post Offices, Government Departments, and Religious Institutions. Individuals are required to leave lost and found items at any of these authorized locations. Any attempt by individuals to register items directly through this platform will violate our policy and may result in account suspension.\n\n'
          'The platform is publicly accessible for searching for lost items without charge.\n\n'
          'When claiming an item, a profile with your name and contact number will be created/referenced. For certain items, a biometric fingerprint signature may be required at the collection point for secure verification. This app helps facilitate the connection, but physical collection and final verification occur at the authorized entity\'s premises.',
          style: TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}
