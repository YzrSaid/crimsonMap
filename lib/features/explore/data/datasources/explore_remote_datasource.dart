import '../../../../core/errors/exceptions.dart';
import '../../../../core/services/supabase_service.dart';
import '../models/destination_model.dart';
import '../models/building_model.dart';
import '../models/category_model.dart';

class ExploreRemoteDatasource {
  Future<List<DestinationModel>> getDestinations() async {
    try {
      final data = await SupabaseService.client.from('destinations').select();
      return (data as List).map((e) => DestinationModel.fromJson(e as Map<String, dynamic>)).toList();
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  Future<List<DestinationModel>> searchDestinations(String query) async {
    try {
      final data = await SupabaseService.client
          .from('destinations')
          .select()
          .ilike('name', '%$query%');
      return (data as List).map((e) => DestinationModel.fromJson(e as Map<String, dynamic>)).toList();
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  Future<DestinationModel> getDestinationDetails(String id) async {
    try {
      final data = await SupabaseService.client
          .from('destinations')
          .select()
          .eq('id', id)
          .single();
      return DestinationModel.fromJson(data as Map<String, dynamic>);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  Future<List<BuildingModel>> getBuildings() async {
    try {
      final data = await SupabaseService.client.from('buildings').select();
      return (data as List).map((e) => BuildingModel.fromJson(e as Map<String, dynamic>)).toList();
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  Future<List<CategoryModel>> getCategories() async {
    try {
      final data = await SupabaseService.client.from('categories').select();
      return (data as List).map((e) => CategoryModel.fromJson(e as Map<String, dynamic>)).toList();
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}
