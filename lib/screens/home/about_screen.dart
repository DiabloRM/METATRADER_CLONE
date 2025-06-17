import 'package:flutter/material.dart';
import 'package:metatrader_clone/screens/home/contact_developer_screen.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF181C23),
      appBar: AppBar(
        backgroundColor: const Color(0xFF181C23),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'About',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 32),
            // Logo
            Center(
              child: Container(
                width: 120,
                height: 120,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFF232A36),
                ),
                child: Center(
                  child: Icon(
                    Icons.groups_3_rounded, // Placeholder for MT5 logo
                    size: 80,
                    color: Color(0xFF6EC6F1),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            // App Name
            const Text(
              'MetaTrader 5',
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            // Build Number
            const Text(
              'Build 4982',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 16,
                fontWeight: FontWeight.w400,
              ),
            ),
            const SizedBox(height: 32),
            // Rate your experience
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Rate your experience',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
                Row(
                  children: List.generate(
                    5,
                    (index) => const Icon(
                      Icons.star,
                      color: Color(0xFFFFD600),
                      size: 28,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            // User guide
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading:
                  const Icon(Icons.menu_book_outlined, color: Colors.white),
              title: const Text(
                'User guide',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
              trailing: const Icon(Icons.chevron_right, color: Colors.white54),
              onTap: () async {
                const url =
                    'https://www.metatrader5.com/en/mobile-trading/android/help';
                if (await canLaunchUrl(Uri.parse(url))) {
                  await launchUrl(Uri.parse(url),
                      mode: LaunchMode.externalApplication);
                }
              },
            ),
            // Contact Developer
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.email_outlined, color: Colors.white),
              title: const Text(
                'Contact Developer',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
              trailing: const Icon(Icons.chevron_right, color: Colors.white54),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                      builder: (_) => const ContactDeveloperScreen()),
                );
              },
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}
