import 'package:flutter/material.dart';
import 'announcements_screen.dart';
import 'circulars_screen.dart';
import 'downloads_screen.dart';
import 'gallery_screen.dart';
import 'login_screen.dart';
import 'my_complaints_screen.dart';
import 'notifications_screen.dart';
import 'profile_screen.dart';
import 'programs_screen.dart';
import 'submit_complaint_screen.dart';
import 'survey_screen.dart';
import 'ward_members_screen.dart';
import '../widgets/dashboard_card.dart';

class HomeScreen extends StatelessWidget {
  final String fullname;
  final String mobile;
  final String email;

  const HomeScreen({
    super.key,
    required this.fullname,
    required this.mobile,
    required this.email,
  });

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Logout"),
        content: const Text("Are you sure you want to log out?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (_) => false,
              );
            },
            child: const Text("Logout", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> menuItems = [
      {
        "title": "Announcements",
        "icon": Icons.campaign,
        "color": Colors.green,
        "action": (BuildContext ctx) => Navigator.push(
              ctx,
              MaterialPageRoute(builder: (_) => const AnnouncementsScreen()),
            ),
      },
      {
        "title": "Programs",
        "icon": Icons.event,
        "color": Colors.blue,
        "action": (BuildContext ctx) => Navigator.push(
              ctx,
              MaterialPageRoute(builder: (_) => const ProgramsScreen()),
            ),
      },
      {
        "title": "Downloads",
        "icon": Icons.download,
        "color": Colors.indigo,
        "action": (BuildContext ctx) => Navigator.push(
              ctx,
              MaterialPageRoute(builder: (_) => const DownloadsScreen()),
            ),
      },
      {
        "title": "Circulars",
        "icon": Icons.article,
        "color": Colors.orange,
        "action": (BuildContext ctx) => Navigator.push(
              ctx,
              MaterialPageRoute(builder: (_) => const CircularsScreen()),
            ),
      },
      {
        "title": "Gallery",
        "icon": Icons.photo_library,
        "color": Colors.purple,
        "action": (BuildContext ctx) => Navigator.push(
              ctx,
              MaterialPageRoute(builder: (_) => const GalleryScreen()),
            ),
      },
      {
        "title": "Notifications",
        "icon": Icons.notifications,
        "color": Colors.amber.shade800,
        "action": (BuildContext ctx) => Navigator.push(
              ctx,
              MaterialPageRoute(builder: (_) => NotificationsScreen(mobile: mobile)),
            ),
      },
      {
        "title": "Survey",
        "icon": Icons.poll,
        "color": Colors.teal,
        "action": (BuildContext ctx) => Navigator.push(
              ctx,
              MaterialPageRoute(builder: (_) => SurveyScreen(mobile: mobile)),
            ),
      },
      {
        "title": "Ward Members",
        "icon": Icons.people,
        "color": Colors.cyan.shade800,
        "action": (BuildContext ctx) => Navigator.push(
              ctx,
              MaterialPageRoute(builder: (_) => const WardMembersScreen()),
            ),
      },
      {
        "title": "Submit Complaint",
        "icon": Icons.report_problem,
        "color": Colors.red,
        "action": (BuildContext ctx) => Navigator.push(
              ctx,
              MaterialPageRoute(builder: (_) => const SubmitComplaintScreen()),
            ),
      },
      {
        "title": "My Complaints",
        "icon": Icons.list_alt,
        "color": Colors.deepOrange,
        "action": (BuildContext ctx) => Navigator.push(
              ctx,
              MaterialPageRoute(builder: (_) => MyComplaintsScreen(mobile: mobile)),
            ),
      },
      {
        "title": "My Profile",
        "icon": Icons.person,
        "color": Colors.blueGrey,
        "action": (BuildContext ctx) => Navigator.push(
              ctx,
              MaterialPageRoute(
                builder: (_) => ProfileScreen(
                  fullname: fullname,
                  mobile: mobile,
                  email: email,
                ),
              ),
            ),
      },
      {
        "title": "Logout",
        "icon": Icons.logout,
        "color": Colors.redAccent,
        "action": (BuildContext ctx) => _confirmLogout(ctx),
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Ward Shabdam"),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: "Logout",
            onPressed: () => _confirmLogout(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              color: Theme.of(context).primaryColor.withValues(alpha: 0.08),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: Theme.of(context).primaryColor,
                      child: const Icon(Icons.person, color: Colors.white),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Welcome,",
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade700,
                            ),
                          ),
                          Text(
                            fullname.isNotEmpty ? fullname : "Citizen",
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              "Services & Updates",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: menuItems.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.15,
              ),
              itemBuilder: (context, index) {
                final item = menuItems[index];
                return DashboardCard(
                  icon: item["icon"] as IconData,
                  title: item["title"] as String,
                  color: item["color"] as Color,
                  onTap: () => (item["action"] as Function(BuildContext))(context),
                );
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
