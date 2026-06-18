// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:animated_emoji/emoji.dart';
// import 'package:animated_emoji/emojis.g.dart';
// import 'package:auto_size_text/auto_size_text.dart';
// import 'package:pickutopia/core/utils/constants.dart';
// import 'package:pickutopia/features/userprofile/presentation/views/userprofile_view.dart';

// class CustomAppBar extends StatelessWidget {
//   const CustomAppBar({
//     super.key,
//     required this.userName,
//     required this.userAvatarUrl,
//   });

//   final String userName;
//   final String userAvatarUrl;

//   @override
//   Widget build(BuildContext context) {
//     final double screenWidth = MediaQuery.of(context).size.width;

//     return Padding(
//       padding: EdgeInsets.symmetric(
//         horizontal: screenWidth * 0.05,
//         vertical: 16,
//       ),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   'Welcome',
//                   style: GoogleFonts.lexend(
//                     fontSize: screenWidth * 0.07,
//                     color: kMainColor,
//                   ),
//                 ),
//                 Row(
//                   children: [
//                     Flexible(
//                       child: AutoSizeText(
//                         userName,
//                         maxLines: 1,
//                         overflow: TextOverflow.ellipsis,
//                         style: GoogleFonts.lexend(
//                           fontSize: screenWidth * 0.06,
//                           color: kMainColor,
//                         ),
//                       ),
//                     ),
//                     const SizedBox(width: 6),
//                     AnimatedEmoji(
//                       AnimatedEmojis.wave,
//                       size: screenWidth * 0.08,
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//           GestureDetector(
//             onTap: () {
//               Navigator.pushNamed(context, UserProfilePage.id);
//             },
//             child: ClipOval(
//               child: Image.network(
//                 userAvatarUrl,
//                 width: 48,
//                 height: 48,
//                 fit: BoxFit.cover,
//                 errorBuilder: (context, error, stackTrace) {
//                   return Image.asset(
//                     'assets/default_avatar.png',
//                     width: 48,
//                     height: 48,
//                     fit: BoxFit.cover,
//                   );
//                 },
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pickutopia/features/userprofile/presentation/views/userprofile_view.dart';

class CustomAppBar extends StatelessWidget {
  final String? userAvatarUrl;

  const CustomAppBar({
    super.key,
    this.userAvatarUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'PICKUTOPIA',
                style: GoogleFonts.lexend(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF9D50FF), // Primary brand color
                  letterSpacing: 1.2,
                ),
              ),
              Text(
                'VibeChoice',
                style: GoogleFonts.lexend(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          GestureDetector(
            onTap: () {
              Navigator.pushNamed(context, UserProfilePage.id);
            },
            child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white12, width: 2),
                ),
                child: CircleAvatar(
                  radius: 22,
                  backgroundColor: const Color(0xFF1B1437),
                  child: CachedNetworkImage(
                    imageUrl:
                        (userAvatarUrl != null && userAvatarUrl!.isNotEmpty)
                            ? userAvatarUrl!
                            : "",
                    imageBuilder: (context, imageProvider) => Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        image: DecorationImage(
                          image: imageProvider,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    placeholder: (context, url) => const Icon(Icons.person,
                        color: Colors.white70, size: 20),
                    errorWidget: (context, url, error) => const Icon(
                        Icons.person,
                        color: Colors.white70,
                        size: 20),
                  ),
                )),
          ),
        ],
      ),
    );
  }
}
