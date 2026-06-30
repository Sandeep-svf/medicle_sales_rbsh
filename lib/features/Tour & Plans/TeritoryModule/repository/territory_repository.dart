import '../model/area_model.dart';
import '../model/beat_area_model.dart';
import '../model/beat_model.dart';
import '../model/doctor_location_model.dart';
import '../model/headquarter_model.dart';
import '../service/territory_dummy_data.dart';

class TerritoryRepository {
  TerritoryRepository._();

  static final TerritoryRepository instance = TerritoryRepository._();

  List<HeadquarterModel> getHeadquarters() {
    return TerritoryDummyData.headquarters;
  }

  List<AreaModel> getAreas() {
    return TerritoryDummyData.areas;
  }

  List<DoctorLocationModel> getDoctors() {
    return TerritoryDummyData.doctors;
  }

  List<BeatModel> getBeats() {
    return TerritoryDummyData.beats;
  }

  List<BeatAreaModel> getBeatAreas() {
    return TerritoryDummyData.beatAreas;
  }
}