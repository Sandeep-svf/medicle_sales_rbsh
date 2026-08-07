import 'package:medicle_sales_rbsh/features/Tour%20&%20Plans/TeritoryModule/model/stockist_location_model.dart';

import 'area_model.dart';
import 'beat_area_model.dart';
import 'beat_model.dart';
import 'chemist_location_model.dart';
import 'doctor_location_model.dart';




class TerritoryMasterModel {
  final List<AreaModel> areas;
  final List<DoctorLocationModel> doctors;
  final List<ChemistLocationModel> chemists;
  final List<StockistLocationModel> stockists;
  final List<BeatModel> beats;
  final List<BeatAreaModel> beatAreas;

  TerritoryMasterModel({
    required this.areas,
    required this.doctors,
    required this.chemists,
    required this.stockists,
    required this.beats,
    required this.beatAreas,
  });

  factory TerritoryMasterModel.fromJson(Map<String, dynamic> json) {
    return TerritoryMasterModel(
      areas: (json["areas"] as List? ?? [])
          .map((e) => AreaModel.fromJson(e))
          .toList(),

      doctors: (json["doctors"] as List? ?? [])
          .map((e) => DoctorLocationModel.fromJson(e))
          .toList(),

      chemists: (json["chemists"] as List? ?? [])
          .map((e) => ChemistLocationModel.fromJson(e))
          .toList(),

      stockists: (json["stockists"] as List? ?? [])
          .map((e) => StockistLocationModel.fromJson(e))
          .toList(),

      beats: (json["beats"] as List? ?? [])
          .map((e) => BeatModel.fromJson(e))
          .toList(),

      beatAreas: (json["beatAreas"] as List? ?? [])
          .map((e) => BeatAreaModel.fromJson(e))
          .toList(),
    );
  }
}