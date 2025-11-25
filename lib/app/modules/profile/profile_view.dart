import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../data/models/resume_profile.dart';
import '../../utils/validators.dart';
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

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    FormFieldValidator<String>? validator,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(labelText: label),
      validator: validator,
      maxLines: maxLines,
      onChanged: (_) => _updateFormValidity(),
    );
  }

  Widget _buildChip({required IconData icon, required String text}) {
    return Chip(
      avatar: Icon(icon, size: 16),
      label: Text(text),
      padding: const EdgeInsets.symmetric(horizontal: 6),
    );
  }

  @override
  Widget build(BuildContext context) {
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
                    Obx(
                      () => Card(
                        elevation: 1,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Obx(() {
                                final path = imagePath.value;
                                if (path == null || path.isEmpty) {
                                  return CircleAvatar(
                                    radius: 32,
                                    backgroundColor: Colors.grey.shade200,
                                    child: const Icon(Icons.person, size: 28),
                                  );
                                }

                                return CircleAvatar(
                                  radius: 32,
                                  backgroundColor: Colors.grey.shade200,
                                  backgroundImage: FileImage(File(path)),
                                );
                              }),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      previewFullName.value.isEmpty
                                          ? 'full_name_label'.tr
                                          : previewFullName.value,
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium,
                                    ),
                                    if (previewJobTitle.value.isNotEmpty)
                                      Padding(
                                        padding:
                                            const EdgeInsets.symmetric(vertical: 4),
                                        child: Text(
                                          previewJobTitle.value,
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleSmall,
                                        ),
                                      ),
                                    if (previewLocation.value.isNotEmpty)
                                      Row(
                                        children: [
                                          const Icon(Icons.location_on, size: 14),
                                          const SizedBox(width: 6),
                                          Text(previewLocation.value),
                                        ],
                                      ),
                                    const SizedBox(height: 8),
                                    Wrap(
                                      spacing: 8,
                                      runSpacing: 6,
                                      children: [
                                        if (previewEmail.value.isNotEmpty)
                                          _buildChip(
                                            icon: Icons.email,
                                            text: previewEmail.value,
                                          ),
                                        if (previewPhone.value.isNotEmpty)
                                          _buildChip(
                                            icon: Icons.phone,
                                            text: previewPhone.value,
                                          ),
                                        if (previewPortfolio.value.isNotEmpty)
                                          _buildChip(
                                            icon: Icons.link,
                                            text: previewPortfolio.value,
                                          ),
                                        if (previewLinkedIn.value.isNotEmpty)
                                          _buildChip(
                                            icon: Icons.business_center,
                                            text: previewLinkedIn.value,
                                          ),
                                        if (previewGithub.value.isNotEmpty)
                                          _buildChip(
                                            icon: Icons.code,
                                            text: previewGithub.value,
                                          ),
                                      ],
                                    ),
                                    if (previewSummary.value.isNotEmpty)
                                      Padding(
                                        padding: const EdgeInsets.only(top: 12),
                                        child: Text(
                                          previewSummary.value,
                                          maxLines: 4,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Form(
                      key: _formKey,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Card(
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'identity_block'.tr,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium,
                                  ),
                                  const SizedBox(height: 12),
                                  isWide
                                      ? Row(
                                          children: [
                                            Expanded(
                                              child: Column(
                                                children: [
                                                  _buildTextField(
                                                    controller:
                                                        fullNameController,
                                                    label: 'full_name_label'.tr,
                                                    validator: FormValidators
                                                        .requiredField,
                                                  ),
                                                  const SizedBox(height: 12),
                                                  _buildTextField(
                                                    controller:
                                                        jobTitleController,
                                                    label: 'job_title_label'.tr,
                                                  ),
                                                ],
                                              ),
                                            ),
                                            const SizedBox(width: 16),
                                            Expanded(
                                              child: _buildTextField(
                                                controller: locationController,
                                                label: 'location_label'.tr,
                                              ),
                                            ),
                                          ],
                                        )
                                      : Column(
                                          children: [
                                            _buildTextField(
                                              controller: fullNameController,
                                              label: 'full_name_label'.tr,
                                              validator:
                                                  FormValidators.requiredField,
                                            ),
                                            const SizedBox(height: 12),
                                            _buildTextField(
                                              controller: jobTitleController,
                                              label: 'job_title_label'.tr,
                                            ),
                                            const SizedBox(height: 12),
                                            _buildTextField(
                                              controller: locationController,
                                              label: 'location_label'.tr,
                                            ),
                                          ],
                                        ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Card(
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'contact_block'.tr,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium,
                                  ),
                                  const SizedBox(height: 12),
                                  Wrap(
                                    spacing: 16,
                                    runSpacing: 12,
                                    children: [
                                      SizedBox(
                                        width: fieldWidth,
                                        child: _buildTextField(
                                          controller: phoneController,
                                          label: 'phone_label'.tr,
                                          validator:
                                              FormValidators.requiredField,
                                        ),
                                      ),
                                      SizedBox(
                                        width: fieldWidth,
                                        child: _buildTextField(
                                          controller: emailController,
                                          label: 'email_label'.tr,
                                          validator: FormValidators.email,
                                        ),
                                      ),
                                      SizedBox(
                                        width: fieldWidth,
                                        child: _buildTextField(
                                          controller: portfolioController,
                                          label: 'portfolio_label'.tr,
                                        ),
                                      ),
                                      SizedBox(
                                        width: fieldWidth,
                                        child: _buildTextField(
                                          controller: linkedInController,
                                          label: 'linkedin_label'.tr,
                                        ),
                                      ),
                                      SizedBox(
                                        width: fieldWidth,
                                        child: _buildTextField(
                                          controller: githubController,
                                          label: 'github_label'.tr,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Card(
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'summary_label'.tr,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium,
                                  ),
                                  const SizedBox(height: 12),
                                  _buildTextField(
                                    controller: summaryController,
                                    label: 'summary_label'.tr,
                                    validator: FormValidators.requiredField,
                                    maxLines: 5,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Card(
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'select_image'.tr,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium,
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
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
                                            return Text('no_image_selected'.tr);
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
                                                      color: Colors
                                                          .grey.shade300),
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
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Wrap(
                              spacing: 12,
                              runSpacing: 8,
                              children: [
                                Obx(
                                  () => ElevatedButton(
                                    onPressed:
                                        isFormValid.value ? _submit : null,
                                    child: Text(
                                      editingProfile.value == null
                                          ? 'save'.tr
                                          : 'update'.tr,
                                    ),
                                  ),
                                ),
                                TextButton(
                                  onPressed: _resetForm,
                                  child: Text('clear'.tr),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'profiles_title'.tr,
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Obx(() {
                      final profiles = controller.profiles;

                      if (controller.isLoading.isTrue) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (profiles.isEmpty) {
                        return Text('no_profiles'.tr);
                      }

                      return ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: profiles.length,
                        itemBuilder: (context, index) {
                          final profile = profiles[index];
                          return Card(
                            child: ListTile(
                              title: Text(profile.fullName),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (profile.jobTitle.isNotEmpty)
                                    Text(profile.jobTitle),
                                  Text(
                                    [
                                      if (profile.location.isNotEmpty)
                                        profile.location,
                                      profile.email,
                                      profile.phone,
                                    ].join(' • '),
                                  ),
                                ],
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit),
                                    onPressed: () {
                                      editingProfile.value = profile;
                                      fullNameController.text = profile.fullName;
                                      jobTitleController.text = profile.jobTitle;
                                      locationController.text = profile.location;
                                      emailController.text = profile.email;
                                      phoneController.text = profile.phone;
                                      portfolioController.text = profile.portfolioUrl;
                                      linkedInController.text = profile.linkedInUrl;
                                      githubController.text = profile.githubUrl;
                                      summaryController.text = profile.summary;
                                      imagePath.value = profile.imagePath;
                                      _updateFormValidity();
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete),
                                    onPressed: () async {
                                      if (profile.id != null) {
                                        await controller.deleteProfile(
                                            profile.id!);
                                      }
                                    },
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    }),
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
