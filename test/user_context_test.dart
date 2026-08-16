import 'package:cloud_frog/cloud_frog.dart' show User;
import 'package:cloud_frog_riverpod/cloud_frog_riverpod.dart';
import 'package:dart_frog/dart_frog.dart';
// ignore: implementation_imports
import 'package:dart_frog/src/_internal.dart' show toShelfHandler;
import 'package:riverpod/riverpod.dart';
import 'package:shelf/shelf.dart' as shelf;
import 'package:test/test.dart';

import 'generated_dependency.dart';

void main() {
  group('ProviderContainer user scope', () {
    late ProviderContainer root;

    setUp(() => root = ProviderContainer());
    tearDown(() => root.dispose());

    test('requires a current user for currentUserId', () {
      expect(() => root.currentUserId, throwsStateError);
    });

    test('creates isolated explicit user scopes', () {
      final first = root.scopedToUser('user-1');
      final second = root.scopedToUser('user-2');
      addTearDown(first.dispose);
      addTearDown(second.dispose);

      expect(first.currentUserId, 'user-1');
      expect(second.currentUserId, 'user-2');
      expect(root.read(currentUserIdProvider), isNull);
    });

    test('rejects empty and replacement user IDs', () {
      expect(() => root.scopedToUser(''), throwsArgumentError);

      final scoped = root.scopedToUser('user-1');
      addTearDown(scoped.dispose);
      expect(() => scoped.scopedToUser('user-2'), throwsStateError);
    });

    test('supports generated dependencies on currentUserId', () {
      final scoped = root.scopedToUser('generated-user');
      addTearDown(scoped.dispose);

      expect(scoped.read(generatedUserIdProvider), 'generated-user');
    });
  });

  group('Ref.resolveUserId', () {
    final resolvedProvider = Provider.family<String, String?>(
      (ref, explicitUserId) => ref.resolveUserId(explicitUserId),
      dependencies: [currentUserIdProvider],
    );

    test('requires an explicit ID outside a user scope', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(
        () => container.read(resolvedProvider(null)),
        throwsA(
          predicate<Object>(
            (error) => error.toString().contains(
              'An explicit userId is required outside a request scope',
            ),
          ),
        ),
      );
      expect(container.read(resolvedProvider('job-user')), 'job-user');
    });

    test('uses the scoped ID and rejects a mismatch', () {
      final root = ProviderContainer();
      final scoped = root.scopedToUser('scoped-user');
      addTearDown(scoped.dispose);
      addTearDown(root.dispose);

      expect(scoped.read(resolvedProvider(null)), 'scoped-user');
      expect(scoped.read(resolvedProvider('scoped-user')), 'scoped-user');
      expect(
        () => scoped.read(resolvedProvider('different-user')),
        throwsA(
          predicate<Object>(
            (error) => error.toString().contains(
              'Explicit userId does not match the scoped user',
            ),
          ),
        ),
      );
    });
  });

  test('userRiverpod provides the authenticated user and container', () async {
    final root = ProviderContainer();
    addTearDown(root.dispose);
    final user = User(
      subject: 'request-user',
      email: 'user@example.com',
      emailVerified: true,
    );

    final handler = ((RequestContext context) async {
      expect(context.container.read(userProvider), same(user));
      expect(context.readProvider(currentUserIdProvider), user.subject);
      return Response();
    }).use(userRiverpod(root)).use(provider<User>((context) => user));

    final response = await toShelfHandler(handler)(
      shelf.Request('GET', Uri.parse('https://example.com/')),
    );

    expect(response.statusCode, 200);
    expect(root.read(userProvider), isNull);
  });

  test('rootRiverpod exposes a caller-owned container', () async {
    final root = ProviderContainer();
    addTearDown(root.dispose);

    final handler = ((RequestContext context) async {
      expect(context.container, same(root));
      return Response();
    }).use(rootRiverpod(root));

    final response = await toShelfHandler(handler)(
      shelf.Request('GET', Uri.parse('https://example.com/')),
    );

    expect(response.statusCode, 200);
    expect(root.read(userProvider), isNull);
  });

  test('userRiverpod cannot replace an existing user scope', () async {
    final root = ProviderContainer();
    final scopedRoot = root.scopedToUser('existing-user');
    addTearDown(scopedRoot.dispose);
    addTearDown(root.dispose);
    final differentUser = User(
      subject: 'different-user',
      email: 'user@example.com',
      emailVerified: true,
    );

    final handler = ((RequestContext context) async => Response())
        .use(userRiverpod(scopedRoot))
        .use(provider<User>((context) => differentUser));

    await expectLater(
      toShelfHandler(handler)(
        shelf.Request('GET', Uri.parse('https://example.com/')),
      ),
      throwsStateError,
    );
  });
}
