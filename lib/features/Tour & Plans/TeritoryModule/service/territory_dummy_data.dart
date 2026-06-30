import 'dart:math';

import 'package:latlong2/latlong.dart';
import 'package:uuid/uuid.dart';


import '../model/area_model.dart';
import '../model/beat_area_model.dart';
import '../model/beat_model.dart';
import '../model/doctor_location_model.dart';
import '../model/headquarter_model.dart';
import '../utils/enumsclass.dart';

class TerritoryDummyData {
  TerritoryDummyData._();

  static const _uuid = Uuid();

  static final Random _random = Random();

  //////////////////////////////////////////////////////////////////////////////
  /// HEADQUARTERS
  //////////////////////////////////////////////////////////////////////////////

  static final List<HeadquarterModel> headquarters = [

    const HeadquarterModel(
      id: "HQ001",
      code: "NOIDA",
      name: "Noida Headquarter",
      state: "Uttar Pradesh",
      latitude: 28.5706,
      longitude: 77.3272,
      zoom: 12.8,
    ),

    const HeadquarterModel(
      id: "HQ002",
      code: "DELHI",
      name: "Delhi Headquarter",
      state: "Delhi",
      latitude: 28.6139,
      longitude: 77.2090,
      zoom: 11.8,
    ),

  ];

  //////////////////////////////////////////////////////////////////////////////
  /// AREAS
  //////////////////////////////////////////////////////////////////////////////

  static final List<AreaModel> areas = [

    ///===========================
    /// NOIDA
    ///===========================

    AreaModel(
      id: "AREA001",
      headquarterId: "HQ001",
      postOffice: "Sector 18",
      pincode: "201301",
      latitude: 28.570784,
      longitude: 77.324662,
      doctorCount: 15,
    ),

    AreaModel(
      id: "AREA002",
      headquarterId: "HQ001",
      postOffice: "Sector 62",
      pincode: "201309",
      latitude: 28.628280,
      longitude: 77.364848,
      doctorCount: 18,
    ),

    AreaModel(
      id: "AREA003",
      headquarterId: "HQ001",
      postOffice: "Sector 37",
      pincode: "201303",
      latitude: 28.566518,
      longitude: 77.344135,
      doctorCount: 12,
    ),

    AreaModel(
      id: "AREA004",
      headquarterId: "HQ001",
      postOffice: "Sector 50",
      pincode: "201307",
      latitude: 28.573867,
      longitude: 77.361386,
      doctorCount: 14,
    ),

    AreaModel(
      id: "AREA005",
      headquarterId: "HQ001",
      postOffice: "Sector 27",
      pincode: "201301",
      latitude: 28.579846,
      longitude: 77.334588,
      doctorCount: 11,
    ),

    AreaModel(
      id: "AREA006",
      headquarterId: "HQ001",
      postOffice: "Sector 12",
      pincode: "201301",
      latitude: 28.593113,
      longitude: 77.326744,
      doctorCount: 16,
    ),

    ///////////////////////////////////////////////////////////
    /// DELHI
    ///////////////////////////////////////////////////////////

    AreaModel(
      id: "AREA007",
      headquarterId: "HQ002",
      postOffice: "Karol Bagh",
      pincode: "110005",
      latitude: 28.651952,
      longitude: 77.190918,
      doctorCount: 15,
    ),

    AreaModel(
      id: "AREA008",
      headquarterId: "HQ002",
      postOffice: "Laxmi Nagar",
      pincode: "110092",
      latitude: 28.631543,
      longitude: 77.277313,
      doctorCount: 13,
    ),

    AreaModel(
      id: "AREA009",
      headquarterId: "HQ002",
      postOffice: "Janakpuri",
      pincode: "110058",
      latitude: 28.621900,
      longitude: 77.087100,
      doctorCount: 18,
    ),

    AreaModel(
      id: "AREA010",
      headquarterId: "HQ002",
      postOffice: "Dwarka",
      pincode: "110075",
      latitude: 28.592100,
      longitude: 77.046000,
      doctorCount: 16,
    ),

    AreaModel(
      id: "AREA011",
      headquarterId: "HQ002",
      postOffice: "Rohini",
      pincode: "110085",
      latitude: 28.742000,
      longitude: 77.102500,
      doctorCount: 14,
    ),

  ];

  //////////////////////////////////////////////////////////////////////////////
  /// DOCTORS
  //////////////////////////////////////////////////////////////////////////////

  static final List<DoctorLocationModel> doctors =
  _generateDoctors();

  //////////////////////////////////////////////////////////////////////////////
  /// BEATS
  //////////////////////////////////////////////////////////////////////////////

  static final List<BeatModel> beats = [];

  //////////////////////////////////////////////////////////////////////////////
  /// BEAT AREA
  //////////////////////////////////////////////////////////////////////////////

  static final List<BeatAreaModel> beatAreas = [];

  //////////////////////////////////////////////////////////////////////////////
  /// HELPER
  //////////////////////////////////////////////////////////////////////////////

  static LatLng randomLocation(
      double latitude,
      double longitude,
      ) {

    const radius = 0.0022;

    final lat =
        latitude + (_random.nextDouble() - .5) * radius;

    final lng =
        longitude + (_random.nextDouble() - .5) * radius;

    return LatLng(
      lat,
      lng,
    );
  }

  //////////////////////////////////////////////////////////////////////////////
  /// DOCTOR GENERATOR
//////////////////////////////////////////////////////////////////////////////

