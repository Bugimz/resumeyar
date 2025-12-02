import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../data/models/resume_profile.dart';
import '../../utils/validators.dart';
import '../../utils/widgets/section_card.dart';
import 'profile_controller.dart';

class ProfileView extends GetView<ProfileController> {
  ProfileView({super.key});

  final _formKey = GlobalKey<FormState>();
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController jobTitleController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController portfolioController = TextEditingController();
  final TextEditingController linkedInController = TextEditingController();
  final TextEditingController githubController = TextEditingController();
  final TextEditingController summaryController = TextEditingController();
  final Rxn<ResumeProfile> editingProfile = Rxn<ResumeProfile>();
  final RxnString imagePath = RxnString();
  final RxBool isFormValid = false.obs;
  final RxString previewFullName = ''.obs;
  final RxString previewJobTitle = ''.obs;
  final RxString previewLocation = ''.obs;
  final RxString previewEmail = ''.obs;
  final RxString previewPhone = ''.obs;
  final RxString previewPortfolio = ''.obs;
  final RxString previewLinkedIn = ''.obs;
  final RxString previewGithub = ''.obs;
  final RxString previewSummary = ''.obs;

  void _resetForm() {
    editingProfile.value = null;
    fullNameController.clear();
    jobTitleController.clear();
    locationController.clear();
    emailController.clear();
    phoneController.clear();
    portfolioController.clear();
    linkedInController.clear();
    githubController.clear();
    summaryController.clear();
    imagePath.value = null;
    isFormValid.value = false;
    _updatePreviewFromControllers();
  }

  void _updateFormValidity() {
    final currentState = _formKey.currentState;
    if (currentState == null) {
      isFormValid.value = false;
      return;
    }

    isFormValid.value = currentState.validate();
    _updatePreviewFromControllers();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final profile = ResumeProfile(
      id: editingProfile.value?.id,
      fullName: fullNameController.text,
      jobTitle: jobTitleController.text,
      location: locationController.text,
      email: emailController.text,
      phone: phoneController.text,
      summary: summaryController.text,
      portfolioUrl: portfolioController.text,
      linkedInUrl: linkedInController.text,
      githubUrl: githubController.text,
      imagePath: imagePath.value,
      signaturePath: editingProfile.value?.signaturePath,
    );

    if (editingProfile.value == null) {
      await controller.saveProfile(profile);
    } else {
      await controller.updateProfile(profile);
    }

    _resetForm();
  }

