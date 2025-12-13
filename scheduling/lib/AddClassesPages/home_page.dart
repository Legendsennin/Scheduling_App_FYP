import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    // 1. Base Structure: Stack used to layer the blue background behind content
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // A. The Top Blue Background Decoration
          Container(
            height: 280,
            decoration: const BoxDecoration(
              color: Color(0xFF4A7BEE), // The primary blue from your design
            ),
          ),

          // B. The Scrollable Content
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  // 1. Header (Greeting + Profile)
                  _buildHeader(context),

                  const SizedBox(height: 30),
                  // 2. Task Dashboard (Dark Card)
                  _buildTaskDashboard(),

                  const SizedBox(height: 30),
                  // 3. Classes Section (Horizontal Scroll)
                  Text(
                    "Classes",
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    "Recommendations for you",
                    style: GoogleFonts.poppins(color: Colors.grey),
                  ),
                  const SizedBox(height: 15),
                  _buildClassesList(),

                  const SizedBox(height: 30),
                  // 4. Schedule Section (Side-by-side columns)
                  Text(
                    "Schedule",
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 15),
                  _buildScheduleSection(),

                  // Extra space for the bottom floating nav
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),

          // C. Custom Floating Bottom Navigation Bar
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: _buildCustomBottomNav(),
          ),
        ],
      ),
    );
  }

  // --- WIDGET COMPONENTS ---

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Hello Shaf",
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Text(
              "Mei 27, 2022",
              style: GoogleFonts.poppins(fontSize: 14, color: Colors.white70),
            ),
          ],
        ),
        // Profile Picture with Interaction
        GestureDetector(
          onTap: () {
            // Logic: Redirect to Profile Page
            print("Navigate to Profile");
            // Navigator.pushNamed(context, '/profile');
          },
          child: Container(
            height: 50,
            width: 50,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
              image: const DecorationImage(
                // Replace with your asset image
                image: NetworkImage('https://i.pravatar.cc/150?img=5'),
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTaskDashboard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: const Color(0xFF16171D), // Dark background color
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Text(
            "Task",
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildTaskStat("Overall", "5", Colors.white),
              _buildTaskStat("Today", "1", Colors.yellow),
              _buildTaskStat("Overdue", "2", Colors.redAccent),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTaskStat(String label, String count, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(color: Colors.white70, fontSize: 14),
        ),
        const SizedBox(height: 10),
        Text(
          count,
          style: GoogleFonts.poppins(
            color: color,
            fontSize: 36,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildClassesList() {
    // SingleChildScrollView with horizontal scrolling
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildClassCard(
            "DSF",
            Icons.calculate_outlined,
            const Color(0xFFFF7E55), // Orange
            const Color(0xFFFFB280), // Light Orange accent
          ),
          _buildClassCard(
            "Req. Engineering",
            Icons.language,
            const Color(0xFF8F9BFF), // Purple/Blue
            const Color(0xFF2E3A8C), // Dark Blue accent
          ),
          _buildClassCard(
            "Design",
            Icons.brush,
            const Color(0xFFFFCC80), // Yellow
            const Color(0xFFFFA726), // Orange accent
          ),
        ],
      ),
    );
  }

  Widget _buildClassCard(
    String title,
    IconData icon,
    Color mainColor,
    Color accentColor,
  ) {
    return Container(
      margin: const EdgeInsets.only(right: 15),
      width: 140,
      height: 100,
      decoration: BoxDecoration(
        color: mainColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Stack(
        children: [
          // Decorative circle in top right
          Positioned(
            right: -20,
            top: -20,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: accentColor.withOpacity(0.5),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon, color: Colors.white, size: 28),
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleSection() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: _buildScheduleCard(
            "Upcoming classes",
            "Software Test",
            "(Noor Azila)",
            "10.00 a.m - 11.20 a.m",
            "LR14",
            isQuiz: false,
          ),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: _buildScheduleCard(
            "Upcoming quiz",
            "Software Test",
            "",
            "10.00 a.m - 11.20 a.m",
            "LR14",
            isQuiz: true,
            date: "11/5/2025",
          ),
        ),
      ],
    );
  }

  Widget _buildScheduleCard(
    String header,
    String title,
    String sub,
    String time,
    String loc, {
    bool isQuiz = false,
    String? date,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          header,
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 14),
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF8F9BFF),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              if (sub.isNotEmpty)
                Text(
                  sub,
                  style: GoogleFonts.poppins(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
              const SizedBox(height: 15),

              if (isQuiz && date != null) ...[
                _buildScheduleRow(Icons.calendar_today, date),
                const SizedBox(height: 8),
              ],

              _buildScheduleRow(Icons.access_time, time),
              const SizedBox(height: 8),
              _buildScheduleRow(Icons.location_on, loc),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildScheduleRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: Colors.white70, size: 14),
        const SizedBox(width: 5),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.poppins(color: Colors.white, fontSize: 11),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  // Custom Bottom Navigation Bar to look "Floating"
  Widget _buildCustomBottomNav() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 5,
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _navItem(Icons.home, "Home", true),
          _navItem(Icons.calendar_today, "Calendar", false),
          _navItem(Icons.book, "Tasks", false),
          _navItem(Icons.school, "Classes", false),
          _navItem(Icons.folder_open, "Folders", false),
        ],
      ),
    );
  }

  Widget _navItem(IconData icon, String label, bool isActive) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          color: isActive ? const Color(0xFF4A7BEE) : Colors.grey,
          size: 24,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 10,
            color: isActive ? const Color(0xFF4A7BEE) : Colors.grey,
          ),
        ),
      ],
    );
  }
}
