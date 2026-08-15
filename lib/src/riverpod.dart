import 'package:cloud_frog/cloud_frog.dart' show User;
import 'package:dart_frog/dart_frog.dart';
import 'package:riverpod/misc.dart' show ProviderListenable;
import 'package:riverpod/riverpod.dart';

/// Makes the application-wide Riverpod container available to a request.
///
/// The caller retains ownership of [rootContainer] and must dispose it when the
/// application shuts down. Authenticated routes should use [userRiverpod].
Middleware rootRiverpod(ProviderContainer rootContainer) =>
    provider<ProviderContainer>((context) => rootContainer);

/// The authenticated Cloud Frog user, or `null` outside a request user scope.
final userProvider = Provider<User?>((ref) => null, dependencies: const []);

/// The authenticated user's subject, or `null` outside a user scope.
final currentUserIdProvider = Provider<String?>(
  (ref) => ref.watch(userProvider)?.subject,
  dependencies: [userProvider],
);

/// Helpers for providers that can run both in requests and background jobs.
extension UserContextRef on Ref {
  /// Resolves [explicitUserId] against the current request user, if any.
  ///
  /// An explicit ID is required outside a user scope. Inside a user scope, an
  /// explicit ID must match the authenticated user's subject.
  String resolveUserId(String? explicitUserId) {
    final scopedUserId = watch(currentUserIdProvider);
    if (scopedUserId == null) {
      if (explicitUserId == null || explicitUserId.isEmpty) {
        throw StateError(
          'An explicit userId is required outside a request scope',
        );
      }
      return explicitUserId;
    }

    if (explicitUserId != null && explicitUserId != scopedUserId) {
      throw StateError('Explicit userId does not match the scoped user');
    }
    return scopedUserId;
  }
}

/// User-scoping helpers for Riverpod containers.
extension UserContextContainer on ProviderContainer {
  /// The current user ID.
  ///
  /// Throws when the container is not in a user scope.
  String get currentUserId =>
      read(currentUserIdProvider) ??
      (throw StateError('A current user is required outside a user scope'));

  /// Creates a child container scoped to [userId].
  ///
  /// This is intended for background work that does not have a Cloud Frog
  /// request. The returned container must be disposed by its caller.
  ProviderContainer scopedToUser(String userId) {
    if (userId.isEmpty) {
      throw ArgumentError.value(userId, 'userId', 'Must not be empty');
    }
    _ensureCompatibleUserScope(this, userId);
    return ProviderContainer(
      parent: this,
      overrides: [currentUserIdProvider.overrideWithValue(userId)],
    );
  }
}

/// Creates a request-local Riverpod container scoped to the authenticated user.
///
/// A Cloud Frog authentication middleware must provide [User] before this
/// middleware runs. The request container is disposed after the handler ends.
/// The caller owns [rootContainer]; this middleware never disposes it.
Middleware userRiverpod(ProviderContainer rootContainer) {
  return (handler) {
    return (context) async {
      final user = context.read<User>();
      _ensureCompatibleUserScope(rootContainer, user.subject);
      final requestContainer = ProviderContainer(
        parent: rootContainer,
        overrides: [userProvider.overrideWithValue(user)],
      );

      try {
        return await handler(
          context.provide<ProviderContainer>(() => requestContainer),
        );
      } finally {
        requestContainer.dispose();
      }
    };
  };
}

void _ensureCompatibleUserScope(ProviderContainer container, String userId) {
  final existingUserId = container.read(currentUserIdProvider);
  if (existingUserId != null && existingUserId != userId) {
    throw StateError('Cannot replace the current user scope');
  }
}

/// Riverpod accessors for Dart Frog request contexts.
extension RiverpodContext on RequestContext {
  /// The Riverpod container attached to this request.
  ProviderContainer get container => read<ProviderContainer>();

  /// Reads [provider] from the container attached to this request.
  T readProvider<T>(ProviderListenable<T> provider) => container.read(provider);
}
