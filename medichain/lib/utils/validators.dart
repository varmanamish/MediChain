// lib/utils/validators.dart
import 'dart:convert';

//import 'package:intl/intl.dart';

class Validators {
  // Email validation
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }

    final emailRegex = RegExp(
      r'^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+',
      caseSensitive: false,
    );

    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email address';
    }

    return null;
  }

  // Password validation
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }

    if (value.length < 8) {
      return 'Password must be at least 8 characters long';
    }

    if (!value.contains(RegExp(r'[A-Z]'))) {
      return 'Password must contain at least one uppercase letter';
    }

    if (!value.contains(RegExp(r'[a-z]'))) {
      return 'Password must contain at least one lowercase letter';
    }

    if (!value.contains(RegExp(r'[0-9]'))) {
      return 'Password must contain at least one number';
    }

    if (!value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
      return 'Password must contain at least one special character';
    }

    return null;
  }

  // Confirm password validation
  static String? validateConfirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }

    if (value != password) {
      return 'Passwords do not match';
    }

    return null;
  }

  // Required field validation
  static String? validateRequired(String? value,
      {String fieldName = 'This field'}) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  // Name validation
  static String? validateName(String? value, {String fieldName = 'Name'}) {
    final requiredError = validateRequired(value, fieldName: fieldName);
    if (requiredError != null) return requiredError;

    if (value!.length < 2) {
      return '$fieldName must be at least 2 characters long';
    }

    if (value.length > 50) {
      return '$fieldName cannot exceed 50 characters';
    }

    final nameRegex = RegExp(r"^[a-zA-Z\s\-\.\']+$");
    if (!nameRegex.hasMatch(value)) {
      return '$fieldName can only contain letters, spaces, hyphens, and apostrophes';
    }

    return null;
  }

  // Phone number validation
  static String? validatePhoneNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone number is required';
    }

    // Remove all non-digit characters
    final digitsOnly = value.replaceAll(RegExp(r'[^\d]'), '');

    if (digitsOnly.length < 10) {
      return 'Phone number must be at least 10 digits';
    }

    if (digitsOnly.length > 15) {
      return 'Phone number cannot exceed 15 digits';
    }

    // Basic international phone number validation
    final phoneRegex = RegExp(
      r'^[\+]?[1-9][\d]{0,15}$',
    );

    if (!phoneRegex.hasMatch(digitsOnly)) {
      return 'Please enter a valid phone number';
    }

    return null;
  }

  // Drug name validation
  static String? validateDrugName(String? value) {
    final requiredError = validateRequired(value, fieldName: 'Drug name');
    if (requiredError != null) return requiredError;

    if (value!.length < 2) {
      return 'Drug name must be at least 2 characters long';
    }

    if (value.length > 100) {
      return 'Drug name cannot exceed 100 characters';
    }

    // Allow letters, numbers, spaces, hyphens, and parentheses
    final drugNameRegex = RegExp(r'^[a-zA-Z0-9\s\-\(\)\.&]+$');
    if (!drugNameRegex.hasMatch(value)) {
      return 'Drug name can only contain letters, numbers, spaces, hyphens, parentheses, and ampersands';
    }

    return null;
  }

  // Batch ID validation
  static String? validateBatchId(String? value) {
    final requiredError = validateRequired(value, fieldName: 'Batch ID');
    if (requiredError != null) return requiredError;

    if (value!.length < 3) {
      return 'Batch ID must be at least 3 characters long';
    }

    if (value.length > 50) {
      return 'Batch ID cannot exceed 50 characters';
    }

    // Allow alphanumeric characters, hyphens, and underscores
    final batchIdRegex = RegExp(r'^[a-zA-Z0-9\-_]+$');
    if (!batchIdRegex.hasMatch(value)) {
      return 'Batch ID can only contain letters, numbers, hyphens, and underscores';
    }

    return null;
  }

  // Quantity validation
  static String? validateQuantity(String? value) {
    final requiredError = validateRequired(value, fieldName: 'Quantity');
    if (requiredError != null) return requiredError;

    final quantity = int.tryParse(value!);
    if (quantity == null) {
      return 'Please enter a valid number';
    }

    if (quantity <= 0) {
      return 'Quantity must be greater than 0';
    }

    if (quantity > 1000000) {
      return 'Quantity cannot exceed 1,000,000';
    }

    return null;
  }

  // Positive number validation
  static String? validatePositiveNumber(String? value,
      {String fieldName = 'Number'}) {
    if (value == null || value.isEmpty) {
      return '$fieldName is required';
    }

    final number = double.tryParse(value);
    if (number == null) {
      return 'Please enter a valid number';
    }

    if (number < 0) {
      return '$fieldName cannot be negative';
    }

    return null;
  }

  // Temperature validation (in Celsius)
  static String? validateTemperature(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Temperature is optional
    }

    final temperature = double.tryParse(value);
    if (temperature == null) {
      return 'Please enter a valid temperature';
    }

    if (temperature < -50 || temperature > 100) {
      return 'Temperature must be between -50°C and 100°C';
    }

    return null;
  }

  // Humidity validation (percentage)
  static String? validateHumidity(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Humidity is optional
    }

    final humidity = double.tryParse(value);
    if (humidity == null) {
      return 'Please enter a valid humidity percentage';
    }

    if (humidity < 0 || humidity > 100) {
      return 'Humidity must be between 0% and 100%';
    }

    return null;
  }

  // Date validation
  static String? validateDate(String? value, {String fieldName = 'Date'}) {
    if (value == null || value.isEmpty) {
      return '$fieldName is required';
    }

    try {
      DateTime.parse(value);
      return null;
    } catch (e) {
      return 'Please enter a valid date';
    }
  }

  // Future date validation (date must be in the future)
  static String? validateFutureDate(String? value,
      {String fieldName = 'Date'}) {
    final dateError = validateDate(value, fieldName: fieldName);
    if (dateError != null) return dateError;

    final date = DateTime.parse(value!);
    if (date.isBefore(DateTime.now())) {
      return '$fieldName must be in the future';
    }

    return null;
  }

  // Past date validation (date must be in the past)
  static String? validatePastDate(String? value, {String fieldName = 'Date'}) {
    final dateError = validateDate(value, fieldName: fieldName);
    if (dateError != null) return dateError;

    final date = DateTime.parse(value!);
    if (date.isAfter(DateTime.now())) {
      return '$fieldName must be in the past';
    }

    return null;
  }

  // Date range validation (end date must be after start date)
  static String? validateDateRange(DateTime? startDate, DateTime? endDate) {
    if (startDate == null || endDate == null) {
      return null; // Let individual date validators handle null cases
    }

    if (endDate.isBefore(startDate)) {
      return 'End date must be after start date';
    }

    return null;
  }

  // Company name validation
  static String? validateCompanyName(String? value) {
    final requiredError = validateRequired(value, fieldName: 'Company name');
    if (requiredError != null) return requiredError;

    if (value!.length < 2) {
      return 'Company name must be at least 2 characters long';
    }

    if (value.length > 100) {
      return 'Company name cannot exceed 100 characters';
    }

    return null;
  }

  // License number validation
  static String? validateLicenseNumber(String? value) {
    final requiredError = validateRequired(value, fieldName: 'License number');
    if (requiredError != null) return requiredError;

    if (value!.length < 5) {
      return 'License number must be at least 5 characters long';
    }

    if (value.length > 50) {
      return 'License number cannot exceed 50 characters';
    }

    // Allow alphanumeric characters and common separators
    final licenseRegex = RegExp(r'^[a-zA-Z0-9\-\s\/\.]+$');
    if (!licenseRegex.hasMatch(value)) {
      return 'License number can only contain letters, numbers, hyphens, spaces, slashes, and periods';
    }

    return null;
  }

  // Address validation
  static String? validateAddress(String? value) {
    final requiredError = validateRequired(value, fieldName: 'Address');
    if (requiredError != null) return requiredError;

    if (value!.length < 10) {
      return 'Address must be at least 10 characters long';
    }

    if (value.length > 200) {
      return 'Address cannot exceed 200 characters';
    }

    return null;
  }

  // Composition validation (drug composition)
  static String? validateComposition(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Composition is optional
    }

    if (value.length > 500) {
      return 'Composition cannot exceed 500 characters';
    }

    return null;
  }

  // Dosage form validation
  static String? validateDosageForm(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Dosage form is optional
    }

    if (value.length > 50) {
      return 'Dosage form cannot exceed 50 characters';
    }

    final dosageRegex = RegExp(r'^[a-zA-Z\s\-]+$');
    if (!dosageRegex.hasMatch(value)) {
      return 'Dosage form can only contain letters, spaces, and hyphens';
    }

    return null;
  }

  // Storage conditions validation
  static String? validateStorageConditions(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Storage conditions are optional
    }

    if (value.length > 200) {
      return 'Storage conditions cannot exceed 200 characters';
    }

    return null;
  }

  // Notes validation
  static String? validateNotes(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Notes are optional
    }

    if (value.length > 1000) {
      return 'Notes cannot exceed 1000 characters';
    }

    return null;
  }

  // Location validation
  static String? validateLocation(String? value) {
    final requiredError = validateRequired(value, fieldName: 'Location');
    if (requiredError != null) return requiredError;

    if (value!.length < 3) {
      return 'Location must be at least 3 characters long';
    }

    if (value.length > 100) {
      return 'Location cannot exceed 100 characters';
    }

    return null;
  }

  // Latitude validation
  static String? validateLatitude(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Latitude is optional
    }

    final latitude = double.tryParse(value);
    if (latitude == null) {
      return 'Please enter a valid latitude';
    }

    if (latitude < -90 || latitude > 90) {
      return 'Latitude must be between -90 and 90';
    }

    return null;
  }

  // Longitude validation
  static String? validateLongitude(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Longitude is optional
    }

    final longitude = double.tryParse(value);
    if (longitude == null) {
      return 'Please enter a valid longitude';
    }

    if (longitude < -180 || longitude > 180) {
      return 'Longitude must be between -180 and 180';
    }

    return null;
  }

  // URL validation
  static String? validateUrl(String? value) {
    if (value == null || value.isEmpty) {
      return null; // URL is optional
    }

    final urlRegex = RegExp(
      r'^(https?://)?([\w-]+\.)+[\w-]+(/[\w-./?%&=]*)?$',
      caseSensitive: false,
    );

    if (!urlRegex.hasMatch(value)) {
      return 'Please enter a valid URL';
    }

    return null;
  }

  // File size validation (in bytes)
  static String? validateFileSize(List<int>? bytes, {int maxSizeInMB = 10}) {
    if (bytes == null) {
      return 'File is required';
    }

    final maxSizeInBytes = maxSizeInMB * 1024 * 1024;
    if (bytes.length > maxSizeInBytes) {
      return 'File size must be less than ${maxSizeInMB}MB';
    }

    return null;
  }

  // File type validation
  static String? validateFileType(
      String? fileName, List<String> allowedExtensions) {
    if (fileName == null || fileName.isEmpty) {
      return 'File is required';
    }

    final extension = fileName.toLowerCase().split('.').last;
    if (!allowedExtensions.contains(extension)) {
      return 'File type not allowed. Allowed types: ${allowedExtensions.join(', ')}';
    }

    return null;
  }

  // Multiple validators
  static String? validateMultiple(List<String? Function()> validators) {
    for (final validator in validators) {
      final error = validator();
      if (error != null) {
        return error;
      }
    }
    return null;
  }

  // Conditional validation
  static String? Function(String?) conditional(
    bool condition,
    String? Function(String?) validator,
  ) {
    return (value) => condition ? validator(value) : null;
  }

  // Batch expiration validation
  static String? validateExpiryDate(
      DateTime? manufactureDate, DateTime? expiryDate) {
    if (manufactureDate == null || expiryDate == null) {
      return null; // Let individual date validators handle null cases
    }

    if (expiryDate.isBefore(manufactureDate)) {
      return 'Expiry date must be after manufacture date';
    }

    if (expiryDate.isBefore(DateTime.now())) {
      return 'Expiry date must be in the future';
    }

    // Check if expiry is too far in the future (e.g., more than 10 years)
    final maxExpiry = manufactureDate.add(const Duration(days: 365 * 10));
    if (expiryDate.isAfter(maxExpiry)) {
      return 'Expiry date cannot be more than 10 years from manufacture date';
    }

    return null;
  }

  // QR code data validation
  static String? validateQRData(String? value) {
    if (value == null || value.isEmpty) {
      return 'QR code data is required';
    }

    try {
      final data = jsonDecode(value);

      // Check required fields in QR data
      final requiredFields = [
        'batch_id',
        'drug_name',
        'manufacturer_id',
        'blockchain_hash'
      ];
      for (final field in requiredFields) {
        if (!data.containsKey(field) || data[field] == null) {
          return 'Invalid QR code data: missing $field';
        }
      }

      return null;
    } catch (e) {
      return 'Invalid QR code data format';
    }
  }

  // Role validation
  static String? validateRole(String? value) {
    final requiredError = validateRequired(value, fieldName: 'Role');
    if (requiredError != null) return requiredError;

    final validRoles = ['manufacturer', 'distributor', 'pharmacy', 'end_user'];
    if (!validRoles.contains(value)) {
      return 'Please select a valid role';
    }

    return null;
  }

  // Transaction type validation
  static String? validateTransactionType(String? value) {
    final requiredError =
        validateRequired(value, fieldName: 'Transaction type');
    if (requiredError != null) return requiredError;

    final validTypes = ['manufacture', 'ship', 'receive', 'sell', 'recall'];
    if (!validTypes.contains(value)) {
      return 'Please select a valid transaction type';
    }

    return null;
  }

  // Helper method to format validation errors
  static String formatValidationErrors(Map<String, String> errors) {
    if (errors.isEmpty) return '';

    final errorList = errors.values.where((error) => error.isNotEmpty).toList();
    return errorList.join('\n');
  }

  // Helper method to check if form is valid
  static bool isFormValid(Map<String, String?> errors) {
    return errors.values.every((error) => error == null || error.isEmpty);
  }
}