  static List<DoctorLocationModel> _generateDoctors() {

    final List<DoctorLocationModel> list = [];

    final doctorNames = [

      "Dr. Amit Sharma",
      "Dr. Rajesh Kumar",
      "Dr. Priya Singh",
      "Dr. Neha Gupta",
      "Dr. Vivek Verma",
      "Dr. Mohit Bansal",
      "Dr. Rohit Jain",
      "Dr. Deepak Tyagi",
      "Dr. Ashish Goel",
      "Dr. Sandeep Yadav",
      "Dr. Ankit Gupta",
      "Dr. Nitin Saxena",
      "Dr. Pooja Sharma",
      "Dr. Swati Arora",
      "Dr. Ravi Mehta",
      "Dr. Manoj Gupta",
      "Dr. Rajiv Agarwal",
      "Dr. Alok Mishra",
      "Dr. Sunil Gupta",
      "Dr. Mukesh Jain",

    ];

    final specialities = [

      "Physician",
      "Cardiologist",
      "Dermatologist",
      "Orthopedic",
      "Gynecologist",
      "ENT",
      "Pediatrician",
      "Neurologist",

    ];

    final clinics = [

      "Life Care Clinic",
      "City Hospital",
      "Health Plus",
      "Apollo Clinic",
      "Shanti Clinic",
      "Metro Care",
      "Wellness Centre",
      "Family Care Clinic",

    ];

    int counter = 1;

    for (final area in areas) {

      for (int i = 0; i < area.doctorCount; i++) {

        final location = randomLocation(
          area.latitude,
          area.longitude,
        );

        list.add(

          DoctorLocationModel(

            id: _uuid.v4(),

            doctorCode:
            "DOC${counter.toString().padLeft(4, '0')}",

            doctorName:
            doctorNames[counter % doctorNames.length],

            areaId: area.id,

            headquarterId: area.headquarterId,

            clinicName:
            clinics[counter % clinics.length],

            speciality:
            specialities[counter % specialities.length],

            category:
            DoctorCategory.values[
            counter %
                DoctorCategory.values.length],

            latitude: location.latitude,

            longitude: location.longitude,

            visitStatus: VisitStatus.pending,

          ),

        );

        counter++;

      }

    }

    return list;

  }


//////////////////////////////////////////////////////////////////////////////
  /// BEATS
//////////////////////////////////////////////////////////////////////////////

  static List<BeatModel> _generateBeats() {
    return [

      BeatModel(
        id: "BEAT001",
        headquarterId: "HQ001",
        beatName: "Morning Beat",
        color: BeatColor.blue,
        doctorCount: 33,
        areaCount: 2,
        createdAt: DateTime.now(),
        createdBy: "Admin",
      ),

      BeatModel(
        id: "BEAT002",
        headquarterId: "HQ001",
        beatName: "Evening Beat",
        color: BeatColor.green,
        doctorCount: 25,
        areaCount: 2,
        createdAt: DateTime.now(),
        createdBy: "Admin",
      ),

      BeatModel(
        id: "BEAT003",
        headquarterId: "HQ001",
        beatName: "RM Special",
        color: BeatColor.orange,
        doctorCount: 42,
        areaCount: 3,
        createdAt: DateTime.now(),
        createdBy: "Admin",
      ),

      BeatModel(
        id: "BEAT004",
        headquarterId: "HQ002",
        beatName: "Delhi North",
        color: BeatColor.purple,
        doctorCount: 31,
        areaCount: 2,
        createdAt: DateTime.now(),
        createdBy: "Admin",
      ),

      BeatModel(
        id: "BEAT005",
        headquarterId: "HQ002",
        beatName: "Delhi South",
        color: BeatColor.red,
        doctorCount: 29,
        areaCount: 2,
        createdAt: DateTime.now(),
        createdBy: "Admin",
      ),

    ];
  }

  //////////////////////////////////////////////////////////////////////////////
  /// BEAT AREA MAPPING
//////////////////////////////////////////////////////////////////////////////

  static List<BeatAreaModel> _generateBeatAreas() {
    return [

      //--------------------------------
      // Morning Beat
      //--------------------------------

      const BeatAreaModel(
        beatId: "BEAT001",
        areaId: "AREA001",
      ),

      const BeatAreaModel(
        beatId: "BEAT001",
        areaId: "AREA002",
      ),

      //--------------------------------
      // Evening Beat
      //--------------------------------

      const BeatAreaModel(
        beatId: "BEAT002",
        areaId: "AREA004",
      ),

      const BeatAreaModel(
        beatId: "BEAT002",
        areaId: "AREA005",
      ),

      //--------------------------------
      // RM Beat
      //--------------------------------

      const BeatAreaModel(
        beatId: "BEAT003",
        areaId: "AREA001",
      ),

      const BeatAreaModel(
        beatId: "BEAT003",
        areaId: "AREA003",
      ),

      const BeatAreaModel(
        beatId: "BEAT003",
        areaId: "AREA006",
      ),

      //--------------------------------
      // Delhi North
      //--------------------------------

      const BeatAreaModel(
        beatId: "BEAT004",
        areaId: "AREA007",
      ),

      const BeatAreaModel(
        beatId: "BEAT004",
        areaId: "AREA011",
      ),

      //--------------------------------
      // Delhi South
      //--------------------------------

      const BeatAreaModel(
        beatId: "BEAT005",
        areaId: "AREA009",
      ),

      const BeatAreaModel(
        beatId: "BEAT005",
        areaId: "AREA010",
      ),

    ];
  }


}