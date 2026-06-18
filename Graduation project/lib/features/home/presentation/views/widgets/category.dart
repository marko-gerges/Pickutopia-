// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';

// class Category extends StatelessWidget {
//   const Category({
//     super.key,
//     required this.imagePath,
//     required this.categoryName,
//     required this.onTap,
//   });

//   final String imagePath;
//   final String categoryName;
//   final void Function() onTap;

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Stack(
//         children: [
//           Center(
//             child: Container(
//               height: 120,
//               width: 120,
//               decoration: BoxDecoration(
//                 borderRadius: BorderRadius.circular(10),
//               ),
//               child: ClipRRect(
//                 borderRadius: BorderRadius.circular(10),
//                 child: Image(
//                   image: AssetImage(
//                     imagePath,
//                   ),
//                   fit: BoxFit.cover,
//                 ),
//               ),
//             ),
//           ),
//           Positioned(
//             top: 90,
//             left: 25,
//             child: Text(
//               categoryName,
//               style: GoogleFonts.lexend(
//                 color: Colors.white,
//                 fontWeight: FontWeight.w600,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CategoryCard extends StatelessWidget {
  final String name;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const CategoryCard({
    super.key,
    required this.name,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: const Color(0xFF1B1437), // Darker card color
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 8),
            Text(
              name,
              style: GoogleFonts.lexend(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }
}
