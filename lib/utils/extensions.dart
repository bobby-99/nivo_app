extension StringExtensions on String {
  String get capitalized => 
      isEmpty ? '' : '${this[0].toUpperCase()}${substring(1).toLowerCase()}';
}