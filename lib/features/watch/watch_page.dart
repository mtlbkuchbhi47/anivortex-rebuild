import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/api.dart';
import '../../core/models.dart';
import '../../core/downloads.dart';
import '../../core/progress.dart';

class WatchPage extends StatefulWidget {
  const WatchPage({
    super.key,
    required this.title,
    required this.api,
    this.episode,
  });

  final TitleItem title;
  final ApiClient api;
  final EpisodeItem? episode;

  @override
  State<WatchPage> createState() => _WatchPageState();
}

class _WatchPageState extends State<WatchPage> {
  List<EpisodeItem> episodes = [];
  List<StreamOption> streams = [];

  VideoPlayerController? player;

  int selectedEpisode = 1;
  int streamIndex = 0;

  double speed = 1.0;
  bool loading = true;
  String message = '';

  @override
  void initState() {
    super.initState();
    selectedEpisode = widget.episode?.number ?? 1;
    loadEpisodes();
  }

  Future<void> loadEpisodes() async {
    try {
      final result = await widget.api.episodes(widget.title.id);

      if (!mounted) return;

      setState(() {
        episodes = result;
        loading = false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        loading = false;
      });
    }
  }

  Future<void> play() async {
    if (mounted) {
      setState(() {
        message = 'Finding stream...';
      });
    }

    try {
      final result = await widget.api.streams(
        titleId: widget.title.id,
        episode: selectedEpisode,
      );

      if (result.isEmpty) {
        if (mounted) {
          setState(() {
            message = 'No playable stream returned by the configured API.';
          });
        }
        return;
      }

      streams = result;
      streamIndex = 0;

      await openStream(streams.first);
    } catch (_) {
      if (mounted) {
        setState(() {
          message = 'Unable to load stream.';
        });
      }
    }
  }

  Future<void> openStream(StreamOption stream) async {
    try {
      player?.removeListener(saveProgress);
      await player?.dispose();

      final controller = VideoPlayerController.networkUrl(
        Uri.parse(stream.url),
        httpHeaders: stream.headers,
      );

      await controller.initialize();
      await controller.setPlaybackSpeed(speed);
      await controller.play();

      controller.addListener(saveProgress);

      if (!mounted) {
        await controller.dispose();
        return;
      }

      setState(() {
        player = controller;
        message = '';
      });
    } catch (_) {
      if (mounted) {
        setState(() {
          message = 'Player could not open this source.';
        });
      }
    }
  }

