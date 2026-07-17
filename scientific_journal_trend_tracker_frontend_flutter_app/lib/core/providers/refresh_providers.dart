import 'package:flutter_riverpod/flutter_riverpod.dart';

class BookmarkRefreshNotifier extends Notifier<int> {
  @override
  int build() => 0;
  void increment() => state++;
}
final bookmarkRefreshProvider = NotifierProvider<BookmarkRefreshNotifier, int>(() => BookmarkRefreshNotifier());

class FollowRefreshNotifier extends Notifier<int> {
  @override
  int build() => 0;
  void increment() => state++;
}
final followRefreshProvider = NotifierProvider<FollowRefreshNotifier, int>(() => FollowRefreshNotifier());
