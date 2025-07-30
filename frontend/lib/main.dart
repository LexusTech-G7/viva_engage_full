import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'controllers/theme_controller.dart';
import 'screens/login.dart';
import 'screens/dashboard.dart';
import 'screens/post_detail_screen.dart';
import 'models/user.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final themeCtrl = ThemeController();
  await themeCtrl.load();

  runApp(
    ChangeNotifierProvider.value(
      value: themeCtrl,
      child: const VivaEngageApp(),
    ),
  );
}

class VivaEngageApp extends StatelessWidget {
  const VivaEngageApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeCtrl = context.watch<ThemeController>();

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Viva Engage',
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.blue),
      darkTheme: ThemeData.dark(useMaterial3: true),
      themeMode: themeCtrl.mode,
      home: const LoginScreen(),
      routes: {
        '/postDetail': (context) {
          final args = ModalRoute.of(context)?.settings.arguments
              as Map<String, dynamic>?;

          final user = args?['currentUser'] as User?;
          final postID = args?['postID'] as int?;

          if (user == null || postID == null) {
            return Scaffold(
              appBar: AppBar(title: const Text('Lỗi')),
              body: const Center(
                child: Text('Thiếu thông tin bài viết hoặc người dùng'),
              ),
            );
          }

          return PostDetailScreen(
            currentUser: user,
            postID: postID,
          );
        },
      },
    );
  }
}
