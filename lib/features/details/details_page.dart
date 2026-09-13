import 'package:flutter/material.dart';

import '../../core/api.dart';
import '../../core/models.dart';
import '../watch/watch_page.dart';

class DetailsPage extends StatefulWidget {
  const DetailsPage({
    super.key,
    required this.api,
    required this.title,
  });

  final ApiClient api;
  final TitleItem title;

  @override
  State<DetailsPage> createState() => _DetailsPageState();
}

class _DetailsPageState extends State<DetailsPage> {
  late Future<TitleItem> details;
  late Future<List<EpisodeItem>> episodes;
  int season = 1;

  @override
  void initState() {
    super.initState();
    details = widget.api.details(widget.title.id);
    episodes = widget.api.episodes(widget.title.id);
  }

  Widget imageWidget(String url) {
    if (url.startsWith('http')) {
      return Image.network(
        url,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => const SizedBox(),
      );
    }

    return Image.asset(
      url.isEmpty
          ? 'assets/images/common/anivortex_logo.png'
          : url,
      fit: BoxFit.cover,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Details'),
      ),
      body: FutureBuilder<TitleItem>(
        future: details,
        builder: (context, snapshot) {
          final title = snapshot.data ?? widget.title;

          return ListView(
            children: [
              if (title.backdrop.isNotEmpty)
                SizedBox(
                  height: 210,
                  width: double.infinity,
                  child: imageWidget(title.backdrop),
                ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title.name,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      [
                        title.year,
                        title.type,
                        ...title.genres,
                      ].where((x) => x.isNotEmpty).join(' • '),
                    ),
                    if (title.overview.isNotEmpty) ...[
                      const SizedBox(height: 14),
                      Text(title.overview),
                    ],
                    const SizedBox(height: 18),
                    Text(
                      'Episodes',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    FutureBuilder<List<EpisodeItem>>(
                      future: episodes,
                      builder: (context, episodeSnapshot) {
                        final list = episodeSnapshot.data ?? [];

                        final seasons = list
                            .map((episode) => episode.season)
                            .toSet()
                            .toList()
                          ..sort();

                        if (list.isEmpty) {
                          return const Text('No episodes found');
                        }

                        if (!seasons.contains(season)) {
                          season = seasons.first;
                        }

                        final seasonEpisodes =
                            list.where((e) => e.season == season);

                        return Column(
                          children: [
                            if (seasons.length > 1)
                              Align(
                                alignment: Alignment.centerLeft,
                                child: DropdownButton<int>(
                                  value: season,
                                  items: seasons
                                      .map(
                                        (value) => DropdownMenuItem<int>(
                                          value: value,
                                          child: Text('Season $value'),
                                        ),
                                      )
                                      .toList(),
                                  onChanged: (value) {
                                    if (value != null) {
                                      setState(() => season = value);
                                    }
                                  },
                                ),
                              ),
                            ...seasonEpisodes.map(
                              (episode) => ListTile(
                                contentPadding: EdgeInsets.zero,
                                leading: CircleAvatar(
                                  child: Text('${episode.number}'),
                                ),
                                title: Text(
                                  episode.title.isEmpty
                                      ? 'Episode ${episode.number}'
                                      : episode.title,
                                ),
                                subtitle: episode.overview.isEmpty
                                    ? null
                                    : Text(
                                        episode.overview,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                trailing:
                                    const Icon(Icons.play_circle_fill),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => WatchPage(
                                        api: widget.api,
                                        title: title,
                                        episode: episode,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
