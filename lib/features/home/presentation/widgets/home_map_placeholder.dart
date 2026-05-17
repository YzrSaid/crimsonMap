import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart' as mbx;
import '../../../../core/constants/app_constants.dart';
import '../../../../core/services/mapbox_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../data/models/map_edge_model.dart';
import '../../data/models/map_info_model.dart';
import '../../data/models/map_node_model.dart';
import '../providers/map_data_provider.dart';
import '../providers/user_location_provider.dart';

class HomeMapPlaceholder extends ConsumerStatefulWidget {
  const HomeMapPlaceholder({super.key});

  @override
  ConsumerState<HomeMapPlaceholder> createState() => _HomeMapPlaceholderState();
}

class _HomeMapPlaceholderState extends ConsumerState<HomeMapPlaceholder> {
  mbx.MapboxMap? _map;
  mbx.CircleAnnotationManager? _infraCircleMgr;
  mbx.CircleAnnotationManager? _barrierCircleMgr;
  mbx.PointAnnotationManager? _labelMgr;
  mbx.PolylineAnnotationManager? _barrierLineMgr;

  bool _locating = false;

  static const double _defaultZoom = 16.5;
  static const double _userFocusZoom = 18.0;

  static const int _kInfraFill = 0xFF424242;
  static const int _kInfraStroke = 0xFFFFFFFF;
  static const int _kBarrierFill = 0xFFDC143C;
  static const int _kBarrierStroke = 0xFFFFFFFF;
  static const int _kBarrierLine = 0xFFDC143C;
  static const int _kLabelText = 0xFF212121;
  static const int _kLabelHalo = 0xFFFFFFFF;

  @override
  Widget build(BuildContext context) {
    if (AppConstants.mapboxAccessToken.isEmpty) {
      return const _MissingTokenView();
    }

    final currentMap = ref.watch(currentMapProvider);
    final nodesAsync = ref.watch(currentMapNodesProvider);
    ref.watch(currentMapEdgesProvider);
    ref.watch(infraAcronymsProvider);

    // Listen on the derived provider so `next` is the recomputed value —
    // reading currentMapProvider inside a selectedMapIdProvider listener
    // returns the previous value before invalidation has propagated.
    ref.listen<MapInfo?>(currentMapProvider, (prev, next) {
      if (next == null) return;
      if (prev?.mapId == next.mapId) return;
      _flyToMap(next);
    });
    ref.listen<AsyncValue<List<MapNode>>>(currentMapNodesProvider, (_, _) => _spawnAll());
    ref.listen<AsyncValue<List<MapEdge>>>(currentMapEdgesProvider, (_, _) => _spawnAll());
    ref.listen<AsyncValue<Map<String, String>>>(infraAcronymsProvider, (_, _) => _spawnAll());

    return Stack(
      children: [
        Positioned.fill(
          child: mbx.MapWidget(
            key: const ValueKey('home_mapbox_map'),
            cameraOptions: _initialCamera(currentMap),
            styleUri: MapboxService.styleUri(),
            onMapCreated: _onMapCreated,
            onStyleLoadedListener: _onStyleLoaded,
          ),
        ),
        Positioned(
          top: 16,
          left: 0,
          right: 0,
          child: Center(
            child: _MapSelectorChip(
              label: currentMap?.name ?? 'WMSU MAP',
              onTap: () => _openMapPicker(context),
            ),
          ),
        ),
        Positioned(
          top: 16,
          right: 16,
          child: _SquareIconButton(
            icon: _locating ? Icons.gps_not_fixed : Icons.my_location,
            onTap: _locating ? null : _flyToUser,
          ),
        ),
        Positioned(
          top: 76,
          right: 16,
          child: _ZoomControls(
            onZoomIn: () => _nudgeZoom(1),
            onZoomOut: () => _nudgeZoom(-1),
          ),
        ),
        if (nodesAsync.isLoading)
          const Positioned(
            bottom: 16,
            left: 0,
            right: 0,
            child: Center(child: _LoadingPill()),
          ),
      ],
    );
  }

  mbx.CameraOptions _initialCamera(MapInfo? info) {
    final lat = info?.centerLat ?? AppConstants.defaultLatitude;
    final lng = info?.centerLng ?? AppConstants.defaultLongitude;
    return mbx.CameraOptions(
      center: mbx.Point(coordinates: mbx.Position(lng, lat)),
      zoom: _defaultZoom,
    );
  }

