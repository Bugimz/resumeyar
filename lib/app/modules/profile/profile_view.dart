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
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController summaryController = TextEditingController();
  final Rxn<ResumeProfile> editingProfile = Rxn<ResumeProfile>();
  final RxnString imagePath = RxnString();
  final RxBool isFormValid = false.obs;

  void _resetForm() {
    editingProfile.value = null;
    fullNameController.clear();
    emailController.clear();
    phoneController.clear();
    summaryController.clear();
    imagePath.value = null;
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

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final profile = ResumeProfile(
      id: editingProfile.value?.id,
      fullName: fullNameController.text,
      email: emailController.text,
      phone: phoneController.text,
      summary: summaryController.text,
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
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('profiles_title'.tr),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Form(
              key: _formKey,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              child: Column(
                children: [
                  TextFormField(
                    controller: fullNameController,
                    decoration: InputDecoration(labelText: 'full_name_label'.tr),
                    validator: FormValidators.requiredField,
                    onChanged: (_) => _updateFormValidity(),
                  ),
                  TextFormField(
                    controller: emailController,
                    decoration: InputDecoration(labelText: 'email_label'.tr),
                    validator: FormValidators.email,
                    onChanged: (_) => _updateFormValidity(),
                  ),
                  TextFormField(
                    controller: phoneController,
                    decoration: InputDecoration(labelText: 'phone_label'.tr),
                    validator: FormValidators.requiredField,
                    onChanged: (_) => _updateFormValidity(),
                  ),
                  TextFormField(
                    controller: summaryController,
                    decoration: InputDecoration(labelText: 'summary_label'.tr),
                    validator: FormValidators.requiredField,
                    onChanged: (_) => _updateFormValidity(),
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
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.grey.shade300),
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
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Obx(() => ElevatedButton(
                            onPressed: isFormValid.value ? _submit : null,
                            child: Text(
                              editingProfile.value == null
                                  ? 'save'.tr
                                  : 'update'.tr,
                            ),
                          )),
                      const SizedBox(width: 8),
                      TextButton(
                        onPressed: _resetForm,
                        child: Text('clear'.tr),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'profiles_title'.tr,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
                      subtitle: Text('${profile.email} • ${profile.phone}'),
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
                                await controller.deleteProfile(profile.id!);
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
    );
  }
}
