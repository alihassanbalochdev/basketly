import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Tells GoRouter "check your redirects again" whenever someone signs
/// in or out. GoRouter can't listen to a Stream, but it can listen to this.
class AuthListenable extends ChangeNotifier {
  AuthListenable(SupabaseClient client) {
    _subscription = client.auth.onAuthStateChange.listen((_) => notifyListeners());
  }

  late final StreamSubscription<AuthState> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
