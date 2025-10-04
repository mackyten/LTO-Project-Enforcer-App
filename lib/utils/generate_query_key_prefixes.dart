/// Generates an array of query key prefixes from an input string.
/// 
/// This function takes a string input, normalizes it by trimming whitespace
/// and converting to uppercase, then generates all possible prefixes of
/// increasing length from 1 to the full string length.
/// 
/// Example:
/// ```dart
/// generateQueryKeyPrefixes("hello") 
/// // Returns: ["H", "HE", "HEL", "HELL", "HELLO"]
/// ```
/// 
/// Returns an empty list if the input is null, empty, or only whitespace.
List<String> generateQueryKeyPrefixes(String? input) {
  final String normalized = (input ?? '').trim();
  if (normalized.isEmpty) return [];

  final String upper = normalized.toUpperCase();
  final List<String> prefixes = [];
  
  for (int i = 1; i <= upper.length; i++) {
    prefixes.add(upper.substring(0, i));
  }
  
  return prefixes;
}
