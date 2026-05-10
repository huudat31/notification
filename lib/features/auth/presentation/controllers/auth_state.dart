import 'package:notification/features/auth/data/models/auth_tokens.dart';
import '../../../../core/network/token_refresher.dart' show LogoutReason;

sealed class AuthState {
  const AuthState();

  bool get isAuthenticated => this is Authenticated;

  factory AuthState.bootstrapping() => const Bootstrapping();
}

class Bootstrapping extends AuthState {
  const Bootstrapping();
}

class Authenticated extends AuthState {
  final AuthTokens tokens;

  const Authenticated(this.tokens);

  Authenticated copyWith({AuthTokens? tokens}) {
    return Authenticated(tokens ?? this.tokens);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Authenticated && other.tokens == tokens);

  @override
  int get hashCode => tokens.hashCode;
}

class Unauthenticated extends AuthState {
  final LogoutReason? reason;

  const Unauthenticated({this.reason});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Unauthenticated && other.reason == reason);

  @override
  int get hashCode => reason.hashCode;
}
