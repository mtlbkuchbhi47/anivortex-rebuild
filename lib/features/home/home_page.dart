import 'package:flutter/material.dart';

import '../../core/api.dart';
import '../../core/models.dart';
import 'continue_watching.dart';
import '../watch/watch_page.dart';
import '../details/details_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({
    super.key,
    required this.api,
  });

  final ApiClient api;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<List<TitleItem>> future;

  @override
  void initState() {
    super.initState();
    future = widget.api.home();
  }

  Widget image(
    String url, {
    double? width,
  }) {
    if (url.startsWith('http')) {
      return Image.network(
        url,
        fit: BoxFit.cover,
        width: width,
        errorBuilder: (_, __, ___) {
          return const Center(
            child: Icon(Icons.broken_image),
          );
        },
      );
    }

    return Image.asset(
      url,
      fit: BoxFit.cover,
      width: width,
      errorBuilder: (_, __, ___) {
        return const Center(
          child: Icon(Icons.image_not_supported),
        );
      },
    );
  }

  Widget card(TitleItem item) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => DetailsPage(
              title: item,
              api: widget.api,
            ),
          ),
        );
      },
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: image(
                item.image,
                width: double.infinity,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(9),
              child: Text(
                item.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            if (item.subtitle.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(9, 0, 9, 9),
                child: Text(
                  item.subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        setState(() {
          future = widget.api.home();
        });
      },
      child: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            title: Image.asset(
              'assets/images/common/anivortex_logo_transparent.png',
              height: 34,
            ),
          ),
          SliverToBoxAdapter(
            child: ContinueWatching(
              onTap: (item) {
                final title = TitleItem(
                  id: item.titleId,
                  name: item.title,
                );

                final episode = EpisodeItem(
                  id: '${item.titleId}-e${item.episode}',
                  number: item.episode,
                );

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
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 18, 16, 10),
              child: Text(
                'New movie, series, and anime updates',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(12),
            sliver: FutureBuilder<List<TitleItem>>(
              future: future,
              builder: (context, snapshot) {
                if (snapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const SliverFillRemaining(
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                final items = snapshot.data ?? demoTitles;

                return SliverGrid.builder(
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: .68,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemCount: items.length,
                  itemBuilder: (_, index) => card(items[index]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
