class TitleItem {
  const TitleItem({required this.id, required this.name, this.image = '', this.backdrop = '', this.subtitle = '', this.type = '', this.year = '', this.overview = '', this.genres = const [], this.cast = const []});
  final String id, name, image, backdrop, subtitle, type, year, overview;
  final List<String> genres, cast;
  factory TitleItem.fromJson(Map<String, dynamic> j) => TitleItem(
    id: '${j['id'] ?? j['title_id'] ?? j['slug'] ?? ''}',
    name: '${j['title'] ?? j['name'] ?? 'Untitled'}',
    image: '${j['poster_url'] ?? j['title_poster_url'] ?? j['image_url'] ?? ''}',
    backdrop: '${j['backdrop_url'] ?? j['backdrop'] ?? ''}',
    subtitle: '${j['subtitle'] ?? j['year'] ?? j['type'] ?? j['content_type'] ?? ''}',
    type: '${j['type'] ?? j['content_type'] ?? ''}', year: '${j['year'] ?? ''}',
    overview: '${j['overview'] ?? j['description'] ?? ''}',
    genres: _strings(j['genres']), cast: _strings(j['cast']),
  );
  static List<String> _strings(dynamic v) => v is List ? v.map((e) => e is Map ? '${e['name'] ?? e['character'] ?? ''}' : '$e').where((e)=>e.isNotEmpty).toList() : const [];
}
class EpisodeItem {
  const EpisodeItem({required this.id, required this.number, this.title = '', this.season = 1, this.image = '', this.overview = ''});
  final String id, title, image, overview; final int number, season;
  factory EpisodeItem.fromJson(Map<String,dynamic> j)=>EpisodeItem(id:'${j['id'] ?? j['episode_id'] ?? ''}',number:int.tryParse('${j['episode_number'] ?? j['number'] ?? 0}')??0,title:'${j['episode_title'] ?? j['title'] ?? ''}',season:int.tryParse('${j['season_number'] ?? j['season'] ?? 1}')??1,image:'${j['image_url'] ?? j['still_url'] ?? j['thumbnail'] ?? ''}',overview:'${j['overview'] ?? j['description'] ?? ''}');
}
class StreamOption {
  const StreamOption({required this.url,this.quality='',this.language='',this.headers=const {},this.subtitles=const []});
  final String url, quality, language; final Map<String,String> headers; final List<String> subtitles;
  factory StreamOption.fromJson(Map<String,dynamic> j)=>StreamOption(url:'${j['url'] ?? j['stream_url'] ?? j['download_url'] ?? ''}',quality:'${j['quality'] ?? j['resolution'] ?? ''}',language:'${j['language'] ?? j['audio'] ?? ''}',headers:j['headers'] is Map ? Map<String,String>.from((j['headers'] as Map).map((k,v)=>MapEntry('$k','$v'))) : const {},subtitles:j['subtitle_paths'] is List ? (j['subtitle_paths'] as List).map((e)=>'$e').toList() : const []);
}
class DownloadItem { const DownloadItem({required this.id,required this.title,required this.url,required this.filePath,this.episode=0,this.totalBytes=0,this.downloadedBytes=0,this.status='queued'}); final String id,title,url,filePath; final int episode,totalBytes,downloadedBytes; final String status; double get progress=>totalBytes>0?downloadedBytes/totalBytes:0; }
const demoTitles=<TitleItem>[TitleItem(id:'demo-1',name:'AniVortex Demo',image:'assets/images/common/anivortex_logo_transparent.png',subtitle:'Offline demo title',type:'anime_movie',overview:'This is an offline-safe rebuild preview.'),TitleItem(id:'demo-2',name:'Explore Catalog',image:'assets/images/catalog/film_roll.png',subtitle:'Remote API when configured',type:'anime_movie')];
