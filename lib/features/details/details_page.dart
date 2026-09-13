import 'package:flutter/material.dart';
import '../../core/api.dart';
import '../../core/models.dart';
import '../watch/watch_page.dart';

class DetailsPage extends StatefulWidget {
  const DetailsPage({super.key, required this.api, required this.title});
  final ApiClient api; final TitleItem title;
  @override State<DetailsPage> createState()=>_DetailsPageState();
}
class _DetailsPageState extends State<DetailsPage> {
  late Future<TitleItem> details; late Future<List<EpisodeItem>> episodes; int season=1;
  @override void initState(){super.initState();details=widget.api.details(widget.title.id);episodes=widget.api.episodes(widget.title.id);}
  Widget img(String u)=>u.startsWith('http')?Image.network(u,fit:BoxFit.cover,errorBuilder:(_,__,___)=>const SizedBox()):Image.asset(u.isEmpty?'assets/images/common/anivortex_logo.png':u,fit:BoxFit.cover);
  @override Widget build(BuildContext context)=>Scaffold(appBar:AppBar(title:const Text('Details')),body:FutureBuilder<TitleItem>(future:details,builder:(c,s){final t=s.data??widget.title;return ListView(children:[if(t.backdrop.isNotEmpty)SizedBox(height:210,width:double.infinity,child:img(t.backdrop)),Padding(padding:const EdgeInsets.all(16),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text(t.name,style:Theme.of(context).textTheme.headlineSmall),const SizedBox(height:8),Text([t.year,t.type,...t.genres].where((x)=>x.isNotEmpty).join(' • ')),if(t.overview.isNotEmpty)...[const SizedBox(height:14),Text(t.overview)],const SizedBox(height:18),Text('Episodes',style:Theme.of(context).textTheme.titleLarge),const SizedBox(height:8),FutureBuilder<List<EpisodeItem>>(future:episodes,builder:(c,e){final list=e.data??[];final seasons=list.map((x)=>x.season).toSet().toList()..sort();if(list.isEmpty)return const Text('No episodes found');if(!seasons.contains(season))season=seasons.first;return Column(children:[if(seasons.length>1)Align(alignment:Alignment.centerLeft,child:DropdownButton<int>(value:season,items:seasons.map((x)=>DropdownMenuItem(value:x,child:Text('Season $x'))).toList(),onChanged:(x){if(x!=null)setState(()=>season=x);})),...list.where((x)=>x.season==season).map((ep)=>ListTile(contentPadding:EdgeInsets.zero,leading:CircleAvatar(child:Text('${ep.number}')),title:Text(ep.title.isEmpty?'Episode ${ep.number}':ep.title),subtitle:ep.overview.isEmpty?null:Text(ep.overview,maxLines:2,overflow:TextOverflow.ellipsis),trailing:const Icon(Icons.play_circle_fill),onTap:()=>Navigator.push(context,MaterialPageRoute(builder:(_)=>WatchPage(api:widget.api,title:t,episode:ep))))]);})]))]);}));
}
