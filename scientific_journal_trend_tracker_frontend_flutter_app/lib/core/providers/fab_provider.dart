import 'package:flutter_riverpod/flutter_riverpod.dart';

class FabVisibilityNotifier extends Notifier<bool> {
  @override
  bool build() => true;

  void show() => state = true;
  void hide() => state = false;
}

final fabVisibilityProvider = NotifierProvider<FabVisibilityNotifier, bool>(
  FabVisibilityNotifier.new,
);
