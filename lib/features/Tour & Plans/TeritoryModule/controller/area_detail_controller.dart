import 'package:latlong2/latlong.dart';

import '../model/area_model.dart';

import 'package:get/get.dart';

import '../model/chemist_location_model.dart';
import '../model/doctor_location_model.dart';
import '../model/stockist_location_model.dart';


class AreaDetailController extends GetxController {
  final AreaModel area;

  final List<DoctorLocationModel> doctors;
  final List<ChemistLocationModel> chemists;
  final List<StockistLocationModel> stockists;
  final Distance distance = const Distance();

  AreaDetailController({
    required this.area,
    required this.doctors,
    required this.chemists,
    required this.stockists,
  });

  final RxList<DoctorLocationModel> areaDoctors =
      <DoctorLocationModel>[].obs;

  final RxList<ChemistLocationModel> areaChemists =
      <ChemistLocationModel>[].obs;

  final RxList<StockistLocationModel> areaStockists =
      <StockistLocationModel>[].obs;

  final dynamicRadius = 0.0.obs;

  @override
  void onInit() {
    super.onInit();

    _filterEntities();
    calculateRadius();
  }

  void _filterEntities() {
    areaDoctors.assignAll(
      doctors.where((doctor) => doctor.areaId == area.id).toList(),
    );

    areaChemists.assignAll(
      chemists.where((chemist) => chemist.areaId == area.id).toList(),
    );

    areaStockists.assignAll(
      stockists.where((stockist) => stockist.areaId == area.id).toList(),
    );
  }

  void calculateRadius() {
    double radius = area.radius;

    final center = LatLng(
      area.latitude,
      area.longitude,
    );

    for (final doctor in areaDoctors) {
      final d = distance.as(
        LengthUnit.Meter,
        center,
        LatLng(
          doctor.latitude,
          doctor.longitude,
        ),
      );

      if (d > radius) {
        radius = d;
      }
    }

    for (final chemist in areaChemists) {
      final d = distance.as(
        LengthUnit.Meter,
        center,
        LatLng(
          chemist.latitude,
          chemist.longitude,
        ),
      );

      if (d > radius) {
        radius = d;
      }
    }

    for (final stockist in areaStockists) {
      final d = distance.as(
        LengthUnit.Meter,
        center,
        LatLng(
          stockist.latitude,
          stockist.longitude,
        ),
      );

      if (d > radius) {
        radius = d;
      }
    }

    dynamicRadius.value = radius + 100;
  }
}