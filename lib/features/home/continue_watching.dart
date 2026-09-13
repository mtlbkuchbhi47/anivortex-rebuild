import 'package:flutter/material.dart';
import '../../core/progress.dart';

class ContinueWatching extends StatelessWidget {
  const ContinueWatching({super.key, required this.onTap});
  final void Function(WatchProgress item) onTap;
  @override
  Widget build(BuildContext context) => FutureBuilder<List<WatchProgress>>(
    future: ProgressStore.all(),
    builder: (context, snap) {
      final items = snap.data ?? const <WatchProgress>[];
      if (items.isEmpty) return const SizedBox.shrink();
      return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(padding: const EdgeInsets.fromLTRB(16, 12, 16, 8), child: Text('Continue Watching', style: Theme.of(context).textTheme.titleLarge)),
        SizedBox(height: 92, child: ListView.separated(padding: const EdgeInsets.symmetric(horizontal:16), scrollDirection: Axis.horizontal, itemCount: items.take(10).length, separatorBuilder: (_,__)=>const SizedBox(width:10), itemBuilder: (_,i){final x=items[i];return SizedBox(width:230,child:Card(child:InkWell(onTap:()=>onTap(x),borderRadius:BorderRadius.circular(12),child:Padding(padding:const EdgeInsets.all(12),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text(x.title,maxLines:1,overflow:TextOverflow.ellipsis,style:const TextStyle(fontWeight:FontWeight.w600)),const SizedBox(height:5),Text('Episode ${x.episode}'),const SizedBox(height:6),LinearProgressIndicator(value:x.fraction)])))));}),),
      ]);
    },
  );
}
