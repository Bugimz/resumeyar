import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../data/models/interest.dart';
import '../../utils/validators.dart';
import 'interest_controller.dart';

class InterestView extends GetView<InterestController> {
  InterestView({super.key});

  final _formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final Rxn<Interest> editingInterest = Rxn<Interest>();
  final RxBool isFormValid = false.obs;

  void _resetForm() {
    editingInterest.value = null;
    nameController.clear();
    descriptionController.clear();
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

    final interest = Interest(
      id: editingInterest.value?.id,
      name: nameController.text,
      description: descriptionController.text,
    );

    if (editingInterest.value == null) {
      await controller.save(interest);
    } else {
      await controller.updateInterest(interest);
    }

    _resetForm();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Interests')),
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
                              controller: nameController,
                              decoration: const InputDecoration(
                                labelText: 'Interest',
                              ),
                              validator: FormValidators.requiredField,
                              onChanged: (_) => _updateFormValidity(),
                            ),
                          ),
                          SizedBox(
                            width: fieldWidth,
                            child: TextFormField(
                              controller: descriptionController,
                              decoration: const InputDecoration(
                                labelText: 'Description',
                              ),
                              validator: FormValidators.requiredField,
                              onChanged: (_) => _updateFormValidity(),
                              maxLines: 3,
                            ),
                          ),
                          SizedBox(
                            width: fieldWidth,
                            child: Wrap(
                              spacing: 12,
                              runSpacing: 8,
                              children: [
                                Obx(
                                  () => ElevatedButton(
                                    onPressed: isFormValid.value ? _submit : null,
                                    child: Text(
                                      editingInterest.value == null
                                          ? 'Save'
                                          : 'Update',
                                    ),
                                  ),
                                ),
                                TextButton(
                                  onPressed: _resetForm,
                                  child: const Text('Clear'),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Interests',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Obx(() {
                      final interests = controller.interests;
                      if (interests.isEmpty) {
                        return const Text('No interests added yet');
                      }

                      return Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: interests
                            .map(
                              (interest) => SizedBox(
                                width: isWide
                                    ? (constraints.maxWidth / 2) - 28
                                    : constraints.maxWidth,
                                child: _InterestCard(
                                  interest: interest,
                                  onEdit: _editInterest,
                                  onDelete: () => controller.delete(interest.id!),
                                ),
                              ),
                            )
                            .toList(),
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

  void _editInterest(Interest interest) {
    editingInterest.value = interest;
    nameController.text = interest.name;
    descriptionController.text = interest.description;
    _updateFormValidity();
  }
}

class _InterestCard extends StatelessWidget {
  const _InterestCard({
    required this.interest,
    required this.onEdit,
    required this.onDelete,
  });

  final Interest interest;
  final ValueChanged<Interest> onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(interest.name),
        subtitle: Text(interest.description),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => onEdit(interest),
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}
