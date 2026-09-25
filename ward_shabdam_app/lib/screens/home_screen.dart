import 'package:flutter/material.dart';
import 'submit_complaint_screen.dart';
import 'my_complaints_screen.dart';
import 'announcements_screen.dart';
import 'programs_screen.dart';
import 'ward_members_screen.dart';
import 'downloads_screen.dart';
import 'circulars_screen.dart';
import 'gallery_screen.dart';
import 'notifications_screen.dart';
import 'survey_screen.dart';
import 'profile_screen.dart';
import 'login_screen.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Wardshabdam"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
  child: Padding(
    padding: const EdgeInsets.all(16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Welcome, $fullname 👋",
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 25),

        DashboardCard(
          icon: Icons.campaign,
          title: "Announcements",
          color: Colors.green,
          onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const AnnouncementsScreen(),
                ),
              );
            },
        ),

        Card(
          child: ListTile(
            leading: const Icon(Icons.event),
            title: const Text("Programs"),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const ProgramsScreen(),
                ),
              );
            },
          ),
        ),

        Card(
          child: ListTile(
            leading: const Icon(Icons.download),
            title: const Text("Downloads"),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const DownloadsScreen()),
            ),
          ),
        ),

        Card(
          child: ListTile(
            leading: const Icon(Icons.article),
            title: const Text("Circulars"),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CircularsScreen()),
            ),
          ),
        ),

        Card(
          child: ListTile(
            leading: const Icon(Icons.photo_library),
            title: const Text("Gallery"),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const GalleryScreen()),
            ),
          ),
        ),

        Card(
          child: ListTile(
            leading: const Icon(Icons.notifications),
            title: const Text("Notifications"),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => NotificationsScreen(mobile: mobile)),
            ),
          ),
        ),

        Card(
          child: ListTile(
            leading: const Icon(Icons.poll),
            title: const Text("Survey"),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => SurveyScreen(mobile: mobile)),
            ),
          ),
        ),

        Card(
          child: ListTile(
            leading: const Icon(Icons.people),
            title: const Text("Ward Members"),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const WardMembersScreen(),
                ),
              );
            },
          ),
        ),

        Card(
          child: ListTile(
            leading: const Icon(Icons.report_problem),
            title: const Text("Submit Complaint"),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const SubmitComplaintScreen(),
                ),
              );
            },
          ),
        ),

        Card(
          child: ListTile(
            leading: const Icon(Icons.list_alt),
            title: const Text("My Complaints"),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => MyComplaintsScreen(mobile: mobile),
                ),
              );
            },
          ),
        ),

        Card(
          child: ListTile(
            leading: const Icon(Icons.person),
            title: const Text("My Profile"),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ProfileScreen(
                    fullname: fullname,
                    mobile: mobile,
                    email: email,
                  ),
                ),
              );
            },
          ),
        ),

        Card(
          child: ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text(
              "Logout",
              style: TextStyle(color: Colors.red),
            ),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (_) => false,
              );
            },
          ),
        ),

        const SizedBox(height: 20),
      ],
    ),
  ),
      ),
    );
  }
}