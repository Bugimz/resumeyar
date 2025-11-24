import 'package:get/get.dart';

class FormValidators {
  const FormValidators._();

  static String? requiredField(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'required_field'.tr;
    }
    return null;
  }

  static String? numeric(String? value) {
    final required = requiredField(value);
    if (required != null) {
      return required;
    }

    if (int.tryParse(value!.trim()) == null) {
      return 'invalid_number'.tr;
    }
    return null;
  }

  static String? email(String? value) {
    final required = requiredField(value);
    if (required != null) {
      return required;
    }

    final emailPattern = RegExp(r'^.+@.+\..+$');
    if (!emailPattern.hasMatch(value!.trim())) {
      return 'invalid_email'.tr;
    }
    return null;
  }

  static String? date(String? value) {
    final required = requiredField(value);
    if (required != null) {
      return required;
    }

    if (DateTime.tryParse(value!.trim()) == null) {
      return 'invalid_date_format'.tr;
    }
    return null;
  }

  static String? startBeforeEnd({
    required String? start,
    required String? end,
  }) {
    final endValidation = date(end);
    if (endValidation != null) {
      return endValidation;
    }

    final startValidation = date(start);
    if (startValidation != null) {
      return startValidation;
    }

    final startDate = DateTime.parse(start!.trim());
    final endDate = DateTime.parse(end!.trim());

    if (startDate.isAfter(endDate)) {
      return 'start_after_end'.tr;
    }
    return null;
  }
}
