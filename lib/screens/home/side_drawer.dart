import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:metatrader_clone/providers/auth_provider.dart';
import 'package:metatrader_clone/screens/auth/login_screen.dart';
import 'package:metatrader_clone/screens/home/about_screen.dart';
import 'package:metatrader_clone/screens/home/news_screen.dart';
import 'package:metatrader_clone/screens/home/journal_screen.dart';
import 'package:metatrader_clone/screens/home/setting_screen.dart';
import 'package:metatrader_clone/screens/home/mailbox_screen.dart';
import 'package:metatrader_clone/screens/auth/register_screen.dart';
import 'package:url_launcher/url_launcher.dart';

class SideDrawer extends StatelessWidget {
  final void Function(int)? onItemSelected;
  const SideDrawer({Key? key, this.onItemSelected}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;
    final isAuthenticated = authProvider.isAuthenticated;

    return Drawer(
      backgroundColor: const Color(0xFF1E1F23),
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 16),
          children: [
            // User Info Section
            if (isAuthenticated && user != null)
              ListTile(
                leading: const CircleAvatar(child: Icon(Icons.person)),
                title: Text(
                  user.name,
                  style: const TextStyle(color: Colors.white),
                ),
                subtitle: Text(
                  "${user.login} - MetaQuotes-Demo",
                  style: const TextStyle(color: Colors.white54),
                ),
                trailing: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    "Demo",
                    style: TextStyle(fontSize: 10, color: Colors.white),
                  ),
                ),
              )
            else
              // Guest/Not Logged In Section
              Column(
                children: [
                  ListTile(
                    leading:
                        const CircleAvatar(child: Icon(Icons.person_outline)),
                    title: const Text(
                      "Guest User",
                      style: TextStyle(color: Colors.white),
                    ),
                    subtitle: const Text(
                      "Not logged in",
                      style: TextStyle(color: Colors.white54),
                    ),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.grey,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        "Guest",
                        style: TextStyle(fontSize: 10, color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ),
                            onPressed: () {
                              Navigator.of(context).pop(); // Close drawer
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => const LoginScreen(),
                                ),
                              );
                            },
                            child: const Text(
                              'LOGIN',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              side: const BorderSide(color: Colors.white54),
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ),
                            onPressed: () {
                              Navigator.of(context).pop(); // Close drawer
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => const RegisterScreen(),
                                ),
                              );
                            },
                            child: const Text(
                              'REGISTER',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.white54,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            const Divider(color: Colors.white24),
            // _drawerItem(
            //   Icons.import_export,
            //   "Quotes",
            //   onTap: () => _select(context, 0),
            // ),
            // _drawerItem(
            //   Icons.candlestick_chart,
            //   "Charts",
            //   onTap: () => _select(context, 1),
            // ),
            _drawerItem(
              Icons.show_chart,
              "Trade",
              onTap: () => _select(context, 2),
            ),
            // _drawerItem(
            //   Icons.history,
            //   "History",
            //   onTap: () => _select(context, 3),
            // ),
            // _drawerItem(
            //   Icons.message,
            //   "Messages",
            //   onTap: () => _select(context, 4),
            // ),
            _drawerItem(
              Icons.newspaper,
              "News",
              onTap: () => _select(context, 6),
            ),
            _drawerItem(
              Icons.mail,
              "Mailbox",
              trailing: const CircleAvatar(
                radius: 10,
                child: Text("8", style: TextStyle(fontSize: 12)),
              ),
              onTap: () => _select(context, 7),
            ),
            _drawerItem(Icons.book, "Journal",
                onTap: () => _select(context, 8)),
            _drawerItem(
              Icons.settings,
              "Settings",
              onTap: () => _select(context, 9),
            ),
            // Add logout option for authenticated users
            if (isAuthenticated)
              _drawerItem(
                Icons.logout,
                "Logout",
                onTap: () => _logout(context),
              ),
            _drawerItem(
              Icons.calendar_today,
              "Economic calendar",
              trailing: _adsTag(),
              onTap: () => _select(context, 10),
            ),
            _drawerItem(
              Icons.groups,
              "Traders Community",
              onTap: () => _select(context, 11),
            ),
            _drawerItem(
              Icons.auto_graph,
              "MQL5 Algo Trading",
              onTap: () => _select(context, 12),
            ),
            _drawerItem(
              Icons.help_outline,
              "User guide",
              onTap: () => _select(context, 13),
            ),
            _drawerItem(
              Icons.info_outline,
              "About",
              onTap: () => _select(context, 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _drawerItem(
    IconData icon,
    String label, {
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.white),
      title: Text(label, style: const TextStyle(color: Colors.white)),
      trailing: trailing,
      onTap: onTap,
    );
  }

  Widget _adsTag() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.blue,
        borderRadius: BorderRadius.circular(6),
      ),
      child: const Text(
        "Ads",
        style: TextStyle(fontSize: 10, color: Colors.white),
      ),
    );
  }

  void _select(BuildContext context, int index) async {
    Navigator.of(context).pop(); // Close the drawer

    if (index == 14) {
      // About
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const AboutScreen()),
      );
      return;
    }
    if (index == 9) {
      // Settings
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const SettingScreen()),
      );
      return;
    }
    if (index == 13) {
      // User guide
      const url = 'https://www.metatrader5.com/en/mobile-trading/android/help';
      if (await canLaunchUrl(Uri.parse(url))) {
        await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
      }
      return;
    }
    if (index == 12) {
      // MQL5 Algo Trading
      const url = 'https://t.me/mql5dev';
      if (await canLaunchUrl(Uri.parse(url))) {
        await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
      }
      return;
    }
    if (index == 10) {
      // Economic calendar
      const url =
          'https://play.google.com/store/apps/details?id=net.metaquotes.economiccalendar';
      if (await canLaunchUrl(Uri.parse(url))) {
        await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
      }
      return;
    }
    if (index == 11) {
      // Traders Community
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const RegisterScreen()),
      );
      return;
    }
    if (index == 6) {
      // News
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const NewsScreen()),
      );
      return;
    }
    if (index == 8) {
      // Journal
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const JournalScreen()),
      );
      return;
    }
    if (index == 7) {
      // Mailbox
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const MailboxScreen()),
      );
      return;
    }
    // Call the callback for other items
    onItemSelected?.call(index);
  }

  void _logout(BuildContext context) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    try {
      await authProvider.logout();

      // Check if widget is still mounted before using context
      if (context.mounted) {
        Navigator.of(context).pop(); // Close drawer

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Successfully logged out'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      // Check if widget is still mounted before using context
      if (context.mounted) {
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Logout failed: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
