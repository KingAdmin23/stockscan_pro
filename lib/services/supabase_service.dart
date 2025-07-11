import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static final SupabaseService _instance = SupabaseService._internal();
  late final SupabaseClient _client;
  bool _isInitialized = false;
  final Future<void> _initFuture;

  // Singleton pattern
  factory SupabaseService() {
    return _instance;
  }

  SupabaseService._internal() : _initFuture = _initializeSupabase();

  static const String supabaseUrl =
      String.fromEnvironment('SUPABASE_URL', defaultValue: '');
  static const String supabaseAnonKey =
      String.fromEnvironment('SUPABASE_ANON_KEY', defaultValue: '');

  // Internal initialization logic
  static Future<void> _initializeSupabase() async {
    if (supabaseUrl.isEmpty || supabaseAnonKey.isEmpty) {
      throw Exception(
          'SUPABASE_URL and SUPABASE_ANON_KEY must be defined using --dart-define.');
    }

    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
    );

    _instance._client = Supabase.instance.client;
    _instance._isInitialized = true;
  }

  // Client getter (async)
  Future<SupabaseClient> get client async {
    if (!_isInitialized) {
      await _initFuture;
    }
    return _client;
  }

  // Synchronous client getter for cases where we know it's initialized
  SupabaseClient get syncClient {
    if (!_isInitialized) {
      throw Exception('Supabase not initialized. Use await client instead.');
    }
    return _client;
  }

  // Auth helpers
  User? get currentUser => _isInitialized ? _client.auth.currentUser : null;
  bool get isAuthenticated => currentUser != null;
  String? get currentUserId => currentUser?.id;

  // Auth methods
  Future<AuthResponse> signInWithEmail(String email, String password) async {
    final client = await this.client;
    return await client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  Future<AuthResponse> signUpWithEmail(String email, String password,
      {String? fullName}) async {
    final client = await this.client;
    return await client.auth.signUp(
      email: email,
      password: password,
      data: fullName != null ? {'full_name': fullName} : null,
    );
  }

  Future<void> signOut() async {
    final client = await this.client;
    await client.auth.signOut();
  }

  // Listen to auth state changes
  Stream<AuthState> get authStateChanges {
    return _client.auth.onAuthStateChange;
  }
}
