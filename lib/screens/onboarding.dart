import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dotted_border/dotted_border.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFF7A21),
      body: Stack(
        children: [
          Positioned(
            top: 80,
            left: 40,
            child: Opacity(
              opacity: 0.10,
              child: Icon(Icons.pets, size: 70, color: Colors.white),
            ),
          ),
          Positioned(
            top: 160,
            right: 40,
            child: Opacity(
              opacity: 0.10,
              child: Icon(Icons.pets, size: 50, color: Colors.white),
            ),
          ),
          Positioned(
            top: 180,
            left: 90,
            child: Opacity(
              opacity: 0.08,
              child: Icon(Icons.pets, size: 40, color: Colors.white),
            ),
          ),

          Positioned(
            top: 20,
            right: 120,
            child: Opacity(opacity: 0.06, child: Icon(Icons.pets, size: 90, color: Colors.white)),
          ),
          Positioned(
            top: 260,
            left: 10,
            child: Opacity(opacity: 0.05, child: Icon(Icons.pets, size: 60, color: Colors.white)),
          ),
          Positioned(
            top: 360,
            right: 10,
            child: Opacity(opacity: 0.04, child: Icon(Icons.pets, size: 50, color: Colors.white)),
          ),
          Positioned(
            bottom: 260,
            left: 30,
            child: Opacity(opacity: 0.05, child: Icon(Icons.pets, size: 48, color: Colors.white)),
          ),
          Positioned(
            bottom: 300,
            right: 80,
            child: Opacity(opacity: 0.06, child: Icon(Icons.pets, size: 72, color: Colors.white)),
          ),

          Positioned(
              top: 100,
            left: 0,
            right: 0,
            child: Center(
              child: Image.asset(
                "assets/images/image1.png",
                height: 500,
                width: 700,
                fit: BoxFit.contain,
              ),
            ),
          ),

          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: ClipPath(
              clipper: BottomWaveClipper(),
              child: Container(
                height: 380,
                color: Colors.white,
              ),
            ),
          ),

          Positioned(
            bottom: 100,
            left: 0,
            right: 0,
            child: Column(
              children: [
                Text(
                  "Proud to Be an",
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  "Adoptive Pet Hero",
                  style: GoogleFonts.poppins(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  "Looking for unconditional Love?\nVisit the shelter today!",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    height: 1.4,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 30),

                _dashedButton(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _dashedButton(BuildContext context) {
    return GestureDetector(
      onTap: () {
        debugPrint('Onboarding: Get Started tapped');
        Navigator.pushReplacementNamed(context, '/login');
      },
      child: DottedBorder(
        dashPattern: const [6, 6],
        color: const Color(0xFFFF7A21),
        strokeWidth: 2,
        borderType: BorderType.RRect,
        radius: const Radius.circular(40),
        child: Container(
          width: 300,
          height: 64,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(40),
          ),
          child: Stack(
            alignment: Alignment.centerLeft,
            children: [
              Positioned(
                left: -18,
                child: Container(
                  width: 100,
                  height: 64,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF7A21),
                    borderRadius: BorderRadius.circular(40),
                      boxShadow: [
                      BoxShadow(
                        color: Color.fromRGBO(0, 0, 0, 0.08),
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                ),
              ),

              Positioned(
                left: 6,
                child: Container(
                  width: 64,
                  height: 64,
                  alignment: Alignment.center,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(color: const Color(0xFFFF7A21), width: 3),
                        ),
                      ),
                      Container(
                        width: 34,
                        height: 34,
                        decoration: const BoxDecoration(
                          color: Color(0xFFFF7A21),
                          shape: BoxShape.circle,
                        ),
                        child: const Center(
                          child: Icon(Icons.pets, color: Colors.white, size: 18),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              Positioned(
                left: 100,
                right: 20,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Get Started',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// =======================================================
// WAVE SHAPE
// =======================================================
class BottomWaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height * 0.15);

    path.quadraticBezierTo(
      size.width * 0.5, -60,
      size.width,
      size.height * 0.15,
    );

    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);

    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

class DashedBorderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const dashWidth = 8;
    const dashSpace = 6;

    final paint = Paint()
      ..color = const Color(0xFFFF7A21)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    double x = 0;
    while (x < size.width) {
      canvas.drawLine(Offset(x, 0), Offset(x + dashWidth, 0), paint);
      canvas.drawLine(Offset(x, size.height), Offset(x + dashWidth, size.height), paint);
      x += dashWidth + dashSpace;
    }

    double y = 0;
    while (y < size.height) {
      canvas.drawLine(Offset(0, y), Offset(0, y + dashWidth), paint);
      canvas.drawLine(Offset(size.width, y), Offset(size.width, y + dashWidth), paint);
      y += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}