// ignore_for_file: annotate_overrides
import 'dart:async'; import 'dart:convert'; import 'package:http/http.dart' as http; import 'models.dart';
class ApiClient {
 ApiClient({http.Client? client,this.timeout=const Duration(seconds:15)}):_client=client??http.Client(),_ownsClient=client==null;
 final http.Client _client; final Duration timeout; final bool _ownsClient; static const bootstrapUrl='https://anivortex-bootstrap.pages.dev/config.json'; static const defaultApiBase='https://api.anivortex.in';
 String apiBaseUrl=defaultApiBase; Map<String,dynamic> config={}; Map<String,dynamic> routes={};
 Future<void> initialize() async {try{final b=await getJson(bootstrapUrl);config=b;final c=b['api_base_url']??b['apiBaseUrl']??b['api_base'];if(c is String&&c.startsWith('http'))apiBaseUrl=c.replaceFirst(RegExp(r'/+$'),'');if(b['api_routes'] is Map)routes=Map<String,dynamic>.from(b['api_routes']);}catch(_){}}
 String? route(String key){final v=routes[key];return v is String?v:null;}
 Uri resolve(String path,[Map<String,String>? query]){final u=Uri.parse(path.startsWith('http')?path:'$apiBaseUrl${path.startsWith('/')?'':'/'}$path');return query==null?u:u.replace(queryParameters:{...u.queryParameters,...query});}
 Future<dynamic> requestJson(String path,{Map<String,String>? query,Map<String,String>? headers}) async {final u=resolve(path,query);final r=await _client.get(u,headers:{'Accept':'application/json',...?headers}).timeout(timeout);if(r.statusCode<200||r.statusCode>=300)throw HttpException('HTTP ${r.statusCode}',u.toString());return jsonDecode(r.body);}
 Future<Map<String,dynamic>> getJson(String url,{Map<String,String>? headers}) async {final x=await requestJson(url,headers:headers);if(x is! Map<String,dynamic>)throw const FormatException('Expected JSON object');return x;}
 List<TitleItem> _titles(dynamic raw)=>raw is List?raw.whereType<Map>().map((e)=>TitleItem.fromJson(Map<String,dynamic>.from(e))).toList():const [];
 List<EpisodeItem> _episodes(dynamic raw)=>raw is List?raw.whereType<Map>().map((e)=>EpisodeItem.fromJson(Map<String,dynamic>.from(e))).where((e)=>e.number>0).toList():const [];
 Future<List<TitleItem>> home() async {for(final p in [route('home'),route('trending'),route('catalog')].whereType<String>()){try{final b=await requestJson(p);final r=_titles(b is Map?(b['results']??b['items']??b['titles']??b['trending']??(b['data'] is Map ? (b['data']['results']??b['data']['items']??b['data']['titles']) : null)):b);if(r.isNotEmpty)return r;}catch(_){}}return demoTitles;}
 Future<List<TitleItem>> search(String q) async {final p=route('search')??route('search_titles')??'/search';final b=await requestJson(p,query:{'q':q,'query':q});return _titles(b is Map?(b['results']??b['items']??b['titles']??(b['data'] is Map ? (b['data']['results']??b['data']['items']??b['data']['titles']) : null)):b);}
 Future<TitleItem> details(String id) async {for(final k in ['title_details','details','title']){final p=route(k);if(p==null)continue;try{final b=await requestJson(p,query:{'id':id,'title_id':id});final m=b is Map?(b['title'] is Map?b['title']:(b['data'] is Map?b['data']:b)):null;if(m is Map)return TitleItem.fromJson(Map<String,dynamic>.from(m));}catch(_){}}return demoTitles.firstWhere((x)=>x.id==id,orElse:()=>demoTitles.first);}
 Future<List<EpisodeItem>> episodes(String id) async {for(final k in ['episodes','title_episodes']){final p=route(k);if(p==null)continue;try{final b=await requestJson(p,query:{'id':id,'title_id':id});final r=_episodes(b is Map?(b['episodes']??b['results']??b['items']??(b['data'] is Map ? (b['data']['episodes']??b['data']['results']??b['data']['items']) : null)):b);if(r.isNotEmpty)return r;}catch(_){}}return List.generate(12,(i)=>EpisodeItem(id:'$id-e${i+1}',number:i+1,title:'Episode ${i+1}'));}
 Future<List<StreamOption>> streams({required String titleId,required int episode}) async {for(final k in ['streams','stream','watch','sources']){final p=route(k);if(p==null)continue;try{final b=await requestJson(p,query:{'id':titleId,'title_id':titleId,'episode': '$episode','episode_number':'$episode'});final raw=b is Map?(b['sources']??b['streams']??b['results']??b['data']):b;final list=raw is List?raw.whereType<Map>().map((e)=>StreamOption.fromJson(Map<String,dynamic>.from(e))).where((e)=>e.url.isNotEmpty).toList():const <StreamOption>[];if(list.isNotEmpty)return list;}catch(_){}}return const [];}
 String? webUrl(String key)=>config['smartlink'] is Map&&config['smartlink'][key] is String?config['smartlink'][key]:null;
 bool get downloadsEnabled=>config['downloads_enabled'] != false;
 String? get telegramChannelUrl=>config['telegram_channel_url'] is String?config['telegram_channel_url']: (config['telegram_join'] is Map && config['telegram_join']['telegram_channel_url'] is String?config['telegram_join']['telegram_channel_url']:null);
 String? get authUrl=>webUrl('auth_url')??webUrl('login_url')??(config['auth_url'] is String?config['auth_url']:null);

 void close(){if(_ownsClient)_client.close();}
}
class HttpException implements Exception{const HttpException(this.message,this.url);final String message,url;String toString()=>'HttpException: $message ($url)';}
