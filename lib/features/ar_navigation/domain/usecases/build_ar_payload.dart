import '../entities/route_path.dart';
import '../../integration/ar_payload_builder.dart';

class BuildArPayload {
  Map<String, dynamic> call(RoutePath route) =>
      ArPayloadBuilder.build(route);
}
