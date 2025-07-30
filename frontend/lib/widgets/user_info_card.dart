import 'package:flutter/material.dart';
import '../models/user.dart';

class UserInfoCard extends StatelessWidget {
  final User user;
  const UserInfoCard({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 35,
            backgroundImage: user.avatarURL?.isNotEmpty == true
                ? NetworkImage(user.avatarURL!)
                : null,
            child: user.avatarURL?.isEmpty == true || user.avatarURL == null
                ? Text(
                    user.name.isNotEmpty ? user.name[0].toUpperCase() : "?",
                    style: const TextStyle(fontSize: 28),
                  )
                : null,
          ),
          const SizedBox(height: 12),
          Text(
            user.name,
            style: Theme.of(context).textTheme.titleLarge,
            textAlign: TextAlign.center,
          ),
          Text(
            user.email,
            style: const TextStyle(color: Colors.grey),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.apartment),
            title: Text("Phòng ban"),
            trailing: Text(user.department ?? "Không rõ"),
          ),
          ListTile(
            leading: const Icon(Icons.circle, size: 14, color: Colors.green),
            title: Text("Trạng thái"),
            trailing: Text(user.status ?? "Không rõ"),
          ),
        ],
      ),
    );
  }
}
