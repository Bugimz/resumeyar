import 'package:get/get.dart';

import '../modules/education/education_binding.dart';
import '../modules/education/education_view.dart';
import '../modules/home/home_view.dart';
import '../modules/profile/profile_binding.dart';
import '../modules/profile/profile_view.dart';
import '../modules/project/project_binding.dart';
import '../modules/project/project_view.dart';
import '../modules/skill/skill_binding.dart';
import '../modules/skill/skill_view.dart';
import '../modules/work/work_binding.dart';
import '../modules/work/work_view.dart';
import '../modules/settings/settings_view.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static const initial = Routes.home;

  static final routes = [
    GetPage(name: Routes.home, page: HomeView.new),
    GetPage(
      name: Routes.profile,
      page: ProfileView.new,
      binding: ProfileBinding(),
    ),
    GetPage(
      name: Routes.work,
      page: WorkView.new,
      binding: WorkBinding(),
    ),
    GetPage(
      name: Routes.education,
      page: EducationView.new,
      binding: EducationBinding(),
    ),
    GetPage(
      name: Routes.skills,
      page: SkillView.new,
      binding: SkillBinding(),
    ),
    GetPage(
      name: Routes.projects,
      page: ProjectView.new,
      binding: ProjectBinding(),
    ),
    GetPage(
      name: Routes.settings,
      page: SettingsView.new,
    ),
  ];
}