  Future<void> _pickImage() async {
    final photosStatus = await Permission.photos.request();
    final storageStatus = await Permission.storage.request();

    if (!photosStatus.isGranted && !storageStatus.isGranted) {
      return;
    }

    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      imagePath.value = pickedFile.path;
      _updatePreviewFromControllers();
    }
  }

  void _updatePreviewFromControllers() {
    previewFullName.value = fullNameController.text;
    previewJobTitle.value = jobTitleController.text;
    previewLocation.value = locationController.text;
    previewEmail.value = emailController.text;
    previewPhone.value = phoneController.text;
    previewPortfolio.value = portfolioController.text;
    previewLinkedIn.value = linkedInController.text;
    previewGithub.value = githubController.text;
    previewSummary.value = summaryController.text;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('profiles_title'.tr),
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
                      title: 'profiles_title'.tr,
                      subtitle: 'profile_details_subtitle'.tr,
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
                                controller: fullNameController,
                                decoration: InputDecoration(
                                  labelText: 'full_name_label'.tr,
                                  prefixIcon: const Icon(Icons.person_outline),
                                ),
                                validator: FormValidators.requiredField,
                                onChanged: (_) => _updateFormValidity(),
                              ),
                            ),
                            SizedBox(
                              width: fieldWidth,
                              child: TextFormField(
                                controller: jobTitleController,
                                decoration: InputDecoration(
                                  labelText: 'job_title_label'.tr,
                                  prefixIcon: const Icon(Icons.work_outline),
                                ),
                                validator: FormValidators.requiredField,
                                onChanged: (_) => _updateFormValidity(),
                              ),
                            ),
                            SizedBox(
                              width: fieldWidth,
                              child: TextFormField(
                                controller: locationController,
                                decoration: InputDecoration(
                                  labelText: 'location_label'.tr,
                                  prefixIcon: const Icon(Icons.place_outlined),
                                ),
                                validator: FormValidators.requiredField,
                                onChanged: (_) => _updateFormValidity(),
                              ),
                            ),
                            SizedBox(
                              width: fieldWidth,
                              child: TextFormField(
                                controller: emailController,
                                decoration: InputDecoration(
                                  labelText: 'email_label'.tr,
                                  prefixIcon: const Icon(Icons.mail_outline),
                                ),
                                validator: FormValidators.email,
                                onChanged: (_) => _updateFormValidity(),
                              ),
                            ),
                            SizedBox(
                              width: fieldWidth,
                              child: TextFormField(
                                controller: phoneController,
                                decoration: InputDecoration(
                                  labelText: 'phone_label'.tr,
                                  prefixIcon: const Icon(Icons.phone_outlined),
                                ),
                                validator: FormValidators.requiredField,
                                onChanged: (_) => _updateFormValidity(),
                              ),
                            ),
                            SizedBox(
                              width: fieldWidth,
                              child: TextFormField(
                                controller: portfolioController,
                                decoration: InputDecoration(
                                  labelText: 'portfolio_url_label'.tr,
                                  prefixIcon: const Icon(Icons.public),
                                ),
                                validator: FormValidators.url,
                                onChanged: (_) => _updateFormValidity(),
                              ),
                            ),
                            SizedBox(
                            width: fieldWidth,
                            child: TextFormField(
                              controller: linkedInController,
                              decoration: InputDecoration(
                                  labelText: 'linkedin_url_label'.tr,
                                  prefixIcon: const Icon(Icons.link_outlined),
                                ),
                                validator: FormValidators.url,
                                onChanged: (_) => _updateFormValidity(),
                              ),
                            ),
                            SizedBox(
                              width: fieldWidth,
                              child: TextFormField(
                                controller: githubController,
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
                                controller: summaryController,
                                decoration: InputDecoration(
                                  labelText: 'summary_label'.tr,
                                  prefixIcon: const Icon(Icons.notes_outlined),
                                ),
                                validator: FormValidators.requiredField,
                                maxLines: 3,
                                onChanged: (_) => _updateFormValidity(),
                              ),
                            ),
                            SizedBox(
                              width: fieldWidth,
                              child: Row(
                                children: [
                                  ElevatedButton.icon(
                                    onPressed: _pickImage,
                                    icon: const Icon(Icons.image),
                                    label: Text('select_image'.tr),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Obx(() {
                                      final path = imagePath.value;
                                      if (path == null || path.isEmpty) {
                                        return Text(
                                          'no_image_selected'.tr,
                                          style: theme.textTheme.bodySmall,
                                        );
                                      }
                                      return Row(
                                        children: [
                                          Container(
                                            width: 48,
                                            height: 48,
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              border: Border.all(
                                                  color: Colors.grey.shade300),
                                            ),
                                            clipBehavior: Clip.antiAlias,
                                            child: Image.file(
                                              File(path),
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              path,
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      );
                                    }),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(
                              width: fieldWidth,
                              child: Wrap(
                                spacing: 12,
                                runSpacing: 8,
                                children: [
                                  Obx(() => ElevatedButton.icon(
                                        onPressed:
                                            isFormValid.value ? _submit : null,
                                        icon: Icon(editingProfile.value == null
                                            ? Icons.save_outlined
                                            : Icons.check_circle_outline),
                                        label: Text(
                                          editingProfile.value == null
                                              ? 'save'.tr
                                              : 'update'.tr,
                                        ),
                                      )),
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
                      title: 'profiles_title'.tr,
                      subtitle: 'profiles_subtitle'.tr,
                      child: Obx(() {
                        final profiles = controller.profiles;

                        if (controller.isLoading.isTrue) {
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 24),
                              child: CircularProgressIndicator(),
                            ),
                          );
                        }

                        if (profiles.isEmpty) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Text('no_profiles'.tr),
                          );
                        }

                        return Wrap(
                          spacing: 16,
                          runSpacing: 16,
                          children: profiles
                              .map(
                                (profile) => SizedBox(
                                  width: isWide
                                      ? (constraints.maxWidth / 2) - 20
                                      : constraints.maxWidth,
                                  child: _ProfileCard(
                                    profile: profile,
                                    onEdit: () {
                                      editingProfile.value = profile;
                                      fullNameController.text =
                                          profile.fullName;
                                      jobTitleController.text =
                                          profile.jobTitle;
                                      locationController.text =
                                          profile.location;
                                      emailController.text = profile.email;
                                      phoneController.text = profile.phone;
                                      portfolioController.text =
                                          profile.portfolioUrl;
                                      linkedInController.text =
                                          profile.linkedInUrl;
                                      githubController.text =
                                          profile.githubUrl;
                                      summaryController.text =
                                          profile.summary;
                                      imagePath.value = profile.imagePath;
                                      _updatePreviewFromControllers();
                                    },
                                    onDelete: () async {
                                      if (profile.id != null) {
                                        await controller.deleteProfile(
                                            profile.id!);
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

class _ProfileCard extends StatelessWidget {
  const _ProfileCard({
    required this.profile,
    required this.onEdit,
    required this.onDelete,
  });

  final ResumeProfile profile;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 26,
                  backgroundColor: theme.colorScheme.primaryContainer,
                  child: Text(
                    profile.fullName.isNotEmpty
                        ? profile.fullName[0].toUpperCase()
                        : '?',
                    style: theme.textTheme.titleMedium,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        profile.fullName,
                        style: theme.textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      if (profile.jobTitle.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          profile.jobTitle,
                          style: theme.textTheme.bodyMedium,
                        ),
                      ],
                      if (profile.location.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.place_outlined, size: 16),
                            const SizedBox(width: 4),
                            Flexible(child: Text(profile.location)),
                          ],
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
            if (profile.summary.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                profile.summary,
                style: theme.textTheme.bodyMedium,
              ),
            ],
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (profile.email.isNotEmpty)
                  _InfoChip(icon: Icons.mail_outline, label: profile.email),
                if (profile.phone.isNotEmpty)
                  _InfoChip(icon: Icons.phone_outlined, label: profile.phone),
                if (profile.portfolioUrl.isNotEmpty)
                  _InfoChip(icon: Icons.public, label: profile.portfolioUrl),
                if (profile.linkedInUrl.isNotEmpty)
                  _InfoChip(icon: Icons.link, label: profile.linkedInUrl),
                if (profile.githubUrl.isNotEmpty)
                  _InfoChip(icon: Icons.code_outlined, label: profile.githubUrl),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: Icon(icon, size: 16),
      label: Text(label, overflow: TextOverflow.ellipsis),
      padding: const EdgeInsets.symmetric(horizontal: 6),
    );
  }
}
