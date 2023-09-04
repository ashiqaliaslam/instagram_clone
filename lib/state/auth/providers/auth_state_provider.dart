import 'package:hooks_riverpod/hooks_riverpod.dart' show StateNotifierProvider;
import 'package:instantgram_clone/state/auth/models/auth_state.dart';
import 'package:instantgram_clone/state/auth/notifiers/auth_state_notifier.dart';

// StateNotifierProvider<Notifier, NotifierObject>
final authStateProvider = StateNotifierProvider<AuthStateNotifier, AuthState>(
  (_) => AuthStateNotifier(),
);
