import 'package:flutter/material.dart';

class SideDrawer extends StatelessWidget {
  final void Function(int)? onItemSelected;
  const SideDrawer({Key? key, this.onItemSelected}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: const Color(0xFF1E1F23),
      child: ListView(
        padding: const EdgeInsets.symmetric(vertical: 16),
        children: [
          ListTile(
            leading: const CircleAvatar(child: Icon(Icons.person)),
            title: const Text(
              "Hemant Agrawal",
              style: TextStyle(color: Colors.white),
            ),
            subtitle: const Text(
              "5036996148 - MetaQuotes-Demo",
              style: TextStyle(color: Colors.white54),
            ),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Text(
                "Demo",
                style: TextStyle(fontSize: 10, color: Colors.white),
              ),
            ),
          ),
          const Divider(color: Colors.white24),
          _drawerItem(
            Icons.import_export,
            "Quotes",
            onTap: () => _select(context, 0),
          ),
          _drawerItem(
            Icons.candlestick_chart,
            "Charts",
            onTap: () => _select(context, 1),
          ),
          _drawerItem(
            Icons.show_chart,
            "Trade",
            onTap: () => _select(context, 2),
          ),
          _drawerItem(
            Icons.history,
            "History",
            onTap: () => _select(context, 3),
          ),
          _drawerItem(
            Icons.message,
            "Messages",
            onTap: () => _select(context, 4),
          ),
          _drawerItem(
            Icons.newspaper,
            "News",
            onTap: () => _select(context, 1),
          ),
          _drawerItem(
            Icons.mail,
            "Mailbox",
            trailing: const CircleAvatar(
              radius: 10,
              child: Text("8", style: TextStyle(fontSize: 12)),
            ),
            onTap: () => _select(context, 2),
          ),
          _drawerItem(Icons.book, "Journal", onTap: () => _select(context, 3)),
          _drawerItem(
            Icons.settings,
            "Settings",
            onTap: () => _select(context, 4),
          ),
          _drawerItem(
            Icons.calendar_today,
            "Economic calendar",
            trailing: _adsTag(),
            onTap: () => _select(context, 5),
          ),
          _drawerItem(
            Icons.groups,
            "Traders Community",
            onTap: () => _select(context, 6),
          ),
          _drawerItem(
            Icons.auto_graph,
            "MQL5 Algo Trading",
            onTap: () => _select(context, 7),
          ),
          _drawerItem(
            Icons.help_outline,
            "User guide",
            onTap: () => _select(context, 8),
          ),
          _drawerItem(
            Icons.info_outline,
            "About",
            onTap: () => _select(context, 9),
          ),
        ],
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

  void _select(BuildContext context, int index) {
    onItemSelected?.call(index);
    Navigator.of(context).pop(); // Close the drawer
  }
}
