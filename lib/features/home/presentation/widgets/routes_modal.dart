import 'package:flutter/material.dart';
import '../../../../core/services/pathfinding_service.dart' as pathfinding;
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../ar_navigation/presentation/screens/ar_screen.dart';

class RoutesModal extends StatefulWidget {
  final List<pathfinding.Route> routes;
  final VoidCallback? onNavigate;
  final Function(pathfinding.Route)? onRouteSelected;
  final String? destinationLabel;

  const RoutesModal({
    super.key,
    required this.routes,
    this.onNavigate,
    this.onRouteSelected,
    this.destinationLabel,
  });

  @override
  State<RoutesModal> createState() => _RoutesModalState();
}

class _RoutesModalState extends State<RoutesModal> {
  pathfinding.Route? _selectedRoute;
  bool _showAll = false;

  static const int _initialDisplayCount = 4;

  @override
  void initState() {
    super.initState();
    // Auto-select the recommended route on open
    _selectedRoute = widget.routes.firstWhere(
      (r) => r.isRecommended,
      orElse: () => widget.routes.first,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.routes.isEmpty) {
      return _buildEmptyState(context);
    }

    final bool hasMore = widget.routes.length > _initialDisplayCount;
    final displayedRoutes = _showAll
        ? widget.routes
        : widget.routes.take(_initialDisplayCount).toList();
    final hiddenCount = widget.routes.length - _initialDisplayCount;

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          child: Column(
            children: [
              _buildHeader(context),
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                  // cards + optional "show all" row + navigate button
                  itemCount: displayedRoutes.length + (hasMore ? 1 : 0) + 1,
                  itemBuilder: (context, index) {
                    // Route cards
                    if (index < displayedRoutes.length) {
                      return _RouteCard(
                        route: displayedRoutes[index],
                        index: index + 1,
                        isSelected: _selectedRoute == displayedRoutes[index],
                        onTap: () {
                          setState(
                            () => _selectedRoute = displayedRoutes[index],
                          );
                        },
                      );
                    }

                    // "Show all / show less" small inline button
                    if (hasMore && index == displayedRoutes.length) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: GestureDetector(
                          onTap: () => setState(() => _showAll = !_showAll),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                _showAll
                                    ? Icons.keyboard_arrow_up
                                    : Icons.keyboard_arrow_down,
                                size: 18,
                                color: AppColors.primary,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                _showAll
                                    ? 'Show less'
                                    : 'Show all routes  •  $hiddenCount more',
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }
                    // Navigate button — always last
                    return Padding(
                      padding: const EdgeInsets.fromLTRB(0, 12, 0, 24),
                      child: SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _selectedRoute != null
                              ? () {
                                  widget.onRouteSelected?.call(_selectedRoute!);
                                  widget.onNavigate?.call();
                                  // Close modal first
                                  Navigator.pop(context);
                                  // Push AR screen directly
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => ArScreen(
                                        selectedRoute: _selectedRoute,
                                        destinationLabel:
                                            widget.destinationLabel,
                                      ),
                                    ),
                                  );
                                }
                              : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: AppColors.textOnPrimary,
                            disabledBackgroundColor: AppColors.primary
                                .withValues(alpha: 0.4),
                            disabledForegroundColor: AppColors.textOnPrimary,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: Text(
                            'Start Navigation',
                            style: AppTextStyles.buttonLarge.copyWith(
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Available Routes', style: AppTextStyles.headlineSmall),
              Text(
                '${widget.routes.length} route${widget.routes.length != 1 ? 's' : ''} found',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.map_outlined,
              size: 64,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: 16),
            Text('No Routes Found', style: AppTextStyles.headlineSmall),
            const SizedBox(height: 8),
            Text(
              'Unable to find a route between the selected locations.',
              style: AppTextStyles.body,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Go Back'),
            ),
          ],
        ),
      ),
    );
  }
}

class _RouteCard extends StatefulWidget {
  final pathfinding.Route route;
  final int index;
  final bool isSelected;
  final VoidCallback onTap;

  const _RouteCard({
    required this.route,
    required this.index,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<_RouteCard> createState() => _RouteCardState();
}

class _RouteCardState extends State<_RouteCard> {
  static const Color _crimson = Color(0xFFDC143C);
  bool _waypointsExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      color: widget.isSelected
          ? const Color.fromARGB(250, 250, 250, 250)
          : const Color.fromARGB(246, 246, 246, 246),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: widget.isSelected ? _crimson : Colors.transparent,
          width: 1.5,
        ),
      ),
      child: InkWell(
        onTap: widget.onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.route.routeName,
                      style: AppTextStyles.titleLarge.copyWith(
                        fontWeight: FontWeight.w700,
                        color: widget.isSelected
                            ? _crimson
                            : AppColors.textDark,
                      ),
                    ),
                  ),
                  if (widget.route.isRecommended)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: widget.isSelected ? _crimson : AppColors.primary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.star, size: 14, color: Colors.white),
                          const SizedBox(width: 4),
                          Text(
                            'RECOMMENDED',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              // Details row
              Row(
                children: [
                  Expanded(
                    child: _RouteDetail(
                      icon: Icons.straight,
                      label: 'Distance',
                      value: widget.route.formattedDistance,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _RouteDetail(
                      icon: Icons.schedule,
                      label: 'Duration',
                      value:
                          '${widget.route.walkingTime.toStringAsFixed(0)} min',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _RouteDetail(
                      icon: Icons.directions_walk,
                      label: 'Via',
                      value: widget.route.viaMode.replaceFirst('Via ', ''),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _buildWaypointsPreview(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWaypointsPreview() {
    final waypointsCount = widget.route.path.length;
    const previewCount = 3; // always show first 3 stops collapsed
    final hasMore = waypointsCount > previewCount;
    final displayCount = _waypointsExpanded
        ? waypointsCount
        : previewCount.clamp(0, waypointsCount);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row with eye icon
          Row(
            children: [
              Text(
                'Route Preview',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const Spacer(),
              if (hasMore)
                GestureDetector(
                  onTap: () =>
                      setState(() => _waypointsExpanded = !_waypointsExpanded),
                  child: Row(
                    children: [
                      Icon(
                        _waypointsExpanded
                            ? Icons.visibility_off
                            : Icons.visibility,
                        size: 14,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 3),
                      Text(
                        _waypointsExpanded
                            ? 'Show less'
                            : '${waypointsCount - previewCount} more',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 6),
          // Waypoint rows
          for (int i = 0; i < displayCount; i++)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                children: [
                  if (i == 0)
                    const Icon(
                      Icons.location_on,
                      size: 14,
                      color: AppColors.primary,
                    )
                  else if (i == waypointsCount - 1)
                    const Icon(Icons.location_on, size: 14, color: Colors.red)
                  else
                    const Icon(
                      Icons.stop_circle_outlined,
                      size: 14,
                      color: AppColors.textSecondary,
                    ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      widget.route.path[i].name, // direct index now, no skip
                      style: AppTextStyles.bodySmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _RouteDetail extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _RouteDetail({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: AppColors.primary),
            const SizedBox(width: 4),
            Text(
              label,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: AppTextStyles.body.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.textDark,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
