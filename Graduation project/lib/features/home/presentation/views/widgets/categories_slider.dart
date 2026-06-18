// import 'package:carousel_slider/carousel_slider.dart';
// import 'package:flutter/material.dart';
// import 'package:pickutopia/core/utils/assets.dart';
// import 'package:pickutopia/features/chatbot/presentation/views/anime_chatbot_view.dart';
// import 'package:pickutopia/features/chatbot/presentation/views/books_chatbot_view.dart';
// import 'package:pickutopia/features/chatbot/presentation/views/games_chatbot_view.dart';
// import 'package:pickutopia/features/chatbot/presentation/views/movies_chatbot_view.dart';
// import 'package:pickutopia/features/chatbot/presentation/views/music_chatbot_view.dart';
// import 'package:pickutopia/features/chatbot/presentation/views/tvshows_chatbot_view.dart';
// import 'category.dart';

// class CategoriesSlider extends StatelessWidget {
//   const CategoriesSlider({
//     super.key,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return CarouselSlider(
//       items: [
//         Category(
//           imagePath: AssetsData.movieCategory,
//           categoryName: "Movies",
//           onTap: () {
//             Navigator.pushNamed(context, MoviesChatBotPage.id);
//           },
//         ),
//         Category(
//           imagePath: AssetsData.tvShowsCategory,
//           categoryName: "Tv Shows",
//           onTap: () {
//             Navigator.pushNamed(context, TvShowsChatBotPage.id);
//           },
//         ),
//         Category(
//           imagePath: AssetsData.animeCategory,
//           categoryName: "Anime",
//           onTap: () {
//             Navigator.pushNamed(context, AnimeChatBotPage.id);
//           },
//         ),
//         Category(
//           imagePath: AssetsData.musicCategory,
//           categoryName: "Music",
//           onTap: () {
//             Navigator.pushNamed(context, MusicChatBotPage.id);
//           },
//         ),
//         Category(
//           imagePath: AssetsData.gamesCategory,
//           categoryName: "Games",
//           onTap: () {
//             Navigator.pushNamed(context, GamesChatBotPage.id);
//           },
//         ),
//         Category(
//           imagePath: AssetsData.booksCategory,
//           categoryName: "Books",
//           onTap: () {
//             Navigator.pushNamed(context, BooksChatBotPage.id);
//           },
//         ),
//       ],
//       options: CarouselOptions(
//         aspectRatio: 3,
//         initialPage: 0,
//         viewportFraction: 0.4,
//         enableInfiniteScroll: false,
//         padEnds: false,
//       ),
//     );
//   }
// }
