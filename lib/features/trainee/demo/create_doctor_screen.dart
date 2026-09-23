import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:medicle_sales_rbsh/utils/constants/colors.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';
import 'package:medicle_sales_rbsh/utils/constants/text_strings.dart';
import 'package:medicle_sales_rbsh/utils/constants/sizes.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: TTexts.uiTextDoctorTutorialDemo,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: TColors.materialBlue,
      ),
      home: const CreateDoctorScreen(),
    );
  }
}

class CreateDoctorScreen extends StatefulWidget {
  const CreateDoctorScreen({super.key});

  @override
  State<CreateDoctorScreen> createState() => _CreateDoctorScreenState();
}

class _CreateDoctorScreenState extends State<CreateDoctorScreen> {
  final _formKey = GlobalKey<FormState>();

  late FlutterTts flutterTts;

  //------------------------------------------
  // Tutorial
  //------------------------------------------

  late TutorialCoachMark tutorialCoachMark;

  final List<TargetFocus> targets = [];

  //------------------------------------------
  // Global Keys
  //------------------------------------------

  final headerKey = GlobalKey();

  final doctorNameKey = GlobalKey();
  final mobileKey = GlobalKey();
  final emailKey = GlobalKey();

  final specializationKey = GlobalKey();
  final qualificationKey = GlobalKey();
  final registrationKey = GlobalKey();

  final genderKey = GlobalKey();
  final priorityKey = GlobalKey();

  final headOfficeKey = GlobalKey();
  final territoryKey = GlobalKey();
  final doctorClassKey = GlobalKey();

  final clinicKey = GlobalKey();
  final addressKey = GlobalKey();
  final cityKey = GlobalKey();
  final stateKey = GlobalKey();
  final pincodeKey = GlobalKey();

  final visitFrequencyKey = GlobalKey();
  final visitDayKey = GlobalKey();
  final visitTimeKey = GlobalKey();

  final geoKey = GlobalKey();

  final imageKey = GlobalKey();

  final submitKey = GlobalKey();

  //------------------------------------------
  // Controllers
  //------------------------------------------

  final doctorName = TextEditingController();
  final mobile = TextEditingController();
  final email = TextEditingController();
  final qualification = TextEditingController();
  final registrationNo = TextEditingController();

  //------------------------------------------
  // Dropdowns
  //------------------------------------------

  String? gender;
  String? specialization;
  String? priority;

  final genders = [
    "Male",
    "Female",
    "Other",
  ];

  final priorities = [
    "A",
    "B",
    "C",
  ];

  final specializations = [
    "Cardiologist",
    "Physician",
    "Neurologist",
    "Orthopedic",
    "ENT",
    "Pediatrician",
    "Gynecologist",
    "Dermatologist",
  ];

