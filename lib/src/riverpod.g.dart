// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'riverpod.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The authenticated Cloud Frog user, or `null` outside a request user scope.

@ProviderFor(user)
final userProvider = UserProvider._();

/// The authenticated Cloud Frog user, or `null` outside a request user scope.

final class UserProvider extends $FunctionalProvider<User?, User?, User?>
    with $Provider<User?> {
  /// The authenticated Cloud Frog user, or `null` outside a request user scope.
  UserProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'userProvider',
        isAutoDispose: false,
        dependencies: <ProviderOrFamily>[],
        $allTransitiveDependencies: <ProviderOrFamily>[],
      );

  @override
  String debugGetCreateSourceHash() => _$userHash();

  @$internal
  @override
  $ProviderElement<User?> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  User? create(Ref ref) {
    return user(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(User? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<User?>(value),
    );
  }
}

String _$userHash() => r'9d8259f28dc07de63cba1d24465638058dad1833';

/// The authenticated user's subject, or `null` outside a user scope.

@ProviderFor(currentUserId)
final currentUserIdProvider = CurrentUserIdProvider._();

/// The authenticated user's subject, or `null` outside a user scope.

final class CurrentUserIdProvider
    extends $FunctionalProvider<String?, String?, String?>
    with $Provider<String?> {
  /// The authenticated user's subject, or `null` outside a user scope.
  CurrentUserIdProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'currentUserIdProvider',
        isAutoDispose: false,
        dependencies: <ProviderOrFamily>[userProvider],
        $allTransitiveDependencies: <ProviderOrFamily>[
          CurrentUserIdProvider.$allTransitiveDependencies0,
        ],
      );

  static final $allTransitiveDependencies0 = userProvider;

  @override
  String debugGetCreateSourceHash() => _$currentUserIdHash();

  @$internal
  @override
  $ProviderElement<String?> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  String? create(Ref ref) {
    return currentUserId(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String?>(value),
    );
  }
}

String _$currentUserIdHash() => r'3c659a4454d9f0861a87bd78241902507a39973e';
