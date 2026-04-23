import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'connectivity_provider.g.dart';

@riverpod
class Connectivity extends _$Connectivity {
  @override
  bool build() => true; // Defaults to online

  void setOnline(bool isOnline) => state = isOnline;
}
