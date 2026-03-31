import '../../../../core/errors/exceptions.dart';
import '../../../../core/services/supabase_service.dart';
import '../models/route_path_model.dart';

class ArNavigationRemoteDatasource {
  Future<RoutePathModel> getArRoute({
    required String destinationId,
    required double userLatitude,
    required double userLongitude,
  }) async {
    try {
      final data = await SupabaseService.client
          .rpc('get_ar_route', params: {
            'destination_id': destinationId,
            'user_lat': userLatitude,
            'user_lon': userLongitude,
          });
      return RoutePathModel.fromJson(data as Map<String, dynamic>);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}
