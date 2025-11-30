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

  static String? optionalNumeric(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null;
    }

    if (double.tryParse(value.trim()) == null) {
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

  static String? achievementBullets(String? value) {
    final required = requiredField(value);
    if (required != null) {
      return required;
    }

    final bullets =
        value!.split('\n').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
    if (bullets.length < 3 || bullets.length > 5) {
      return 'Enter 3 to 5 concise achievements.';
    }

    final invalidEntries = bullets.where((entry) {
      final hasMetric = RegExp(r'\d').hasMatch(entry);
      final startsWithVerb = RegExp(r'^[A-Za-zآ-ی]+').hasMatch(entry);
      return !hasMetric || !startsWithVerb;
    }).toList();

    if (invalidEntries.isNotEmpty) {
      return 'Use action verbs with metrics (e.g., "Increased throughput by 20%" ).';
    }

    return null;
  }

  static String? tagList(String? value) {
    final required = requiredField(value);
    if (required != null) {
      return required;
    }

    final tags = value!
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    if (tags.isEmpty) {
      return 'Enter at least one technology tag.';
    }

    return null;
  }
}
