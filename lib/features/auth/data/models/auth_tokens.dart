import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:clock/clock.dart';

class AuthTokens {
  final String accessToken;
  final String refreshToken;
  final DateTime accessExpiry;
  final DateTime refreshExpiry;
  final DateTime issuedAt;
  final String? userId;

  AuthTokens({
    required this.accessToken,
    required this.refreshToken,
    required this.accessExpiry,
    required this.refreshExpiry,
    required this.issuedAt,
    this.userId,
  });
  factory AuthTokens.fromApi(Map<String, dynamic> json) {
    final accessToken =
        (json['access_token'] ?? json['accessToken'] ?? json['token'])
            as String;
    final refreshToken =
        (json['refresh_token'] ?? json['refreshToken']) as String;

    final decodedAccess = JwtDecoder.tryDecode(accessToken);
    final decodedRefresh = JwtDecoder.tryDecode(refreshToken);

    final accessExp = _resolveExpiry(
      jwtExpSeconds: decodedAccess?['exp'] as int?,
      expiresInSeconds: (json['expires_in'] ?? json['expiresIn']) as int?,
      isoString: (json['access_expiry'] ?? json['accessExpiry']) as String?,
      fieldName: 'access token',
      fallback: clock.now().add(const Duration(days: 1)),
    );

    final refreshExp = _resolveExpiry(
      jwtExpSeconds: decodedRefresh?['exp'] as int?,
      expiresInSeconds:
          (json['refresh_expires_in'] ?? json['refreshExpiresIn']) as int?,
      isoString: (json['refresh_expiry'] ?? json['refreshExpiry']) as String?,
      fieldName: 'refresh token',
      fallback: clock.now().add(const Duration(days: 30)),
    );

    final userId =
        decodedAccess?['sub'] as String? ?? json['user_id'] as String?;

    return AuthTokens(
      accessToken: accessToken,
      refreshToken: refreshToken,
      accessExpiry: accessExp,
      refreshExpiry: refreshExp,
      issuedAt: clock.now(),
      userId: userId,
    );
  }

  static DateTime _resolveExpiry({
    required int? jwtExpSeconds,
    required int? expiresInSeconds,
    required String? isoString,
    required String fieldName,
    DateTime? fallback,
  }) {
    if (jwtExpSeconds != null) {
      return DateTime.fromMillisecondsSinceEpoch(jwtExpSeconds * 1000);
    }
    if (expiresInSeconds != null) {
      return clock.now().add(Duration(seconds: expiresInSeconds));
    }
    if (isoString != null) {
      return DateTime.parse(isoString);
    }
    if (fallback != null) {
      return fallback;
    }
    throw ArgumentError(
      'Cannot determine $fieldName expiry. Backend must provide JWT `exp` claim, '
      '`expires_in`/`refresh_expires_in`, or ISO date string.',
    );
  }

  factory AuthTokens.fromJson(Map<String, dynamic> json) {
    return AuthTokens(
      accessToken: json['accessToken'] as String,
      refreshToken: json['refreshToken'] as String,
      accessExpiry: DateTime.parse(json['accessExpiry'] as String),
      refreshExpiry: DateTime.parse(json['refreshExpiry'] as String),
      issuedAt: DateTime.parse(json['issuedAt'] as String),
      userId: json['userId'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'accessToken': accessToken,
      'refreshToken': refreshToken,
      'accessExpiry': accessExpiry.toIso8601String(),
      'refreshExpiry': refreshExpiry.toIso8601String(),
      'issuedAt': issuedAt.toIso8601String(),
      'userId': userId,
    };
  }

  bool get isAccessExpired =>
      clock.now().isAfter(accessExpiry.subtract(const Duration(seconds: 30)));

  bool get isAccessNearExpiry =>
      clock.now().isAfter(accessExpiry.subtract(const Duration(minutes: 2)));

  bool get isRefreshExpired => clock.now().isAfter(refreshExpiry);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AuthTokens &&
        other.accessToken == accessToken &&
        other.refreshToken == refreshToken &&
        other.accessExpiry == accessExpiry &&
        other.refreshExpiry == refreshExpiry &&
        other.issuedAt == issuedAt &&
        other.userId == userId;
  }

  @override
  int get hashCode => Object.hash(
    accessToken,
    refreshToken,
    accessExpiry,
    refreshExpiry,
    issuedAt,
    userId,
  );

  @override
  String toString() =>
      'AuthTokens(userId: $userId, accessExp: $accessExpiry, '
      'refreshExp: $refreshExpiry)';
}
