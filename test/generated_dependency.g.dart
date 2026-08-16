// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'generated_dependency.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(generatedUserId)
final generatedUserIdProvider = GeneratedUserIdProvider._();

final class GeneratedUserIdProvider
    extends $FunctionalProvider<String, String, String>
    with $Provider<String> {
  GeneratedUserIdProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'generatedUserIdProvider',
        isAutoDispose: true,
        dependencies: <ProviderOrFamily>[currentUserIdProvider],
        $allTransitiveDependencies: <ProviderOrFamily>[
          GeneratedUserIdProvider.$allTransitiveDependencies0,
          GeneratedUserIdProvider.$allTransitiveDependencies1,
        ],
      );

  static final $allTransitiveDependencies0 = currentUserIdProvider;
  static final $allTransitiveDependencies1 =
      CurrentUserIdProvider.$allTransitiveDependencies0;

  @override
  String debugGetCreateSourceHash() => _$generatedUserIdHash();

  @$internal
  @override
  $ProviderElement<String> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  String create(Ref ref) {
    return generatedUserId(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String>(value),
    );
  }
}

String _$generatedUserIdHash() => r'd564a1874b0bb4777960e58ae7a11d620436a801';