  Future<void> _onMapCreated(mbx.MapboxMap controller) async {
    _map = controller;

    // Google-Maps-style user puck: a blue dot with a directional cone that
    // rotates with the device's compass heading, plus a soft accuracy ring.
    // Mapbox handles GPS streaming + smooth follow internally once enabled.
    await controller.location.updateSettings(
      mbx.LocationComponentSettings(
        enabled: true,
        pulsingEnabled: true,
        pulsingColor: 0xFF4285F4,
        showAccuracyRing: true,
        accuracyRingColor: 0x334285F4,
        accuracyRingBorderColor: 0x554285F4,
        puckBearingEnabled: true,
        puckBearing: mbx.PuckBearing.HEADING,
      ),
    );
    await controller.scaleBar.updateSettings(mbx.ScaleBarSettings(enabled: false));
    await controller.compass.updateSettings(mbx.CompassSettings(enabled: false));
    await controller.logo.updateSettings(
      mbx.LogoSettings(marginLeft: 8, marginBottom: 8),
    );
    await controller.attribution.updateSettings(
      mbx.AttributionSettings(marginRight: 8, marginBottom: 8),
    );

    _infraCircleMgr = await controller.annotations.createCircleAnnotationManager();
    _barrierLineMgr = await controller.annotations.createPolylineAnnotationManager();
    _barrierCircleMgr = await controller.annotations.createCircleAnnotationManager();
    _labelMgr = await controller.annotations.createPointAnnotationManager();

    final info = ref.read(currentMapProvider);
    if (info != null) await _flyToMap(info);

    await _spawnAll();
  }

  Future<void> _onStyleLoaded(mbx.StyleLoadedEventData _) async {
    final map = _map;
    if (map == null) return;
    try {
      final layers = await map.style.getStyleLayers();
      for (final layer in layers) {
        final id = layer?.id;
        if (id == null) continue;
        if (id.toLowerCase().contains('label')) {
          await map.style.setStyleLayerProperty(id, 'visibility', 'none');
        }
      }
    } catch (_) {}
  }

  Future<void> _spawnAll() async {
    final infraMgr = _infraCircleMgr;
    final barrierMgr = _barrierCircleMgr;
    final labelMgr = _labelMgr;
    final lineMgr = _barrierLineMgr;
    if (infraMgr == null || barrierMgr == null || labelMgr == null || lineMgr == null) {
      return;
    }

    final nodes = ref.read(currentMapNodesProvider).valueOrNull;
    final edges = ref.read(currentMapEdgesProvider).valueOrNull ?? const <MapEdge>[];
    final acronyms = ref.read(infraAcronymsProvider).valueOrNull ?? const <String, String>{};
    if (nodes == null) return;

    await infraMgr.deleteAll();
    await barrierMgr.deleteAll();
    await labelMgr.deleteAll();
    await lineMgr.deleteAll();

    final infraCircles = <mbx.CircleAnnotationOptions>[];
    final barrierCircles = <mbx.CircleAnnotationOptions>[];
    final labels = <mbx.PointAnnotationOptions>[];
    final barrierById = <String, MapNode>{};

    for (final n in nodes) {
      final point = mbx.Point(
        coordinates: mbx.Position(n.longitude!, n.latitude!),
      );
      switch (n.type) {
        case MapNodeType.infrastructure:
        case MapNodeType.indoorInfra:
          infraCircles.add(mbx.CircleAnnotationOptions(
            geometry: point,
            circleColor: _kInfraFill,
            circleRadius: 6,
            circleStrokeColor: _kInfraStroke,
            circleStrokeWidth: 2,
          ));
          final label = acronyms[n.relatedInfraId] ?? n.name;
          if (label.isNotEmpty) {
            labels.add(mbx.PointAnnotationOptions(
              geometry: point,
              textField: label,
              textOffset: [0, 1.6],
              textSize: 11,
              textColor: _kLabelText,
              textHaloColor: _kLabelHalo,
              textHaloWidth: 1.5,
            ));
          }
          break;
        case MapNodeType.barrier:
          barrierById[n.nodeId] = n;
          barrierCircles.add(mbx.CircleAnnotationOptions(
            geometry: point,
            circleColor: _kBarrierFill,
            circleRadius: 5,
            circleStrokeColor: _kBarrierStroke,
            circleStrokeWidth: 1.5,
          ));
          break;
        case MapNodeType.intermediate:
        case MapNodeType.unknown:
          break;
      }
    }

    final barrierLines = <mbx.PolylineAnnotationOptions>[];
    for (final edge in edges) {
      final from = barrierById[edge.fromNodeId];
      final to = barrierById[edge.toNodeId];
      if (from == null || to == null) continue;
      barrierLines.add(mbx.PolylineAnnotationOptions(
        geometry: mbx.LineString(coordinates: [
          mbx.Position(from.longitude!, from.latitude!),
          mbx.Position(to.longitude!, to.latitude!),
        ]),
        lineColor: _kBarrierLine,
        lineWidth: 3.0,
        lineOpacity: 0.9,
      ));
    }

    if (infraCircles.isNotEmpty) await infraMgr.createMulti(infraCircles);
    if (barrierLines.isNotEmpty) await lineMgr.createMulti(barrierLines);
    if (barrierCircles.isNotEmpty) await barrierMgr.createMulti(barrierCircles);
    if (labels.isNotEmpty) await labelMgr.createMulti(labels);
  }

