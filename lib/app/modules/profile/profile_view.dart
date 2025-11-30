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
                    Form(
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
                              decoration:
                                  InputDecoration(labelText: 'full_name_label'.tr),
                              validator: FormValidators.requiredField,
                              onChanged: (_) => _updateFormValidity(),
                            ),
                          ),
                          SizedBox(
                            width: fieldWidth,
                            child: TextFormField(
                              controller: emailController,
                              decoration:
                                  InputDecoration(labelText: 'email_label'.tr),
                              validator: FormValidators.email,
                              onChanged: (_) => _updateFormValidity(),
                            ),
                          ),
                          SizedBox(
                            width: fieldWidth,
                            child: TextFormField(
                              controller: phoneController,
                              decoration:
                                  InputDecoration(labelText: 'phone_label'.tr),
                              validator: FormValidators.requiredField,
                              onChanged: (_) => _updateFormValidity(),
                            ),
                          ),
                          SizedBox(
                            width: fieldWidth,
                            child: TextFormField(
                              controller: summaryController,
                              decoration:
                                  InputDecoration(labelText: 'summary_label'.tr),
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
                                      return Text('no_image_selected'.tr);
                                    }
                                    return Row(
                                      children: [
                                        Container(
                                          width: 48,
                                          height: 48,
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(8),
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
                                Obx(() => ElevatedButton(
                                      onPressed:
                                          isFormValid.value ? _submit : null,
                                      child: Text(
                                        editingProfile.value == null
                                            ? 'save'.tr
                                            : 'update'.tr,
                                      ),
                                    )),
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
                              subtitle:
                                  Text('${profile.email} • ${profile.phone}'),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit),
                                    onPressed: () {
                                      editingProfile.value = profile;
                                      fullNameController.text = profile.fullName;
                                      emailController.text = profile.email;
                                      phoneController.text = profile.phone;
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
