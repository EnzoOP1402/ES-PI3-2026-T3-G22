import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'menu_button.dart';

class ExploreButtonData {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  ExploreButtonData({
    required this.icon,
    required this.label,
    required this.onTap,
  });
}
class ExploreSection extends StatelessWidget {
  final String title;
  final List<ExploreButtonData> buttons;

  const ExploreSection({
    super.key,
    required this.title,
    required this.buttons,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          title,
          style: GoogleFonts.montserrat(
            color: Color(0xFF353988),
            fontSize: 24,
            fontWeight: FontWeight.w400,
          ),
        ),

        const SizedBox(height: 40),

        Wrap(
          spacing: 10,
          runSpacing: 10,
          alignment: WrapAlignment.center,
          children: buttons.map((button) {
            return MenuButton(
              icon: button.icon,
              label: button.label,
              onTap: button.onTap,
            );
          }).toList(),
        ),
      ],
    );
  }
}