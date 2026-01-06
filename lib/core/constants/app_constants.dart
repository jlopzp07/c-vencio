import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConstants {
  static String get supabaseUrl => dotenv.env['SUPABASE_URL'] ?? '';
  static String get supabaseAnonKey => dotenv.env['SUPABASE_ANON_KEY'] ?? '';
  static String get verifikApiKey => dotenv.env['VERIFIK_API_KEY'] ?? '';

  // AI Features
  static String get geminiApiKey => dotenv.env['GEMINI_API_KEY'] ?? '';
  static bool get enableAiFeatures => dotenv.env['ENABLE_AI_FEATURES'] == 'true';
  static bool get enableVoiceInput => dotenv.env['ENABLE_VOICE_INPUT'] == 'true';
}
