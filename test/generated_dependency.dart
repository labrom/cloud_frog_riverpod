import 'package:cloud_frog_riverpod/cloud_frog_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'generated_dependency.g.dart';

@Riverpod(dependencies: [currentUserId])
String generatedUserId(Ref ref) =>
    ref.watch(currentUserIdProvider) ?? 'no-user';