  Future<void> download() async {
    if (streams.isEmpty) {
      await play();
    }

    if (streams.isEmpty) {
      return;
    }

    final stream = streams[streamIndex];

    if (stream.url.contains('.m3u8')) {
      final uri = Uri.tryParse(stream.url);

      if (uri != null && await canLaunchUrl(uri)) {
        await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'This source is HLS. Opened the source externally; '
              'direct file downloads require a media downloader.',
            ),
          ),
        );
      }

      return;
    }

    final safeName = widget.title.name.replaceAll(
      RegExp(r'[^a-zA-Z0-9._-]+'),
      '_',
    );

    final path = await DownloadManager.instance.defaultPath(
      '${safeName}_E$selectedEpisode.mp4',
    );

    final task = await DownloadManager.instance.start(
      id: '${widget.title.id}-$selectedEpisode',
      title:
          '${widget.title.name} • Episode $selectedEpisode',
      url: stream.url,
      path: path,
      onChanged: (_) {
        if (mounted) {
          setState(() {});
        }
      },
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Download ${task.status}'),
        ),
      );
    }
  }

  void saveProgress() {
    final controller = player;

    if (controller == null ||
        !controller.value.isInitialized) {
      return;
    }

    final position =
        controller.value.position.inMilliseconds;
    final duration =
        controller.value.duration.inMilliseconds;

    if (duration <= 0) {
      return;
    }

    ProgressStore.save(
      WatchProgress(
        titleId: widget.title.id,
        title: widget.title.name,
        episode: selectedEpisode,
        positionMs: position,
        durationMs: duration,
        updatedAt:
            DateTime.now().millisecondsSinceEpoch,
      ),
    );
  }

  @override
  void dispose() {
    player?.removeListener(saveProgress);
    saveProgress();
    player?.dispose();

    super.dispose();
  }

  Widget streamControls() {
    if (streams.isEmpty) {
      return const SizedBox();
    }

    final currentStream =
        streams[streamIndex];

    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 14),
        Text(
          'Source / Quality',
          style:
              Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: List.generate(
            streams.length,
            (index) {
              final labels = <String>[
                streams[index].quality,
                streams[index].language,
              ].where(
                (value) => value.isNotEmpty,
              );

              final label = labels.isEmpty
                  ? 'Source ${index + 1}'
                  : labels.join(' • ');

              return ChoiceChip(
                label: Text(label),
                selected: streamIndex == index,
                onSelected: (_) {
                  setState(() {
                    streamIndex = index;
                  });

                  openStream(streams[index]);
                },
              );
            },
          ),
        ),
        if (currentStream.subtitles.isNotEmpty) ...[
          const SizedBox(height: 10),
          Text(
            'Subtitles',
            style:
                Theme.of(context).textTheme.titleMedium,
          ),
          ...currentStream.subtitles.map(
            (subtitle) => ListTile(
              dense: true,
              leading:
                  const Icon(Icons.subtitles),
              title: Text(subtitle),
              onTap: () {
                ScaffoldMessenger.of(context)
                    .showSnackBar(
                  SnackBar(
                    content:
                        Text('Subtitle track: $subtitle'),
                  ),
                );
              },
            ),
          ),
        ],
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = player;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title.name),
      ),
      body: ListView(
        padding: const EdgeInsets.all(14),
        children: [
          AspectRatio(
            aspectRatio: 16 / 9,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius:
                    BorderRadius.circular(12),
              ),
              child: controller != null &&
                      controller.value.isInitialized
                  ? ClipRRect(
                      borderRadius:
                          BorderRadius.circular(12),
                      child: Stack(
                        alignment:
                            Alignment.bottomCenter,
                        children: [
                          VideoPlayer(controller),
                          VideoProgressIndicator(
                            controller,
                            allowScrubbing: true,
                          ),
                        ],
                      ),
                    )
                  : Center(
                      child: IconButton(
                        iconSize: 72,
                        onPressed: play,
                        icon: const Icon(
                          Icons.play_circle_fill,
                        ),
                      ),
                    ),
            ),
          ),
          if (message.isNotEmpty)
            Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 8),
              child: Text(message),
            ),
          const SizedBox(height: 12),
          Text(
            widget.title.name,
            style:
                Theme.of(context).textTheme.headlineSmall,
          ),
          if (widget.title.overview.isNotEmpty)
            Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 8),
              child: Text(widget.title.overview),
            ),
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: play,
                  icon:
                      const Icon(Icons.play_arrow),
                  label: const Text('Play'),
                ),
              ),
              IconButton(
                onPressed: download,
                icon: const Icon(
                  Icons.download_outlined,
                ),
              ),
              PopupMenuButton<double>(
                onSelected: (value) {
                  setState(() {
                    speed = value;
                  });

                  player?.setPlaybackSpeed(value);
                },
                itemBuilder: (_) =>
                    <double>[
                  0.75,
                  1.0,
                  1.25,
                  1.5,
                  2.0,
                ]
                        .map(
                          (value) =>
                              PopupMenuItem<double>(
                            value: value,
                            child: Text('${value}x'),
                          ),
                        )
                        .toList(),
                child: const Padding(
                  padding: EdgeInsets.all(12),
                  child: Icon(Icons.speed),
                ),
              ),
            ],
          ),
          streamControls(),
          const SizedBox(height: 18),
          Text(
            'Episodes',
            style:
                Theme.of(context).textTheme.titleLarge,
          ),
          if (loading)
            const Padding(
              padding: EdgeInsets.all(20),
              child: Center(
                child:
                    CircularProgressIndicator(),
              ),
            )
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: episodes.map(
                (episode) {
                  return ChoiceChip(
                    label:
                        Text('${episode.number}'),
                    selected:
                        selectedEpisode ==
                            episode.number,
                    onSelected: (_) {
                      setState(() {
                        selectedEpisode =
                            episode.number;
                        streams = [];
                      });

                      player?.pause();
                    },
                  );
                },
              ).toList(),
            ),
        ],
      ),
    );
  }
}
