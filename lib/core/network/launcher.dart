import 'package:url_launcher/url_launcher.dart';

Future<bool> launchPhoneCall(String phoneNumber) async {
  final uri = Uri(scheme: 'tel', path: phoneNumber);
  return launchUrl(uri);
}

Future<bool> launchWhatsApp(String phoneNumber, {String? message}) async {
  // wa.me expects digits only (with country code, no + or spaces).
  final digitsOnly = phoneNumber.replaceAll(RegExp(r'[^0-9]'), '');
  final uri = Uri.parse(
    'https://wa.me/$digitsOnly${message != null ? '?text=${Uri.encodeComponent(message)}' : ''}',
  );
  return launchUrl(uri, mode: LaunchMode.externalApplication);
}

Future<bool> launchDirections(double latitude, double longitude) async {
  final uri = Uri.parse('https://www.google.com/maps/search/?api=1&query=$latitude,$longitude');
  return launchUrl(uri, mode: LaunchMode.externalApplication);
}
