import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../platform_detail/models/platform_detail.dart';
import '../../platform_detail/providers/platform_detail_provider.dart';

class CompareSelectionNotifier extends Notifier<Set<String>> {
  @override
  Set<String> build() => {};

  void toggle(String slug) {
    final current = Set<String>.from(state);
    if (current.contains(slug)) {
      current.remove(slug);
    } else if (current.length < 3) {
      current.add(slug);
    }
    state = current;
  }

  void clear() => state = {};
  bool isSelected(String slug) => state.contains(slug);
}

final compareSelectionProvider =
    NotifierProvider<CompareSelectionNotifier, Set<String>>(CompareSelectionNotifier.new);

final compareDataProvider = FutureProvider<List<PlatformDetail>>((ref) async {
  final slugs = ref.watch(compareSelectionProvider);
  if (slugs.isEmpty) return [];
  final futures = slugs.map((slug) => ref.watch(platformDetailProvider(slug).future));
  return Future.wait(futures);
});
