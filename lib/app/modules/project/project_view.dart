import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../data/models/project.dart';
import '../../utils/validators.dart';
import '../../utils/widgets/section_card.dart';
import 'project_controller.dart';

class ProjectView extends GetView<ProjectController> {
  ProjectView({super.key});

  final _formKey = GlobalKey<FormState>();
  final TextEditingController profileIdController =
      TextEditingController(text: '1');
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController linkController = TextEditingController();
  final TextEditingController roleController = TextEditingController();
  final TextEditingController responsibilitiesController =
      TextEditingController();
  final TextEditingController techTagsController = TextEditingController();
  final TextEditingController demoLinkController = TextEditingController();
  final TextEditingController githubLinkController = TextEditingController();
  final TextEditingController liveLinkController = TextEditingController();
  final TextEditingController thumbnailController = TextEditingController();
  final Rxn<Project> editingProject = Rxn<Project>();
  final RxBool isFormValid = false.obs;
  final RxBool isFeatured = false.obs;

  void _resetForm() {
    editingProject.value = null;
    titleController.clear();
    descriptionController.clear();
    linkController.clear();
    roleController.clear();
    responsibilitiesController.clear();
    techTagsController.clear();
    demoLinkController.clear();
    githubLinkController.clear();
    liveLinkController.clear();
    thumbnailController.clear();
    isFeatured.value = false;
    isFormValid.value = false;
  }

  void _updateFormValidity() {
    final currentState = _formKey.currentState;
    if (currentState == null) {
      isFormValid.value = false;
      return;
    }

    isFormValid.value = currentState.validate();
  }

  int? _parseProfileId() {
    final profileId = int.tryParse(profileIdController.text);
    if (profileId == null) {
      Get.snackbar('error'.tr, 'invalid_number'.tr);
    }
    return profileId;
  }

