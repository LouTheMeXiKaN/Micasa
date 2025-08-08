import 'package:flutter_dotenv/flutter_dotenv.dart';

class Environment {
  static String get apiBaseUrl {
    // Load API URL from .env file
    return dotenv.env['API_BASE_URL'] ?? 'https://micasa-g1w3.onrender.com';
  }
}