import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/user.dart';
import '../controllers/theme_controller.dart';

class ProfileScreen extends StatelessWidget {
  final User user;
  final bool isCurrentUser;

  const ProfileScreen({
    super.key,
    required this.user,
    this.isCurrentUser = true,
  });

  @override
  Widget build(BuildContext context) {
    final themeCtrl = context.watch<ThemeController>();

    return Scaffold(
      appBar: AppBar(
        title: Text(isCurrentUser ? 'Trang cá nhân của bạn' : 'Trang cá nhân'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: CircleAvatar(
                radius: 50,
                backgroundImage:
                    user.avatarURL != null && user.avatarURL!.isNotEmpty
                        ? NetworkImage(user.avatarURL!)
                        : null,
                child: (user.avatarURL == null || user.avatarURL!.isEmpty)
                    ? Text(
                        user.name[0].toUpperCase(),
                        style: const TextStyle(fontSize: 40),
                      )
                    : null,
              ),
            ),
            const SizedBox(height: 16),
            Center(
                child: Text(user.name,
                    style: Theme.of(context).textTheme.titleLarge)),
            Center(
                child: Text(user.email,
                    style: const TextStyle(color: Colors.grey))),
            const Divider(height: 32),
            ListTile(
              leading: const Icon(Icons.badge),
              title: const Text('Vai trò'),
              subtitle: Text(
                user.role.name[0].toUpperCase() + user.role.name.substring(1),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.apartment),
              title: const Text('Phòng ban'),
              subtitle: Text(user.department),
            ),
            ListTile(
              leading: const Icon(Icons.calendar_today),
              title: const Text('Ngày tham gia'),
              subtitle: Text(user.createdAt.toLocal().toString().split(' ')[0]),
            ),
            ListTile(
              leading: const Icon(Icons.info),
              title: const Text('Trạng thái'),
              subtitle: Text(user.status),
            ),
            const Divider(height: 32),
            ListTile(
              leading: const Icon(Icons.brightness_6),
              title: Text(themeCtrl.mode == ThemeMode.dark
                  ? 'Chuyển sang giao diện sáng'
                  : 'Chuyển sang giao diện tối'),
              trailing: Switch(
                value: themeCtrl.mode == ThemeMode.dark,
                onChanged: (_) => themeCtrl.toggle(),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Đóng'),
            ),
          ],
        ),
      ),
    );
  }
}
