import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

import 'package:mobile/providers/map_provider.dart';
import 'package:mobile/models/map_click.dart';

class MapTapBottomSheet extends StatelessWidget {
  const MapTapBottomSheet({super.key, required this.tapPoint});

  final LatLng tapPoint;

  @override
  Widget build(BuildContext context) {
    final mapProvider = context.watch<MapProvider>();
    final tapResult = mapProvider.tapResult;
    final isLoading = mapProvider.isTapLoading;
    final error = mapProvider.tapError;

    final coordsText =
        '${tapPoint.latitude.toStringAsFixed(6)}, ${tapPoint.longitude.toStringAsFixed(6)}';

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.4,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Text(
                'Точка на карте',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 4),
              Text(
                coordsText,
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: Colors.grey),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: () {
                  if (isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (error != null) {
                    return Center(child: Text(error));
                  }

                  if (tapResult == null || tapResult.groups.isEmpty) {
                    return const Center(
                      child: Text(
                        'Здесь пока нет мест из справочника.',
                        textAlign: TextAlign.center,
                      ),
                    );
                  }

                  final groups = tapResult.groups;

                  return ListView.separated(
                    itemCount: groups.length,
                    separatorBuilder: (_, __) => const Divider(height: 16),
                    itemBuilder: (context, index) {
                      final group = groups[index];
                      return MapTapGroupTile(group: group);
                    },
                  );
                }(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MapTapGroupTile extends StatelessWidget {
  const MapTapGroupTile({super.key, required this.group});

  final MapClickGroup group;

  @override
  Widget build(BuildContext context) {
    final mapProvider = context.read<MapProvider>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          group.address,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        ...group.places.map((place) {
          return ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(place.name),
            subtitle: Text(
              '${place.distanceM?.toStringAsFixed(0) ?? '-'} м',
              style: const TextStyle(fontSize: 12),
            ),
            onTap: () async {
              await mapProvider.highlightPlace(place.id);
              if (context.mounted) {
                Navigator.of(context).pop();
              }
            },
          );
        }),
      ],
    );
  }
}
