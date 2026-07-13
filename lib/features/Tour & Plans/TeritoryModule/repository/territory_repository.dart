import 'dart:convert';

import '../../../../utils/http/http_client.dart';
import '../model/territory_master_model.dart';

class TerritoryRepository {
  TerritoryRepository._();

  static final TerritoryRepository instance = TerritoryRepository._();

  Future<TerritoryMasterModel> loadTerritory() async {

    print("TerritoryRepository ===============================");
    print("TerritoryRepository Calling GET /territory/master");

    final response = await THttpHelper.authGet(
      "territory/master",
    );

    print("TerritoryRepository API Response:");
    print(const JsonEncoder.withIndent('  ').convert(response));

    final model = TerritoryMasterModel.fromJson(response);

    print("TerritoryRepository Parsed Model:");
    print("TerritoryRepository Areas      : ${model.areas.length}");
    print("TerritoryRepository Doctors    : ${model.doctors.length}");
    print("TerritoryRepository Beats      : ${model.beats.length}");
    print("TerritoryRepository Beat Areas : ${model.beatAreas.length}");

    if (model.areas.isNotEmpty) {
      print("TerritoryRepository First Area:");
      print(model.areas.first.toJson());
    }

    if (model.doctors.isNotEmpty) {
      print("TerritoryRepository First Doctor:");
      print(model.doctors.first.toJson());
    }

    if (model.beats.isNotEmpty) {
      print("TerritoryRepository First Beat:");
      print(model.beats.first.toJson());
    }

    if (model.beatAreas.isNotEmpty) {
      print("TerritoryRepository First BeatArea:");
      print(model.beatAreas.first.toJson());
    }

    print("TerritoryRepository ===============================");

    return model;
  }

  Future<void> createBeat({
    required String name,
    required List<String> areaIds,
    required String color,
  }) async {
    await THttpHelper.authPost(
      "beats",
      {
        "name": name,
        "areaIds": areaIds,
        "color": color,
      },
    );
  }

  Future<void> updateBeat({
    required String beatId,
    required String name,
    required List<String> areaIds,
    required String color,
  }) async {
    await THttpHelper.authPut(
      "beats/$beatId",
      {
        "name": name,
        "areaIds": areaIds,
        "color": color,
      },
    );
  }

  Future<void> deleteBeat(String beatId) async {
    await THttpHelper.authDelete(
      "beats/$beatId",
    );
  }
}