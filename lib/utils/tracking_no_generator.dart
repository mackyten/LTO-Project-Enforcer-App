import 'dart:math';

String createAlphanumericTrackingNumber() {
  const letters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
  final random = Random();
  final now = DateTime.now();

  // Get the current timestamp in milliseconds
  final timestamp = now.millisecondsSinceEpoch;

  // Generate three random letters
  String randomLetters = '';
  for (int i = 0; i < 3; i++) {
    randomLetters += letters[random.nextInt(letters.length)];
  }

  // Combine the timestamp with the random letters
  final trackingNumber = '$timestamp$randomLetters';

  return trackingNumber;
}