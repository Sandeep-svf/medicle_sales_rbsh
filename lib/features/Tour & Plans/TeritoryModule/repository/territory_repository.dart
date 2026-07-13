import '../../../../utils/http/http_client.dart';

class TerritoryRepository {
  TerritoryRepository._();

  static final TerritoryRepository instance =
  TerritoryRepository._();

  Future<Map<String, dynamic>> loadTerritory() async {
    return await THttpHelper.authGet(
      "territory/master",
    );
  }

  Future<Map<String, dynamic>> createBeat({
    required String name,
    required List<String> areaIds,
    required String color,
  }) async {
    return await THttpHelper.authPost(
      "beats",
      {
        "name": name,
        "areaIds": areaIds,
        "color": color,
      },
    );
  }

  Future<Map<String, dynamic>> updateBeat({
    required String beatId,
    required String name,
    required List<String> areaIds,
    required String color,
  }) async {
    return await THttpHelper.authPut(
      "beats/$beatId",
      {
        "name": name,
        "areaIds": areaIds,
        "color": color,
      },
    );
  }

  Future<void> deleteBeat(
      String beatId,
      ) async {
    await THttpHelper.authDelete(
      "beats/$beatId",
    );
  }
}