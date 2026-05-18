import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../providers/destination_picker_provider.dart';

/// Modal sheet for selecting the FROM location
class FromLocationPickerSheet extends ConsumerStatefulWidget {
  const FromLocationPickerSheet({super.key});

  @override
  ConsumerState<FromLocationPickerSheet> createState() =>
      _FromLocationPickerSheetState();
}

class _FromLocationPickerSheetState
    extends ConsumerState<FromLocationPickerSheet> {
  String _query = '';
  final Set<String> _expanded = {};

  @override
  Widget build(BuildContext context) {
    final asyncBuildings = ref.watch(buildingsWithRoomsProvider);
    final selection = ref.watch(homeSelectionProvider);
    final sheetHeight = MediaQuery.of(context).size.height * 0.85;

    return Container(
      height: sheetHeight,
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.muted,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Row(
              children: [
                Text('Where are you now?', style: AppTextStyles.h3),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              autofocus: false,
              decoration: InputDecoration(
                hintText: 'Search buildings or rooms...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: const Color(0xFFF2F2F2),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 0,
                  horizontal: 12,
                ),
              ),
              onChanged: (v) => setState(() => _query = v.trim()),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: asyncBuildings.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text('Failed to load: $e', style: AppTextStyles.body),
                ),
              ),
              data: (buildings) {
                final filtered = _filter(buildings, _query);
                if (filtered.isEmpty) {
                  return const Center(child: Text('No results'));
                }
                return ListView.builder(
                  itemCount: filtered.length,
                  itemBuilder: (context, i) {
                    final b = filtered[i];
                    final isExpanded = _expanded.contains(b.infraId);
                    final isSelected =
                        selection.fromLocation?.infraId == b.infraId &&
                        selection.fromLocation?.roomId == null;
                    return _BuildingTile(
                      building: b,
                      expanded: isExpanded,
                      query: _query,
                      isSelected: isSelected,
                      onToggle: () => setState(() {
                        if (isExpanded) {
                          _expanded.remove(b.infraId);
                        } else {
                          _expanded.add(b.infraId);
                        }
                      }),
                      onSelectBuilding: () => _selectFrom(
                        DestinationSelection(label: b.name, infraId: b.infraId),
                      ),
                      onSelectRoom: (room) => _selectFrom(
                        DestinationSelection(
                          label: '${room.name} · ${b.name}',
                          infraId: b.infraId,
                          roomId: room.roomId,
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  List<BuildingOption> _filter(List<BuildingOption> all, String query) {
    if (query.isEmpty) return all;
    final q = query.toLowerCase();
    return all.where((b) {
      final matchesBuilding =
          b.name.toLowerCase().contains(q) ||
          (b.acronym?.toLowerCase().contains(q) ?? false);
      final matchesRoom = b.rooms.any((r) => r.name.toLowerCase().contains(q));
      return matchesBuilding || matchesRoom;
    }).toList();
  }

  void _selectFrom(DestinationSelection selection) {
    ref
        .read(homeSelectionProvider.notifier)
        .selectFrom(selection, autoLock: true);
    Navigator.of(context).pop();
  }
}

class _BuildingTile extends StatelessWidget {
  final BuildingOption building;
  final bool expanded;
  final bool isSelected;
  final String query;
  final VoidCallback onToggle;
  final VoidCallback onSelectBuilding;
  final void Function(RoomOption) onSelectRoom;

  const _BuildingTile({
    required this.building,
    required this.expanded,
    required this.isSelected,
    required this.query,
    required this.onToggle,
    required this.onSelectBuilding,
    required this.onSelectRoom,
  });

  @override
  Widget build(BuildContext context) {
    final hasRooms = building.rooms.isNotEmpty;
    final filteredRooms = query.isEmpty
        ? building.rooms
        : building.rooms
              .where((r) => r.name.toLowerCase().contains(query.toLowerCase()))
              .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        InkWell(
          onTap: onSelectBuilding,
          child: Container(
            color: isSelected
                ? AppColors.primary.withValues(alpha: 0.1)
                : Colors.transparent,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                const Icon(
                  Icons.location_city,
                  size: 22,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        building.name,
                        style: AppTextStyles.body.copyWith(
                          fontWeight: isSelected
                              ? FontWeight.w700
                              : FontWeight.w600,
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.textDark,
                        ),
                      ),
                      if (building.acronym != null &&
                          building.acronym!.isNotEmpty)
                        Text(building.acronym!, style: AppTextStyles.bodySmall),
                    ],
                  ),
                ),
                if (isSelected)
                  const Icon(
                    Icons.check_circle,
                    color: AppColors.primary,
                    size: 20,
                  ),
                if (hasRooms && !isSelected)
                  IconButton(
                    icon: Icon(
                      expanded ? Icons.expand_less : Icons.expand_more,
                    ),
                    onPressed: onToggle,
                  ),
              ],
            ),
          ),
        ),
        if (hasRooms && expanded)
          ...filteredRooms.map(
            (r) => InkWell(
              onTap: () => onSelectRoom(r),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(48, 8, 16, 8),
                child: Row(
                  children: [
                    const Icon(
                      Icons.meeting_room_outlined,
                      size: 18,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 12),
                    Expanded(child: Text(r.name, style: AppTextStyles.body)),
                  ],
                ),
              ),
            ),
          ),
        const Divider(height: 1, color: Color(0xFFE0E0E0)),
      ],
    );
  }
}