  @override
  void initState() {
    super.initState();

    initTts();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initTargets();
      _showTutorial();
    });
  }

  @override
  void dispose() {
    flutterTts.stop();

    doctorName.dispose();
    mobile.dispose();
    email.dispose();
    qualification.dispose();
    registrationNo.dispose();

    super.dispose();
  }

  Future<void> initTts() async {
    flutterTts = FlutterTts();

    await flutterTts.setLanguage("en-IN");

    await flutterTts.setSpeechRate(0.45);

    await flutterTts.setPitch(1.0);

    await flutterTts.setVolume(1.0);

    await flutterTts.awaitSpeakCompletion(true);
  }

  Future speak(String text) async {
    await flutterTts.stop();

    await flutterTts.speak(text);
  }

  String? validator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "Required";
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(TTexts.uiTextCreateDoctor),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            //--------------------------------------------------
            // Header
            //--------------------------------------------------

            Card(
              key: headerKey,
              elevation: TSizes.v2,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: const [
                    Icon(
                      Icons.medical_services,
                      size: TSizes.v60,
                    ),
                    SizedBox(height: TSizes.v10),
                    Text(
                      TTexts.uiTextDoctorRegistration,
                      style: TextStyle(
                        fontSize: TSizes.v22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: TSizes.v8),
                    Text(
                      TTexts.uiTextPleaseFillAllMandatoryDetails,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: TSizes.v25),

            //--------------------------------------------------
            // Basic Information
            //--------------------------------------------------

            const Text(
              TTexts.uiTextBasicInformation,
              style: TextStyle(
                fontSize: TSizes.v20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: TSizes.v20),

            TextFormField(
              key: doctorNameKey,
              controller: doctorName,
              validator: validator,
              decoration: const InputDecoration(
                labelText: TTexts.uiTextDoctorName_dd38da5f,
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
            ),

            const SizedBox(height: TSizes.v18),

            TextFormField(
              key: mobileKey,
              controller: mobile,
              keyboardType: TextInputType.phone,
              validator: validator,
              decoration: const InputDecoration(
                labelText: TTexts.uiTextMobileNumber_5c5448f1,
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.phone),
              ),
            ),

            const SizedBox(height: TSizes.v18),

            TextFormField(
              key: emailKey,
              controller: email,
              keyboardType: TextInputType.emailAddress,
              validator: validator,
              decoration: const InputDecoration(
                labelText: TTexts.uiTextEmail,
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.email),
              ),
            ),
            const SizedBox(height: TSizes.v18),

            DropdownButtonFormField<String>(
              key: specializationKey,
              value: specialization,
              validator: (v) => v == null ? "Select Specialization" : null,
              decoration: const InputDecoration(
                labelText: TTexts.uiTextSpecialization,
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.local_hospital),
              ),
              items: specializations
                  .map(
                    (e) => DropdownMenuItem(
                      value: e,
                      child: Text(e),
                    ),
                  )
                  .toList(),
              onChanged: (v) {
                setState(() {
                  specialization = v;
                });
              },
            ),

            const SizedBox(height: TSizes.v18),

            TextFormField(
              key: qualificationKey,
              controller: qualification,
              validator: validator,
              decoration: const InputDecoration(
                labelText: TTexts.uiTextQualification_16abd5ca,
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.school),
              ),
            ),

            const SizedBox(height: TSizes.v18),

            TextFormField(
              key: registrationKey,
              controller: registrationNo,
              validator: validator,
              decoration: const InputDecoration(
                labelText: TTexts.uiTextMedicalRegistrationNo,
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.badge),
              ),
            ),

            const SizedBox(height: TSizes.v18),

            DropdownButtonFormField<String>(
              key: genderKey,
              value: gender,
              validator: (v) => v == null ? "Select Gender" : null,
              decoration: const InputDecoration(
                labelText: TTexts.uiTextGender,
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.people),
              ),
              items: genders
                  .map(
                    (e) => DropdownMenuItem(
                      value: e,
                      child: Text(e),
                    ),
                  )
                  .toList(),
              onChanged: (v) {
                setState(() {
                  gender = v;
                });
              },
            ),

            const SizedBox(height: TSizes.v18),

            DropdownButtonFormField<String>(
              key: priorityKey,
              value: priority,
              validator: (v) => v == null ? "Select Priority" : null,
              decoration: const InputDecoration(
                labelText: TTexts.uiTextPriority_7568d321,
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.star),
              ),
              items: priorities
                  .map(
                    (e) => DropdownMenuItem(
                      value: e,
                      child: Text(e),
                    ),
                  )
                  .toList(),
              onChanged: (v) {
                setState(() {
                  priority = v;
                });
              },
            ),

            const SizedBox(height: TSizes.v25),

            //----------------------------------------
            // Organization Details
            //----------------------------------------

            const Text(
              TTexts.uiTextOrganizationDetails,
              style: TextStyle(
                fontSize: TSizes.v20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: TSizes.v20),

            DropdownButtonFormField<String>(
              key: headOfficeKey,
              decoration: const InputDecoration(
                labelText: TTexts.uiTextHeadOffice_523ae239,
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.apartment),
              ),
              items: const [
                DropdownMenuItem(
                  value: "Delhi",
                  child: Text(TTexts.uiTextDelhi),
                ),
                DropdownMenuItem(
                  value: "Noida",
                  child: Text(TTexts.uiTextNoida),
                ),
                DropdownMenuItem(
                  value: "Lucknow",
                  child: Text(TTexts.uiTextLucknow),
                ),
              ],
              validator: (v) => v == null ? "Required" : null,
              onChanged: (v) {},
            ),

            const SizedBox(height: TSizes.v18),

            DropdownButtonFormField<String>(
              key: territoryKey,
              decoration: const InputDecoration(
                labelText: TTexts.uiTextTerritory_e403f98a,
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.location_city),
              ),
              items: const [
                DropdownMenuItem(
                  value: "Sector 18",
                  child: Text(TTexts.uiTextSector18),
                ),
                DropdownMenuItem(
                  value: "Sector 62",
                  child: Text(TTexts.uiTextSector62),
                ),
                DropdownMenuItem(
                  value: "Greater Noida",
                  child: Text(TTexts.uiTextGreaterNoida),
                ),
              ],
              validator: (v) => v == null ? "Required" : null,
              onChanged: (v) {},
            ),

            const SizedBox(height: TSizes.v18),

            DropdownButtonFormField<String>(
              key: doctorClassKey,
              decoration: const InputDecoration(
                labelText: TTexts.uiTextDoctorClass_53b18a3a,
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.category),
              ),
              items: const [
                DropdownMenuItem(
                  value: "A",
                  child: Text(TTexts.uiTextA),
                ),
                DropdownMenuItem(
                  value: "B",
                  child: Text(TTexts.uiTextB),
                ),
                DropdownMenuItem(
                  value: "C",
                  child: Text(TTexts.uiTextC),
                ),
              ],
              validator: (v) => v == null ? "Required" : null,
              onChanged: (v) {},
            ),

            const SizedBox(height: TSizes.v25),

            //----------------------------------------
            // Clinic Information
            //----------------------------------------

            const Text(
              TTexts.uiTextClinicInformation,
              style: TextStyle(
                fontSize: TSizes.v20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: TSizes.v20),
            TextFormField(
              key: clinicKey,
              validator: validator,
              decoration: const InputDecoration(
                labelText: TTexts.uiTextClinicHospitalName,
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.local_hospital),
              ),
            ),

            const SizedBox(height: TSizes.v18),

            TextFormField(
              key: addressKey,
              validator: validator,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: TTexts.uiTextAddress_d89c9350,
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.home),
              ),
            ),

            const SizedBox(height: TSizes.v18),

            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    key: cityKey,
                    validator: validator,
                    decoration: const InputDecoration(
                      labelText: TTexts.uiTextCity_4ced02cb,
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: TSizes.v15),
                Expanded(
                  child: TextFormField(
                    key: stateKey,
                    validator: validator,
                    decoration: const InputDecoration(
                      labelText: TTexts.uiTextState_21bd05b0,
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: TSizes.v18),

            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    key: pincodeKey,
                    validator: validator,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: TTexts.uiTextPincode_5e13f180,
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: TSizes.v15),
                Expanded(
                  child: TextFormField(
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      labelText: TTexts.uiTextLandline,
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: TSizes.v18),

            TextFormField(
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: TTexts.uiTextRemarks,
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.note_alt_outlined),
              ),
            ),

            const SizedBox(height: TSizes.v25),

            //--------------------------------
            // Visit Information
            //--------------------------------

            const Text(
              TTexts.uiTextVisitInformation,
              style: TextStyle(
                fontSize: TSizes.v20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: TSizes.v20),

            DropdownButtonFormField<String>(
              key: visitFrequencyKey,
              validator: (v) => v == null ? "Required" : null,
              decoration: const InputDecoration(
                labelText: TTexts.uiTextVisitFrequency,
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.repeat),
              ),
              items: const [
                DropdownMenuItem(
                  value: "Weekly",
                  child: Text(TTexts.uiTextWeekly),
                ),
                DropdownMenuItem(
                  value: "Fortnightly",
                  child: Text(TTexts.uiTextFortnightly),
                ),
                DropdownMenuItem(
                  value: "Monthly",
                  child: Text(TTexts.uiTextMonthly),
                ),
              ],
              onChanged: (v) {},
            ),

            const SizedBox(height: TSizes.v18),

            DropdownButtonFormField<String>(
              key: visitDayKey,
              validator: (v) => v == null ? "Required" : null,
              decoration: const InputDecoration(
                labelText: TTexts.uiTextPreferredVisitDay_c6d40b43,
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.calendar_today),
              ),
              items: const [
                DropdownMenuItem(
                  value: "Monday",
                  child: Text(TTexts.uiTextMonday),
                ),
                DropdownMenuItem(
                  value: "Tuesday",
                  child: Text(TTexts.uiTextTuesday),
                ),
                DropdownMenuItem(
                  value: "Wednesday",
                  child: Text(TTexts.uiTextWednesday),
                ),
                DropdownMenuItem(
                  value: "Thursday",
                  child: Text(TTexts.uiTextThursday),
                ),
                DropdownMenuItem(
                  value: "Friday",
                  child: Text(TTexts.uiTextFriday),
                ),
                DropdownMenuItem(
                  value: "Saturday",
                  child: Text(TTexts.uiTextSaturday),
                ),
              ],
              onChanged: (v) {},
            ),

            const SizedBox(height: TSizes.v18),

            TextFormField(
              key: visitTimeKey,
              validator: validator,
              readOnly: true,
              decoration: const InputDecoration(
                labelText: TTexts.uiTextPreferredTime,
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.access_time),
                suffixIcon: Icon(Icons.arrow_drop_down),
              ),
              onTap: () {
                // showTimePicker(...)
              },
            ),

            const SizedBox(height: TSizes.v30),

            //--------------------------------
            // Geo Location
            //--------------------------------

            const Text(
              TTexts.uiTextGeoLocation,
              style: TextStyle(
                fontSize: TSizes.v20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: TSizes.v20),
            Container(
              key: geoKey,
              height: TSizes.v180,
              decoration: BoxDecoration(
                color: TColors.materialGrey200,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: TColors.materialGrey),
              ),
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.map,
                      size: TSizes.v60,
                      color: TColors.materialGrey,
                    ),
                    SizedBox(height: TSizes.v10),
                    Text(
                      TTexts.uiTextMapPreview,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: TSizes.v5),
                    Text(
                      TTexts.uiTextLatitudeLongitudeWillAppearHere,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: TSizes.v15),

            SizedBox(
              width: double.infinity,
              height: TSizes.v50,
              child: OutlinedButton.icon(
                onPressed: () {
                  // TODO:
                  // Capture Current Location
                },
                icon: const Icon(Icons.my_location),
                label: const Text(TTexts.uiTextCaptureCurrentLocation),
              ),
            ),

            const SizedBox(height: TSizes.v30),

            //-----------------------------------------
            // Doctor Photograph
            //-----------------------------------------

            const Text(
              TTexts.uiTextDoctorPhotograph,
              style: TextStyle(
                fontSize: TSizes.v20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: TSizes.v20),

            GestureDetector(
              key: imageKey,
              onTap: () {
                // TODO:
                // Pick Image
              },
              child: Container(
                height: TSizes.v180,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: TColors.materialBlue,
                    width: TSizes.v2,
                  ),
                ),
                child: const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.add_a_photo,
                        size: TSizes.v60,
                        color: TColors.materialBlue,
                      ),
                      SizedBox(height: TSizes.v12),
                      Text(
                        TTexts.uiTextUploadDoctorPhotograph,
                        style: TextStyle(
                          color: TColors.materialBlue,
                          fontSize: TSizes.v16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: TSizes.v35),

            //-----------------------------------------
            // Buttons
            //-----------------------------------------

            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(
                        double.infinity,
                        55,
                      ),
                    ),
                    onPressed: () {
                      _formKey.currentState?.reset();
                    },
                    child: const Text(
                      TTexts.uiTextReset,
                    ),
                  ),
                ),
                const SizedBox(width: TSizes.v15),
                Expanded(
                  flex: 2,
                  child: ElevatedButton.icon(
                    key: submitKey,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(
                        double.infinity,
                        55,
                      ),
                    ),
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              TTexts.uiTextDoctorCreatedSuccessfully,
                            ),
                          ),
                        );
                      }
                    },
                    icon: const Icon(Icons.save),
                    label: const Text(
                      TTexts.uiTextCreateDoctor,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: TSizes.v40),
          ],
        ),
      ),
    );
  }

  //---------------------------------------------------------
  // Tutorial Methods
  //---------------------------------------------------------

  void _showTutorial() {
    tutorialCoachMark = TutorialCoachMark(
      targets: targets,
      colorShadow: TColors.primary,
      opacityShadow: 0.85,
      paddingFocus: 10,
      hideSkip: false,
      textSkip: "SKIP",
      onFinish: () {
        debugPrint("Tutorial Finished");
      },
      onSkip: () {
        return true;
      },
    );

    tutorialCoachMark.show(context: context);
  }

  void _initTargets() {
    targets.clear();

    //------------------------------------------------
    // Welcome
    //------------------------------------------------

    targets.add(
      TargetFocus(
        identify: "header",
        keyTarget: headerKey,
        enableOverlayTab: true,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            builder: (context, controller) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                speak("Enter the doctor's full registered name.");
              });
              return _tutorialCard(
                title: TTexts.uiTextWelcome,
                description: "This screen helps you register a doctor. "
                    "Let's go through every field.",
                controller: controller,
              );
            },
          ),
        ],
      ),
    );

    //------------------------------------------------
    // Doctor Name
    //------------------------------------------------

    targets.add(
      TargetFocus(
        identify: "doctor_name",
        keyTarget: doctorNameKey,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            builder: (context, controller) {
              return _tutorialCard(
                title: TTexts.uiTextDoctorName,
                description: "Enter the doctor's full registered name.",
                controller: controller,
              );
            },
          ),
        ],
      ),
    );

    //------------------------------------------------
    // Mobile
    //------------------------------------------------

    targets.add(
      TargetFocus(
        identify: "mobile",
        keyTarget: mobileKey,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            builder: (context, controller) {
              return _tutorialCard(
                title: TTexts.uiTextMobileNumber,
                description: "Enter doctor's mobile number.",
                controller: controller,
              );
            },
          ),
        ],
      ),
    );

    //------------------------------------------------
    // Email
    //------------------------------------------------

    targets.add(
      TargetFocus(
        identify: "email",
        keyTarget: emailKey,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            builder: (context, controller) {
              return _tutorialCard(
                title: TTexts.email,
                description: "Doctor's email address.",
                controller: controller,
              );
            },
          ),
        ],
      ),
    );

    //------------------------------------------------
    // Specialization
    //------------------------------------------------

    targets.add(
      TargetFocus(
        identify: "specialization",
        keyTarget: specializationKey,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            builder: (context, controller) {
              return _tutorialCard(
                title: TTexts.specialization,
                description: "Choose doctor's specialization.",
                controller: controller,
              );
            },
          ),
        ],
      ),
    );

    //------------------------------------------------
    // Qualification
    //------------------------------------------------

    targets.add(
      TargetFocus(
        identify: "qualification",
        keyTarget: qualificationKey,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            builder: (context, controller) {
              return _tutorialCard(
                title: TTexts.uiTextQualification,
                description: "Example: MBBS, MD, DM.",
                controller: controller,
              );
            },
          ),
        ],
      ),
    );

    //------------------------------------------------
    // Registration
    //------------------------------------------------

    targets.add(
      TargetFocus(
        identify: "registration",
        keyTarget: registrationKey,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            builder: (context, controller) {
              return _tutorialCard(
                title: TTexts.uiTextMedicalRegistration,
                description: "Enter valid medical council registration number.",
                controller: controller,
              );
            },
          ),
        ],
      ),
    );

    //------------------------------------------------
    // Gender
    //------------------------------------------------

    targets.add(
      TargetFocus(
        identify: "gender",
        keyTarget: genderKey,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            builder: (context, controller) {
              return _tutorialCard(
                title: TTexts.gender,
                description: "Select doctor's gender.",
                controller: controller,
              );
            },
          ),
        ],
      ),
    );

    //------------------------------------------------
    // Priority
    //------------------------------------------------

    targets.add(
      TargetFocus(
        identify: "priority",
        keyTarget: priorityKey,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            builder: (context, controller) {
              return _tutorialCard(
                title: TTexts.uiTextPriority,
                description:
                    "Priority determines visit frequency.\n\nA → High\nB → Medium\nC → Low",
                controller: controller,
              );
            },
          ),
        ],
      ),
    );

    //------------------------------------------------
    // Head Office
    //------------------------------------------------

    targets.add(
      TargetFocus(
        identify: "headOffice",
        keyTarget: headOfficeKey,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            builder: (context, controller) {
              return _tutorialCard(
                title: TTexts.uiTextHeadOffice,
                description:
                    "Choose the Head Office to which this doctor belongs.",
                controller: controller,
              );
            },
          ),
        ],
      ),
    );

    //------------------------------------------------
    // Territory
    //------------------------------------------------

    targets.add(
      TargetFocus(
        identify: "territory",
        keyTarget: territoryKey,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            builder: (context, controller) {
              return _tutorialCard(
                title: TTexts.uiTextTerritory,
                description: "Select the territory assigned to this doctor.",
                controller: controller,
              );
            },
          ),
        ],
      ),
    );

    //------------------------------------------------
    // Doctor Class
    //------------------------------------------------

    targets.add(
      TargetFocus(
        identify: "doctorClass",
        keyTarget: doctorClassKey,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            builder: (context, controller) {
              return _tutorialCard(
                title: TTexts.uiTextDoctorClass,
                description: "Doctor Class is used for business segmentation.",
                controller: controller,
              );
            },
          ),
        ],
      ),
    );

    //------------------------------------------------
    // Clinic
    //------------------------------------------------

    targets.add(
      TargetFocus(
        identify: "clinic",
        keyTarget: clinicKey,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            builder: (context, controller) {
              return _tutorialCard(
                title: TTexts.uiTextClinicHospital,
                description: "Enter clinic or hospital name.",
                controller: controller,
              );
            },
          ),
        ],
      ),
    );

    //------------------------------------------------
    // Address
    //------------------------------------------------

    targets.add(
      TargetFocus(
        identify: "address",
        keyTarget: addressKey,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            builder: (context, controller) {
              return _tutorialCard(
                title: TTexts.uiTextAddress,
                description: "Enter complete clinic address.",
                controller: controller,
              );
            },
          ),
        ],
      ),
    );

    //------------------------------------------------
    // City
    //------------------------------------------------

    targets.add(
      TargetFocus(
        identify: "city",
        keyTarget: cityKey,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            builder: (context, controller) {
              return _tutorialCard(
                title: TTexts.uiTextCity,
                description: "Enter doctor's practicing city.",
                controller: controller,
              );
            },
          ),
        ],
      ),
    );

    //------------------------------------------------
    // State
    //------------------------------------------------

    targets.add(
      TargetFocus(
        identify: "state",
        keyTarget: stateKey,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            builder: (context, controller) {
              return _tutorialCard(
                title: TTexts.uiTextState,
                description: "Select the state.",
                controller: controller,
              );
            },
          ),
        ],
      ),
    );

    //------------------------------------------------
    // Pincode
    //------------------------------------------------

    targets.add(
      TargetFocus(
        identify: "pincode",
        keyTarget: pincodeKey,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            builder: (context, controller) {
              return _tutorialCard(
                title: TTexts.uiTextPincode,
                description: "Enter the clinic pincode.",
                controller: controller,
              );
            },
          ),
        ],
      ),
    );

    //------------------------------------------------
    // Visit Frequency
    //------------------------------------------------

    targets.add(
      TargetFocus(
        identify: "visitFrequency",
        keyTarget: visitFrequencyKey,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            builder: (context, controller) {
              return _tutorialCard(
                title: TTexts.visitFrequency,
                description:
                    "Choose how frequently this doctor should be visited.",
                controller: controller,
              );
            },
          ),
        ],
      ),
    );

    //------------------------------------------------
    // Visit Day
    //------------------------------------------------

    targets.add(
      TargetFocus(
        identify: "visitDay",
        keyTarget: visitDayKey,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            builder: (context, controller) {
              return _tutorialCard(
                title: TTexts.uiTextPreferredVisitDay,
                description: "Select the preferred day to visit this doctor.",
                controller: controller,
              );
            },
          ),
        ],
      ),
    );

    //------------------------------------------------
    // Visit Time
    //------------------------------------------------

    targets.add(
      TargetFocus(
        identify: "visitTime",
        keyTarget: visitTimeKey,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            builder: (context, controller) {
              return _tutorialCard(
                title: TTexts.uiTextPreferredVisitTime,
                description: "Select the preferred consultation time.",
                controller: controller,
              );
            },
          ),
        ],
      ),
    );

    //------------------------------------------------
    // Geo Location
    //------------------------------------------------

    targets.add(
      TargetFocus(
        identify: "geoLocation",
        keyTarget: geoKey,
        contents: [
          TargetContent(
            align: ContentAlign.top,
            builder: (context, controller) {
              return _tutorialCard(
                title: TTexts.uiTextGeoLocation,
                description:
                    "Capture the doctor's clinic GPS location. This helps during visit verification and navigation.",
                controller: controller,
              );
            },
          ),
        ],
      ),
    );

    //------------------------------------------------
    // Photo
    //------------------------------------------------

    targets.add(
      TargetFocus(
        identify: "doctorPhoto",
        keyTarget: imageKey,
        contents: [
          TargetContent(
            align: ContentAlign.top,
            builder: (context, controller) {
              return _tutorialCard(
                title: TTexts.uiTextDoctorPhotograph,
                description:
                    "Upload a clear clinic or doctor photograph for verification.",
                controller: controller,
              );
            },
          ),
        ],
      ),
    );

    //------------------------------------------------
    // Submit
    //------------------------------------------------

    targets.add(
      TargetFocus(
        identify: "submit",
        keyTarget: submitKey,
        contents: [
          TargetContent(
            align: ContentAlign.top,
            builder: (context, controller) {
              return Container(
                width: TSizes.v340,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: TColors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      TTexts.uiTextYouReReady,
                      style: TextStyle(
                        fontSize: TSizes.v22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: TSizes.v12),
                    const Text(
                      TTexts.uiTextAllMandatoryFieldsHaveBeenExplainedFillThe,
                      style: TextStyle(
                        fontSize: TSizes.v16,
                      ),
                    ),
                    const SizedBox(height: TSizes.v20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () {
                            controller.skip();
                          },
                          child: const Text(TTexts.skip),
                        ),
                        const SizedBox(width: TSizes.v10),
                        TextButton(
                          onPressed: () {
                            controller.skip();
                          },
                          child: const Text(TTexts.uiTextFinish),
                        )
                      ],
                    )
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _tutorialCard({
    required String title,
    required String description,
    required TutorialCoachMarkController controller,
  }) {
    return Container(
      width: TSizes.v360,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: TColors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: TColors.black26,
            blurRadius: TSizes.v12,
            offset: Offset(0, 4),
          )
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: TColors.materialBlue50,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.school,
                  color: TColors.materialBlue,
                ),
              ),
              const SizedBox(width: TSizes.v15),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: TSizes.v22,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: TSizes.v18),
          Text(
            description,
            style: TextStyle(
              fontSize: TSizes.v16,
              color: TColors.materialGrey700,
              height: TSizes.v1_5,
            ),
          ),
          const SizedBox(height: TSizes.v25),
          LinearProgressIndicator(
            value: 0.3,
            borderRadius: BorderRadius.circular(10),
          ),
          const SizedBox(height: TSizes.v10),
          const Align(
            alignment: Alignment.centerRight,
            child: Text(
              TTexts.uiTextTrainingGuide,
              style: TextStyle(
                color: TColors.materialGrey,
              ),
            ),
          ),
          const SizedBox(height: TSizes.v20),
          Row(
            children: [
              TextButton.icon(
                onPressed: () {
                  controller.skip();
                },
                icon: const Icon(Icons.close),
                label: const Text(TTexts.skip),
              ),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: () {
                  controller.previous();
                },
                icon: const Icon(Icons.arrow_back),
                label: const Text(TTexts.uiTextBack),
              ),
              const SizedBox(width: TSizes.v10),
              ElevatedButton.icon(
                onPressed: () {
                  controller.next();
                },
                icon: const Icon(Icons.arrow_forward),
                label: const Text(TTexts.uiTextNext),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
