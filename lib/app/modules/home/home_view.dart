import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../routes/app_pages.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ResumeYar'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          _NavigationTile(title: 'Profile', route: Routes.profile),
          _NavigationTile(title: 'Work Experience', route: Routes.work),
          _NavigationTile(title: 'Education', route: Routes.education),
          _NavigationTile(title: 'Skills', route: Routes.skills),
          _NavigationTile(title: 'Projects', route: Routes.projects),
        ],
      ),
    );
  }
}

class _NavigationTile extends StatelessWidget {
  const _NavigationTile({required this.title, required this.route});

  final String title;
  final String route;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(title),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => Get.toNamed(route),
      ),
    );
  }
}
