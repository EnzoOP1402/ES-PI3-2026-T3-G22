import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';


class CustomOutlinedButton extends StatelessWidget {
  final String text;
  final IconData icon;
  final Widget page;

  final Color color;
  final double width;

  const CustomOutlinedButton({
    super.key,
    required this.text,
    required this.icon,
    required this.page,
    this.color = const Color(0xFF353988),
    this.width = 250,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: width,
        child: OutlinedButton.icon(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => page,
              ),
            );
          },
          icon: Icon(
            icon,
            color: color,
          ),
          label: Text(
            text,
            style: GoogleFonts.montserrat(
              color: color,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(
              vertical: 12,
            ),
            side: BorderSide(
              color: color,
              width: 2,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        ),
      ),
    );
  }
}