// Extension for easier validation on TextFormField
extension ValidatorExtension on String? {
  String? validateWith(String? Function(String?) validator) {
    return validator(this);
  }
}

// Custom validator for specific business rules
class PharmaTraceValidators {
  // Validate that batch ID follows PharmaTrace format
  static String? validateBatchIdFormat(String? value) {
    final basicError = Validators.validateBatchId(value);
    if (basicError != null) return basicError;

    // PharmaTrace batch ID format: Starts with letters, then numbers
    final pharmaTraceFormat = RegExp(r'^[A-Z]{2,}\d+$');
    if (!pharmaTraceFormat.hasMatch(value!)) {
      return 'Batch ID should start with letters followed by numbers (e.g., PH12345)';
    }

    return null;
  }

  // Validate drug name against common patterns
  static String? validateDrugNameStrict(String? value) {
    final basicError = Validators.validateDrugName(value);
    if (basicError != null) return basicError;

    // Check for suspicious patterns (very basic anti-counterfeit check)
    final suspiciousPatterns = [
      'fake',
      'counterfeit',
      'copy',
      'replica',
      'generic',
    ];

    final lowerValue = value!.toLowerCase();
    for (final pattern in suspiciousPatterns) {
      if (lowerValue.contains(pattern)) {
        return 'Drug name contains suspicious pattern';
      }
    }

    return null;
  }

  // Validate manufacturer credentials
  static String? validateManufacturerCredentials({
    required String? companyName,
    required String? licenseNumber,
  }) {
    final companyError = Validators.validateCompanyName(companyName);
    final licenseError = Validators.validateLicenseNumber(licenseNumber);

    if (companyError != null) return companyError;
    if (licenseError != null) return licenseError;

    return null;
  }

  // Validate transit data
  static String? validateTransitData({
    required String? location,
    required String? transactionType,
    String? temperature,
    String? humidity,
  }) {
    final locationError = Validators.validateLocation(location);
    final typeError = Validators.validateTransactionType(transactionType);
    final tempError = Validators.validateTemperature(temperature);
    final humidityError = Validators.validateHumidity(humidity);

    if (locationError != null) return locationError;
    if (typeError != null) return typeError;
    if (tempError != null) return tempError;
    if (humidityError != null) return humidityError;

    return null;
  }
}
