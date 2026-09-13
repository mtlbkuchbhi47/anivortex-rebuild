import 'dart:async';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class DownloadTask {
  DownloadTask({required this.id, required this.title, required this.url, required this.path, this.total=0, this.done=0, this.status='queued'});
  final String id, title, url, path; int total, done; String status;
  double get progress => total > 0 ? done / total : 0;
}

class DownloadManager {
  static final DownloadManager instance = DownloadManager._();
  DownloadManager._();
  final Map<String, DownloadTask> tasks = {};
  final Map<String, StreamSubscription<List<int>>> _subs = {};
  final Map<String, IOSink> _sinks = {};

  Future<String> defaultPath(String filename) async {
    final dir = await getApplicationDocumentsDirectory();
    final out = Directory('${dir.path}/AniVortex');
    if (!await out.exists()) await out.create(recursive: true);
    return '${out.path}/$filename';
  }

  Future<DownloadTask> start({required String id, required String title, required String url, required String path, void Function(DownloadTask)? onChanged}) async {
    await cancel(id, deletePartial: false);
    final file = File(path);
    final existing = await file.exists() ? await file.length() : 0;
    final request = await HttpClient().getUrl(Uri.parse(url));
    if (existing > 0) request.headers.set(HttpHeaders.rangeHeader, 'bytes=$existing-');
    final response = await request.close();
    final append = existing > 0 && response.statusCode == HttpStatus.partialContent;
    final start = append ? existing : 0;
    final total = response.contentLength > 0 ? start + response.contentLength : 0;
    final task = DownloadTask(id:id,title:title,url:url,path:path,total:total,done:start,status:'downloading');
    tasks[id] = task; onChanged?.call(task);
    final sink = file.openWrite(mode: append ? FileMode.append : FileMode.write);
    _sinks[id] = sink;
    final sub = response.listen((chunk) { sink.add(chunk); task.done += chunk.length; onChanged?.call(task); }, onDone: () async { await sink.flush(); await sink.close(); _sinks.remove(id); _subs.remove(id); task.status='completed'; onChanged?.call(task); }, onError: (Object e) async { await sink.close(); _sinks.remove(id); task.status='failed'; onChanged?.call(task); });
    _subs[id] = sub;
    return task;
  }

  Future<void> cancel(String id, {bool deletePartial=true}) async {
    await _subs.remove(id)?.cancel();
    await _sinks.remove(id)?.close();
    final t = tasks[id];
    if (t != null) {
      t.status = 'paused';
      if (deletePartial) { final f=File(t.path); if(await f.exists()) await f.delete(); t.done=0; }
    }
  }
}
