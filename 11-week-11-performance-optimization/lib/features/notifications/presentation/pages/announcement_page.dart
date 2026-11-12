import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class AnnouncementPage extends StatelessWidget {
  const AnnouncementPage({super.key, required this.id});

  final String id;

  /// Placeholder banner URL — replace with a real CDN URL in production.
  static const _placeholderImageUrl =
      'https://picsum.photos/seed/campus/800/300';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Announcement $id')),
      body: ListView(
        children: [
          // ----------------------------------------------------------------
          // OPTIMIZATION: CachedNetworkImage replaces Image.network.
          //
          // Benefits:
          //  • Images are stored on disk — subsequent loads are instant and
          //    consume zero bandwidth.
          //  • memCacheWidth / memCacheHeight tell the decoder to downscale
          //    to display size in memory, not full resolution. Avoids large
          //    bitmaps sitting in the image cache eating RAM.
          //  • placeholder shows a progress indicator while loading so the
          //    UI does not jump/reflow when the image arrives.
          //  • errorWidget provides graceful fallback instead of a blank gap.
          // ----------------------------------------------------------------
          CachedNetworkImage(
            imageUrl: _placeholderImageUrl,
            // Decode at display size — avoids holding a full-resolution bitmap
            // in memory when the widget only occupies ~200 px of height.
            memCacheWidth: MediaQuery.sizeOf(context).width.toInt(),
            memCacheHeight: 200,
            fadeInDuration: const Duration(milliseconds: 200),
            placeholder: (context, url) => const SizedBox(
              height: 200,
              child: Center(child: CircularProgressIndicator()),
            ),
            errorWidget: (context, url, error) => const SizedBox(
              height: 200,
              child: Center(child: Icon(Icons.broken_image_outlined, size: 48)),
            ),
            imageBuilder: (context, imageProvider) => Container(
              height: 200,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: imageProvider,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Announcement #$id',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 12),
                const Text(
                  'Announcement detail content goes here. '
                  'In a real app this would be fetched from the backend '
                  'using the announcement id.',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
