# cloud_frog_riverpod

Riverpod request and user scopes for
[`cloud_frog`](https://pub.dev/packages/cloud_frog) applications.

## Principles

The application creates and owns one root `ProviderContainer`. This root holds
application-wide providers and shared state, and remains alive for the lifetime
of the application.

Each authenticated request gets a short-lived user container whose parent is
the root container. The child inherits providers from the root while overriding
the current user for that request. Consequently, application-wide dependencies
can be shared without allowing user-specific state to leak between concurrent
requests. The request middleware disposes the user container when the request
finishes, but never disposes the caller-owned root container.

Background jobs follow the same hierarchy without requiring a Dart Frog
request: `scopedToUser` creates an explicit user container beneath the root.
User scopes cannot be replaced with a different user, which prevents work from
silently crossing a request or job's user boundary.

## Usage

Create and own the application's root container, then place `userRiverpod` after
middleware that provides an authenticated Cloud Frog `User`:

```dart
final rootContainer = ProviderContainer();

Handler middleware(Handler handler) => handler
    .use(userRiverpod(rootContainer))
    .use(authenticationMiddleware);
```

Use `rootRiverpod(rootContainer)` for routes that need the application
container without an authenticated user. Dispose the root container when the
application shuts down; the package only owns and disposes the request-local
child containers it creates.

Read providers from a route's `RequestContext`:

```dart
Future<Response> onRequest(RequestContext context) async {
  final userId = context.readProvider(currentUserIdProvider);
  return Response.json(body: {'userId': userId});
}
```

For background jobs, create and dispose an explicit child scope:

```dart
final userContainer = rootContainer.scopedToUser(userId);
try {
  await userContainer.read(jobProvider.future);
} finally {
  userContainer.dispose();
}
```

Providers that support both request and background contexts can call
`ref.resolveUserId(explicitUserId)`. It uses the authenticated request user when
present, requires an explicit ID otherwise, and rejects IDs that do not match
the authenticated user.
