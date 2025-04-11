/*
import 'package:flutter_background_service/flutter_background_service.dart';

import 'LocationService.dart';
// adjust if needed

@pragma('vm:entry-point')
void onStart(ServiceInstance service) {
  LocationService.start(service);

  service.on('stopService').listen((_) {
    LocationService.stop();
    service.stopSelf();
  });
}
*/
