import '../../../../core/errors/exceptions.dart';
import '../../../../core/services/local_data_service.dart';
import '../models/destination_model.dart';
import '../models/building_model.dart';
import '../models/category_model.dart';

// Loads the campus catalog from bundled JSON in assets/data/.
// infrastructure.json holds the destinations/buildings, joined with
// nodes_MAP-XX.json (where type == "infrastructure") to get coordinates.
class ExploreLocalDatasource {
  final LocalDataService _data;
  ExploreLocalDatasource({LocalDataService? data})
      : _data = data ?? LocalDataService.instance;

  Future<List<DestinationModel>> getDestinations() async {
    try {
      final infra = await _data.infrastructure();
      final nodesByInfra = await _data.infraNodesByInfraId();
      return infra
          .where((row) => row['is_deleted'] != true)
          .map((row) => _toDestination(row, nodesByInfra))
          .where((d) => d != null)
          .cast<DestinationModel>()
          .toList();
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  Future<List<DestinationModel>> searchDestinations(String query) async {
    final all = await getDestinations();
    if (query.trim().isEmpty) return all;
    final lower = query.toLowerCase();
    return all
        .where((d) =>
            d.name.toLowerCase().contains(lower) ||
            (d.description?.toLowerCase().contains(lower) ?? false))
        .toList();
  }

  Future<DestinationModel> getDestinationDetails(String id) async {
    final infra = await _data.infrastructure();
    final nodesByInfra = await _data.infraNodesByInfraId();
    final row = infra.firstWhere(
      (r) => r['infra_id'] == id || r['id'] == id,
      orElse: () => throw ServerException('Destination $id not found'),
    );
    final dest = _toDestination(row, nodesByInfra);
    if (dest == null) {
      throw ServerException('Destination $id has no coordinates');
    }
    return dest;
  }

  Future<List<BuildingModel>> getBuildings() async {
    // This campus model treats every infrastructure as a "building".
    final destinations = await getDestinations();
    return destinations
        .map((d) => BuildingModel(
              id: d.id,
              name: d.name,
              description: d.description,
              latitude: d.latitude,
              longitude: d.longitude,
              imageUrl: d.imageUrl,
            ))
        .toList();
  }

  Future<List<CategoryModel>> getCategories() async {
    try {
      final rows = await _data.categories();
      return rows
          .where((r) => r['is_deleted'] != true)
          .map((r) => CategoryModel(
                id: (r['category_id'] ?? r['id']).toString(),
                name: r['name'] as String? ?? '',
                iconName: r['icon'] as String?,
                color: null,
              ))
          .toList();
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  DestinationModel? _toDestination(
    Map<String, dynamic> infra,
    Map<String, Map<String, dynamic>> nodesByInfra,
  ) {
    final infraId = infra['infra_id'] as String?;
    if (infraId == null) return null;
    final node = nodesByInfra[infraId];
    if (node == null) return null;
    final lat = (node['latitude'] as num?)?.toDouble();
    final lng = (node['longitude'] as num?)?.toDouble();
    if (lat == null || lng == null) return null;
    return DestinationModel(
      id: infraId,
      name: infra['name'] as String? ?? '',
      description: infra['acronym'] as String?,
      latitude: lat,
      longitude: lng,
      imageUrl: (infra['image_url'] as String?)?.isEmpty == true
          ? null
          : infra['image_url'] as String?,
      categoryId: infra['category_id'] as String? ?? '',
      buildingId: infraId,
      floor: null,
      roomNumber: null,
    );
  }
}
