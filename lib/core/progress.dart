import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class WatchProgress {
  const WatchProgress({required this.titleId, required this.title, required this.episode, required this.positionMs, required this.durationMs, this.updatedAt = 0});
  final String titleId, title;
  final int episode, positionMs, durationMs, updatedAt;
  double get fraction => durationMs > 0 ? (positionMs / durationMs).clamp(0.0, 1.0) : 0.0;
  Map<String, dynamic> toJson() => {'titleId': titleId, 'title': title, 'episode': episode, 'positionMs': positionMs, 'durationMs': durationMs, 'updatedAt': updatedAt};
  factory WatchProgress.fromJson(Map<String,dynamic> j) => WatchProgress(titleId:'${j['titleId'] ?? ''}', title:'${j['title'] ?? ''}', episode:int.tryParse('${j['episode'] ?? 1}') ?? 1, positionMs:int.tryParse('${j['positionMs'] ?? 0}') ?? 0, durationMs:int.tryParse('${j['durationMs'] ?? 0}') ?? 0, updatedAt:int.tryParse('${j['updatedAt'] ?? 0}') ?? 0);
}

class ProgressStore {
  static const _key = 'anivortex_watch_progress_v1';
  static Future<List<WatchProgress>> all() async {
    final p = await SharedPreferences.getInstance();
    final raw = p.getString(_key);
    if (raw == null) return const [];
    try {
      final list = jsonDecode(raw);
      if (list is! List) return const [];
      return list.whereType<Map>().map((e)=>WatchProgress.fromJson(Map<String,dynamic>.from(e))).where((e)=>e.titleId.isNotEmpty).toList()
        ..sort((a,b)=>b.updatedAt.compareTo(a.updatedAt));
    } catch (_) { return const []; }
  }
  static Future<void> save(WatchProgress item) async {
    final p = await SharedPreferences.getInstance();
    final list = await all();
    final next = [item, ...list.where((x)=>x.titleId != item.titleId || x.episode != item.episode)].take(50).map((x)=>x.toJson()).toList();
    await p.setString(_key, jsonEncode(next));
  }
  static Future<void> remove(String titleId, int episode) async {
    final p = await SharedPreferences.getInstance();
    final list = await all();
    await p.setString(_key, jsonEncode(list.where((x)=>x.titleId != titleId || x.episode != episode).map((x)=>x.toJson()).toList()));
  }
}
