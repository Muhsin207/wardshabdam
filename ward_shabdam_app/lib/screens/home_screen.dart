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
    const primaryColor = Color(0xFF0D5C3A);
    const accentAmber = Color(0xFFD97706);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text("Wardshabdam"),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            tooltip: "Notifications",
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => NotificationsScreen(mobile: mobile)),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            tooltip: "Logout",
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (_) => false,
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Citizen Greeting & Panchayat Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF064E3B), Color(0xFF0D5C3A)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF0D5C3A).withValues(alpha: 0.25),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.18),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          "തച്ചനാട്ടുകര പഞ്ചായത്ത്",
                          style: TextStyle(
                            color: Color(0xFFA7F3D0),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const Icon(Icons.verified_user_rounded, color: Color(0xFFFCD34D), size: 20),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "സ്വാഗതം, $fullname 👋",
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Phone: $mobile",
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.white.withValues(alpha: 0.85),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Primary Actions (Submit Grievance & Track)
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const SubmitComplaintScreen(),
                        ),
                      );
                    },
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF3C7),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFFDE68A)),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFB45309).withValues(alpha: 0.06),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: accentAmber,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.campaign_rounded, color: Colors.white, size: 24),
                          ),
                          const SizedBox(height: 14),
                          const Text(
                            "പരാതി നൽകുക",
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF92400E),
                            ),
                          ),
                          const SizedBox(height: 2),
                          const Text(
                            "Report Issue",
                            style: TextStyle(fontSize: 12, color: Color(0xFFB45309)),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => MyComplaintsScreen(mobile: mobile),
                        ),
                      );
                    },
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEBF7EE),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFA7F3D0)),
                        boxShadow: [
                          BoxShadow(
                            color: primaryColor.withValues(alpha: 0.06),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: primaryColor,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.track_changes_rounded, color: Colors.white, size: 24),
                          ),
                          const SizedBox(height: 14),
                          const Text(
                            "പരാതി ട്രാക്കിംഗ്",
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF065F46),
                            ),
                          ),
                          const SizedBox(height: 2),
                          const Text(
                            "My Complaints",
                            style: TextStyle(fontSize: 12, color: Color(0xFF047857)),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 28),

            const Text(
              "പഞ്ചായത്ത് സേവനങ്ങൾ / Civic Services",
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: Color(0xFF0F172A),
                letterSpacing: -0.2,
              ),
            ),

            const SizedBox(height: 14),

            // Services Grid
            GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              childAspectRatio: 1.35,
              children: [
                _buildServiceCard(
                  icon: Icons.campaign_outlined,
                  title: "അറിയിപ്പുകൾ",
                  subtitle: "Announcements",
                  iconColor: const Color(0xFF2563EB),
                  bgColor: const Color(0xFFEFF6FF),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AnnouncementsScreen()),
                  ),
                ),
                _buildServiceCard(
                  icon: Icons.event_available_outlined,
                  title: "പരിപാടികൾ",
                  subtitle: "Programs",
                  iconColor: const Color(0xFF7C3AED),
                  bgColor: const Color(0xFFF5F3FF),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ProgramsScreen()),
                  ),
                ),
                _buildServiceCard(
                  icon: Icons.how_to_vote_outlined,
                  title: "സർവേകൾ",
                  subtitle: "Surveys & Polls",
                  iconColor: const Color(0xFFD97706),
                  bgColor: const Color(0xFFFFFBEB),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => SurveyScreen(mobile: mobile)),
                  ),
                ),
                _buildServiceCard(
                  icon: Icons.groups_outlined,
                  title: "വാർഡ് അംഗങ്ങൾ",
                  subtitle: "Ward Members",
                  iconColor: const Color(0xFF0D9488),
                  bgColor: const Color(0xFFF0FDFA),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const WardMembersScreen()),
                  ),
                ),
                _buildServiceCard(
                  icon: Icons.description_outlined,
                  title: "സർക്കുലറുകൾ",
                  subtitle: "Circulars",
                  iconColor: const Color(0xFF475569),
                  bgColor: const Color(0xFFF1F5F9),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const CircularsScreen()),
                  ),
                ),
                _buildServiceCard(
                  icon: Icons.file_download_outlined,
                  title: "ഡൗൺലോഡുകൾ",
                  subtitle: "Downloads",
                  iconColor: const Color(0xFF0284C7),
                  bgColor: const Color(0xFFF0F9FF),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const DownloadsScreen()),
                  ),
                ),
                _buildServiceCard(
                  icon: Icons.photo_library_outlined,
                  title: "ഫോട്ടോ ഗാലറി",
                  subtitle: "Gallery",
                  iconColor: const Color(0xFFDB2777),
                  bgColor: const Color(0xFFFDF2F8),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const GalleryScreen()),
                  ),
                ),
                _buildServiceCard(
                  icon: Icons.person_outline_rounded,
                  title: "എന്റെ പ്രൊഫൈൽ",
                  subtitle: "My Profile",
                  iconColor: primaryColor,
                  bgColor: const Color(0xFFECFDF5),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ProfileScreen(
                        fullname: fullname,
                        mobile: mobile,
                        email: email,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color iconColor,
    required Color bgColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE2E8F0)),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0F172A).withValues(alpha: 0.03),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: iconColor, size: 22),
            ),
            const Spacer(),
            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Color(0xFF0F172A),
              ),
            ),
            Text(
              subtitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 11,
                color: Color(0xFF64748B),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}