  Future<void> _flyToMap(MapInfo info) async {
    final map = _map;
    if (map == null) return;
    await map.flyTo(
      mbx.CameraOptions(
        center: mbx.Point(coordinates: mbx.Position(info.centerLng, info.centerLat)),
        zoom: _defaultZoom,
      ),
      mbx.MapAnimationOptions(duration: 800),
    );
  }

  Future<void> _flyToUser() async {
    final map = _map;
    if (map == null) return;

    setState(() => _locating = true);
    try {
      final pos = await resolveCurrentUserPosition();
      await map.flyTo(
        mbx.CameraOptions(
          center: mbx.Point(coordinates: mbx.Position(pos.longitude, pos.latitude)),
          zoom: _userFocusZoom,
        ),
        mbx.MapAnimationOptions(duration: 900),
      );
    } on UserLocationException catch (e) {
      if (!mounted) return;
      _showLocationError(e.reason);
    } catch (_) {
      if (!mounted) return;
      _showLocationError(UserLocationFailure.unknown);
    } finally {
      if (mounted) setState(() => _locating = false);
    }
  }

  void _showLocationError(UserLocationFailure reason) {
    final message = switch (reason) {
      UserLocationFailure.serviceDisabled =>
        'Turn on location services to find your position.',
      UserLocationFailure.permissionDenied =>
        'Location permission is required to show where you are.',
      UserLocationFailure.permissionDeniedForever =>
        'Location is permanently denied. Enable it in system settings.',
      UserLocationFailure.unknown => 'Could not fetch your location.',
    };
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }

  Future<void> _nudgeZoom(double delta) async {
    final map = _map;
    if (map == null) return;
    final cam = await map.getCameraState();
    await map.easeTo(
      mbx.CameraOptions(zoom: cam.zoom + delta),
      mbx.MapAnimationOptions(duration: 250),
    );
  }

  Future<void> _openMapPicker(BuildContext context) async {
    final maps = ref.read(mapsListProvider).valueOrNull ?? const <MapInfo>[];
    if (maps.isEmpty) return;
    final currentId = ref.read(selectedMapIdProvider);

    final picked = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Row(
                children: [
                  Text(
                    'Select Map',
                    style: AppTextStyles.h3.copyWith(fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ),
            for (final m in maps)
              ListTile(
                leading: Icon(
                  m.mapId == currentId
                      ? Icons.radio_button_checked
                      : Icons.radio_button_unchecked,
                  color: AppColors.primary,
                ),
                title: Text(m.name, style: AppTextStyles.body),
                subtitle: Text(
                  '${m.campusIds.length} campus(es) • ${m.mapId}',
                  style: AppTextStyles.body.copyWith(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                onTap: () => Navigator.of(ctx).pop(m.mapId),
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );

    if (picked != null && picked != currentId) {
      ref.read(selectedMapIdProvider.notifier).state = picked;
    }
  }
}

class _MissingTokenView extends StatelessWidget {
  const _MissingTokenView();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFE5E5E5),
      alignment: Alignment.center,
      child: const Icon(
        Icons.map_outlined,
        size: 48,
        color: AppColors.textSecondary,
      ),
    );
  }
}

class _LoadingPill extends StatelessWidget {
  const _LoadingPill();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(999),
        boxShadow: const [
          BoxShadow(color: AppColors.shadow, blurRadius: 8, offset: Offset(0, 2)),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(
            width: 14,
            height: 14,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          const SizedBox(width: 10),
          Text('Loading spawners…', style: AppTextStyles.body.copyWith(fontSize: 12)),
        ],
      ),
    );
  }
}

class _SquareIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;

  const _SquareIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final disabled = onTap == null;
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(8),
      elevation: 2,
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: SizedBox(
          width: 44,
          height: 44,
          child: Icon(
            icon,
            color: disabled ? AppColors.textSecondary : AppColors.textDark,
            size: 22,
          ),
        ),
      ),
    );
  }
}

class _MapSelectorChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _MapSelectorChip({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(8),
      elevation: 2,
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: SizedBox(
          width: 180,
          height: 48,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600),
                  ),
                ),
                const Icon(Icons.expand_more, size: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ZoomControls extends StatelessWidget {
  final VoidCallback onZoomIn;
  final VoidCallback onZoomOut;

  const _ZoomControls({required this.onZoomIn, required this.onZoomOut});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(8),
      elevation: 2,
      child: Column(
        children: [
          InkWell(
            onTap: onZoomIn,
            child: const SizedBox(
              width: 44,
              height: 44,
              child: Icon(Icons.add, color: AppColors.textDark),
            ),
          ),
          const SizedBox(
            width: 32,
            height: 1,
            child: ColoredBox(color: AppColors.divider),
          ),
          InkWell(
            onTap: onZoomOut,
            child: const SizedBox(
              width: 44,
              height: 44,
              child: Icon(Icons.remove, color: AppColors.textDark),
            ),
          ),
        ],
      ),
    );
  }
}