  Future<void> _loadList() async {
    final profileId = _parseProfileId();
    if (profileId != null) {
      await controller.load(profileId);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final profileId = _parseProfileId();
    if (profileId == null) {
      return;
    }

    final project = Project(
      id: editingProject.value?.id,
      profileId: profileId,
      title: titleController.text,
      description: descriptionController.text,
      link: linkController.text,
      role: roleController.text,
      responsibilities: _splitLines(responsibilitiesController.text),
      techTags: _splitTags(techTagsController.text),
      demoLink: demoLinkController.text,
      githubLink: githubLinkController.text,
      liveLink: liveLinkController.text,
      thumbnailUrl: thumbnailController.text,
      isFeatured: isFeatured.value,
    );

    if (editingProject.value == null) {
      await controller.save(project);
    } else {
      await controller.updateProject(project);
    }

    _resetForm();
  }

  List<String> _splitLines(String value) {
    return value
        .split(RegExp(r'\r?\n'))
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .toList();
  }

  List<String> _splitTags(String value) {
    return value
        .split(RegExp(r'[\n,]'))
        .map((tag) => tag.trim())
        .where((tag) => tag.isNotEmpty)
        .toList();
  }

  Future<void> _launchLink(String url) async {
    if (url.isEmpty) return;
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      Get.snackbar('error'.tr, 'invalid_link'.tr);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('projects'.tr),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth > 720;
          final double fieldWidth = isWide
              ? (constraints.maxWidth / 2) - 28
              : constraints.maxWidth;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1100),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SectionCard(
                      title: 'projects'.tr,
                      subtitle: 'project_form_subtitle'.tr,
                      headerTrailing: OutlinedButton.icon(
                        onPressed: _loadList,
                        icon: const Icon(Icons.download_outlined),
                        label: Text('load_list'.tr),
                      ),
                      child: Form(
                        key: _formKey,
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        child: Wrap(
                          spacing: 16,
                          runSpacing: 12,
                          children: [
                            SizedBox(
                              width: fieldWidth,
                              child: TextFormField(
                                controller: profileIdController,
                                decoration: InputDecoration(
                                  labelText: 'profile_id'.tr,
                                  prefixIcon: const Icon(Icons.badge_outlined),
                                ),
                                keyboardType: TextInputType.number,
                                validator: FormValidators.numeric,
                                onChanged: (_) => _updateFormValidity(),
                              ),
                            ),
                            SizedBox(
                              width: fieldWidth,
                              child: TextFormField(
                                controller: titleController,
                                decoration: InputDecoration(
                                  labelText: 'title_label'.tr,
                                  prefixIcon: const Icon(Icons.title_outlined),
                                ),
                                validator: FormValidators.requiredField,
                                onChanged: (_) => _updateFormValidity(),
                              ),
                            ),
                            SizedBox(
                              width: fieldWidth,
                              child: TextFormField(
                                controller: roleController,
                                decoration: InputDecoration(
                                  labelText: 'role_label'.tr,
                                  prefixIcon: const Icon(Icons.manage_accounts),
                                ),
                                validator: FormValidators.requiredField,
                                onChanged: (_) => _updateFormValidity(),
                              ),
                            ),
                            SizedBox(
                              width: fieldWidth,
                              child: TextFormField(
                                controller: descriptionController,
                                decoration: InputDecoration(
                                  labelText: 'description_label'.tr,
                                  prefixIcon:
                                      const Icon(Icons.description_outlined),
                                ),
                                validator: FormValidators.requiredField,
                                maxLines: 3,
                                onChanged: (_) => _updateFormValidity(),
                              ),
                            ),
                            SizedBox(
                              width: fieldWidth,
                              child: TextFormField(
                                controller: responsibilitiesController,
                                decoration: InputDecoration(
                                  labelText: 'responsibilities_label'.tr,
                                  hintText: 'bullet_points_hint'.tr,
                                  prefixIcon: const Icon(Icons.list_alt_outlined),
                                ),
                                maxLines: 3,
                                onChanged: (_) => _updateFormValidity(),
                              ),
                            ),
                            SizedBox(
                              width: fieldWidth,
                              child: TextFormField(
                                controller: techTagsController,
                                decoration: InputDecoration(
                                  labelText: 'tech_stack_label'.tr,
                                  hintText: 'comma_separated_hint'.tr,
                                  prefixIcon: const Icon(Icons.memory_outlined),
                                ),
                                onChanged: (_) => _updateFormValidity(),
                              ),
                            ),
                            SizedBox(
                              width: fieldWidth,
                              child: TextFormField(
                                controller: linkController,
                                decoration: InputDecoration(
                                  labelText: 'link_label'.tr,
                                  prefixIcon: const Icon(Icons.link_outlined),
                                ),
                                validator: FormValidators.requiredField,
                                onChanged: (_) => _updateFormValidity(),
                              ),
                            ),
                            SizedBox(
                              width: fieldWidth,
                              child: TextFormField(
                                controller: demoLinkController,
                                decoration: InputDecoration(
                                  labelText: 'demo_link_label'.tr,
                                  prefixIcon: const Icon(Icons.slideshow_outlined),
                                ),
                                validator: FormValidators.url,
                                onChanged: (_) => _updateFormValidity(),
                              ),
                            ),
                            SizedBox(
                              width: fieldWidth,
                              child: TextFormField(
                                controller: githubLinkController,
                                decoration: InputDecoration(
                                  labelText: 'github_url_label'.tr,
                                  prefixIcon: const Icon(Icons.code_outlined),
                                ),
                                validator: FormValidators.url,
                                onChanged: (_) => _updateFormValidity(),
                              ),
                            ),
                            SizedBox(
                              width: fieldWidth,
                              child: TextFormField(
                                controller: liveLinkController,
                                decoration: InputDecoration(
                                  labelText: 'live_link_label'.tr,
                                  prefixIcon: const Icon(Icons.public),
                                ),
                                validator: FormValidators.url,
                                onChanged: (_) => _updateFormValidity(),
                              ),
                            ),
                            SizedBox(
                              width: fieldWidth,
                              child: TextFormField(
                                controller: thumbnailController,
                                decoration: InputDecoration(
                                  labelText: 'thumbnail_label'.tr,
                                  prefixIcon:
                                      const Icon(Icons.image_outlined),
                                ),
                                validator: FormValidators.url,
                                onChanged: (_) => _updateFormValidity(),
                              ),
                            ),
                            SizedBox(
                              width: fieldWidth,
                              child: SwitchListTile.adaptive(
                                value: isFeatured.value,
                                onChanged: (value) {
                                  isFeatured.value = value;
                                },
                                title: Text('featured_project_label'.tr),
                                contentPadding: EdgeInsets.zero,
                              ),
                            ),
                            SizedBox(
                              width: fieldWidth,
                              child: Wrap(
                                spacing: 12,
                                runSpacing: 8,
                                children: [
                                  Obx(
                                    () => ElevatedButton.icon(
                                      onPressed:
                                          isFormValid.value ? _submit : null,
                                      icon: Icon(editingProject.value == null
                                          ? Icons.save_outlined
                                          : Icons.check_circle_outline),
                                      label: Text(
                                        editingProject.value == null
                                            ? 'save'.tr
                                            : 'update'.tr,
                                      ),
                                    ),
                                  ),
                                  OutlinedButton.icon(
                                    onPressed: _resetForm,
                                    icon: const Icon(Icons.refresh),
                                    label: Text('clear'.tr),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SectionCard(
                      title: 'projects'.tr,
                      subtitle: 'project_list_subtitle'.tr,
                      child: Obx(() {
                        final projects = controller.projects;

                        if (projects.isEmpty) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Text('no_projects'.tr),
                          );
                        }

                        return Wrap(
                          spacing: 16,
                          runSpacing: 16,
                          children: projects
                              .map(
                                (project) => SizedBox(
                                  width: isWide
                                      ? (constraints.maxWidth / 2) - 20
                                      : constraints.maxWidth,
                                  child: _ProjectCard(
                                    project: project,
                                    onLaunch: _launchLink,
                                    onEdit: () {
                                      editingProject.value = project;
                                      profileIdController.text =
                                          project.profileId.toString();
                                      titleController.text = project.title;
                                      descriptionController.text =
                                          project.description;
                                      linkController.text = project.link;
                                      roleController.text = project.role;
                                      responsibilitiesController.text =
                                          project.responsibilities.join('\n');
                                      techTagsController.text =
                                          project.techTags.join(', ');
                                      demoLinkController.text =
                                          project.demoLink;
                                      githubLinkController.text =
                                          project.githubLink;
                                      liveLinkController.text =
                                          project.liveLink;
                                      thumbnailController.text =
                                          project.thumbnailUrl;
                                      isFeatured.value = project.isFeatured;
                                      _updateFormValidity();
                                    },
                                    onDelete: () async {
                                      if (project.id != null) {
                                        await controller.delete(project.id!);
                                      }
                                    },
                                  ),
                                ),
                              )
                              .toList(),
                        );
                      }),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ProjectCard extends StatelessWidget {
  const _ProjectCard({
    required this.project,
    required this.onLaunch,
    required this.onEdit,
    required this.onDelete,
  });

  final Project project;
  final Future<void> Function(String url) onLaunch;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = project.isFeatured
        ? theme.colorScheme.secondaryContainer
        : theme.colorScheme.surfaceVariant;

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 1,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: accent,
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        project.title,
                        style: theme.textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      if (project.role.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(project.role,
                            style: theme.textTheme.bodyMedium),
                      ],
                      if (project.description.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          project.description,
                          style: theme.textTheme.bodyMedium,
                        ),
                      ],
                    ],
                  ),
                ),
                Wrap(
                  spacing: 4,
                  children: [
                    IconButton(
                      tooltip: 'edit'.tr,
                      icon: const Icon(Icons.edit_outlined),
                      onPressed: onEdit,
                    ),
                    IconButton(
                      tooltip: 'delete'.tr,
                      icon: const Icon(Icons.delete_outline),
                      onPressed: onDelete,
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (project.techTags.isNotEmpty)
                  ...project.techTags
                      .map((tag) => Chip(label: Text(tag)))
                      .toList(),
              ],
            ),
            if (project.responsibilities.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                'responsibilities_label'.tr,
                style: theme.textTheme.titleSmall
                    ?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 6),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: project.responsibilities
                    .map((item) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('• '),
                              Expanded(child: Text(item)),
                            ],
                          ),
                        ))
                    .toList(),
              ),
            ],
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (project.link.isNotEmpty)
                  _LinkChip(
                    label: 'link_label'.tr,
                    url: project.link,
                    onTap: onLaunch,
                  ),
                if (project.demoLink.isNotEmpty)
                  _LinkChip(
                    label: 'demo_link_label'.tr,
                    url: project.demoLink,
                    onTap: onLaunch,
                  ),
                if (project.githubLink.isNotEmpty)
                  _LinkChip(
                    label: 'GitHub',
                    url: project.githubLink,
                    onTap: onLaunch,
                  ),
                if (project.liveLink.isNotEmpty)
                  _LinkChip(
                    label: 'live_link_label'.tr,
                    url: project.liveLink,
                    onTap: onLaunch,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _LinkChip extends StatelessWidget {
  const _LinkChip({
    required this.label,
    required this.url,
    required this.onTap,
  });

  final String label;
  final String url;
  final Future<void> Function(String url) onTap;

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      label: Text(label),
      avatar: const Icon(Icons.link, size: 18),
      onPressed: () => onTap(url),
    );
  }
}
