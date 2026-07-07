import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:medicle_sales_rbsh/utils/constants/colors.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';



void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Doctor Tutorial Demo',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.blue,
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
    if (value == null || value
        .trim()
        .isEmpty) {
      return "Required";
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Create Doctor"),
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
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: const [

                    Icon(
                      Icons.medical_services,
                      size: 60,
                    ),

                    SizedBox(height: 10),

                    Text(
                      "Doctor Registration",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    SizedBox(height: 8),

                    Text(
                      "Please fill all mandatory details.",
                    ),

                  ],
                ),
              ),
            ),

            const SizedBox(height: 25),

            //--------------------------------------------------
            // Basic Information
            //--------------------------------------------------

            const Text(
              "Basic Information",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 20),

            TextFormField(
              key: doctorNameKey,
              controller: doctorName,
              validator: validator,
              decoration: const InputDecoration(
                labelText: "Doctor Name *",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
            ),

            const SizedBox(height: 18),

            TextFormField(
              key: mobileKey,
              controller: mobile,
              keyboardType: TextInputType.phone,
              validator: validator,
              decoration: const InputDecoration(
                labelText: "Mobile Number *",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.phone),
              ),
            ),

            const SizedBox(height: 18),

            TextFormField(
              key: emailKey,
              controller: email,
              keyboardType: TextInputType.emailAddress,
              validator: validator,
              decoration: const InputDecoration(
                labelText: "Email *",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.email),
              ),
            ),
            const SizedBox(height: 18),

            DropdownButtonFormField<String>(
              key: specializationKey,
              value: specialization,
              validator: (v) =>
              v == null ? "Select Specialization" : null,
              decoration: const InputDecoration(
                labelText: "Specialization *",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.local_hospital),
              ),
              items: specializations
                  .map(
                    (e) =>
                    DropdownMenuItem(
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

            const SizedBox(height: 18),

            TextFormField(
              key: qualificationKey,
              controller: qualification,
              validator: validator,
              decoration: const InputDecoration(
                labelText: "Qualification *",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.school),
              ),
            ),

            const SizedBox(height: 18),

            TextFormField(
              key: registrationKey,
              controller: registrationNo,
              validator: validator,
              decoration: const InputDecoration(
                labelText: "Medical Registration No *",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.badge),
              ),
            ),

            const SizedBox(height: 18),

            DropdownButtonFormField<String>(
              key: genderKey,
              value: gender,
              validator: (v) =>
              v == null ? "Select Gender" : null,
              decoration: const InputDecoration(
                labelText: "Gender *",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.people),
              ),
              items: genders
                  .map(
                    (e) =>
                    DropdownMenuItem(
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

            const SizedBox(height: 18),

            DropdownButtonFormField<String>(
              key: priorityKey,
              value: priority,
              validator: (v) =>
              v == null ? "Select Priority" : null,
              decoration: const InputDecoration(
                labelText: "Priority *",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.star),
              ),
              items: priorities
                  .map(
                    (e) =>
                    DropdownMenuItem(
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

            const SizedBox(height: 25),

            //----------------------------------------
            // Organization Details
            //----------------------------------------

            const Text(
              "Organization Details",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 20),

            DropdownButtonFormField<String>(
              key: headOfficeKey,
              decoration: const InputDecoration(
                labelText: "Head Office *",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.apartment),
              ),
              items: const [

                DropdownMenuItem(
                  value: "Delhi",
                  child: Text("Delhi"),
                ),

                DropdownMenuItem(
                  value: "Noida",
                  child: Text("Noida"),
                ),

                DropdownMenuItem(
                  value: "Lucknow",
                  child: Text("Lucknow"),
                ),

              ],
              validator: (v) => v == null ? "Required" : null,
              onChanged: (v) {},
            ),

            const SizedBox(height: 18),

            DropdownButtonFormField<String>(
              key: territoryKey,
              decoration: const InputDecoration(
                labelText: "Territory *",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.location_city),
              ),
              items: const [

                DropdownMenuItem(
                  value: "Sector 18",
                  child: Text("Sector 18"),
                ),

                DropdownMenuItem(
                  value: "Sector 62",
                  child: Text("Sector 62"),
                ),

                DropdownMenuItem(
                  value: "Greater Noida",
                  child: Text("Greater Noida"),
                ),

              ],
              validator: (v) => v == null ? "Required" : null,
              onChanged: (v) {},
            ),

            const SizedBox(height: 18),

            DropdownButtonFormField<String>(
              key: doctorClassKey,
              decoration: const InputDecoration(
                labelText: "Doctor Class *",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.category),
              ),
              items: const [

                DropdownMenuItem(
                  value: "A",
                  child: Text("A"),
                ),

                DropdownMenuItem(
                  value: "B",
                  child: Text("B"),
                ),

                DropdownMenuItem(
                  value: "C",
                  child: Text("C"),
                ),

              ],
              validator: (v) => v == null ? "Required" : null,
              onChanged: (v) {},
            ),

            const SizedBox(height: 25),

            //----------------------------------------
            // Clinic Information
            //----------------------------------------

            const Text(
              "Clinic Information",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 20),
            TextFormField(
              key: clinicKey,
              validator: validator,
              decoration: const InputDecoration(
                labelText: "Clinic / Hospital Name *",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.local_hospital),
              ),
            ),

            const SizedBox(height: 18),

            TextFormField(
              key: addressKey,
              validator: validator,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: "Address *",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.home),
              ),
            ),

            const SizedBox(height: 18),

            Row(
              children: [

                Expanded(
                  child: TextFormField(
                    key: cityKey,
                    validator: validator,
                    decoration: const InputDecoration(
                      labelText: "City *",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),

                const SizedBox(width: 15),

                Expanded(
                  child: TextFormField(
                    key: stateKey,
                    validator: validator,
                    decoration: const InputDecoration(
                      labelText: "State *",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),

              ],
            ),

            const SizedBox(height: 18),

            Row(
              children: [

                Expanded(
                  child: TextFormField(
                    key: pincodeKey,
                    validator: validator,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: "Pincode *",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),

                const SizedBox(width: 15),

                Expanded(
                  child: TextFormField(
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      labelText: "Landline",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),

              ],
            ),

            const SizedBox(height: 18),

            TextFormField(
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: "Remarks",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.note_alt_outlined),
              ),
            ),

            const SizedBox(height: 25),

            //--------------------------------
            // Visit Information
            //--------------------------------

            const Text(
              "Visit Information",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 20),

            DropdownButtonFormField<String>(
              key: visitFrequencyKey,
              validator: (v) => v == null ? "Required" : null,
              decoration: const InputDecoration(
                labelText: "Visit Frequency *",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.repeat),
              ),
              items: const [

                DropdownMenuItem(
                  value: "Weekly",
                  child: Text("Weekly"),
                ),

                DropdownMenuItem(
                  value: "Fortnightly",
                  child: Text("Fortnightly"),
                ),

                DropdownMenuItem(
                  value: "Monthly",
                  child: Text("Monthly"),
                ),

              ],
              onChanged: (v) {},
            ),

            const SizedBox(height: 18),

            DropdownButtonFormField<String>(
              key: visitDayKey,
              validator: (v) => v == null ? "Required" : null,
              decoration: const InputDecoration(
                labelText: "Preferred Visit Day *",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.calendar_today),
              ),
              items: const [

                DropdownMenuItem(
                  value: "Monday",
                  child: Text("Monday"),
                ),

                DropdownMenuItem(
                  value: "Tuesday",
                  child: Text("Tuesday"),
                ),

                DropdownMenuItem(
                  value: "Wednesday",
                  child: Text("Wednesday"),
                ),

                DropdownMenuItem(
                  value: "Thursday",
                  child: Text("Thursday"),
                ),

                DropdownMenuItem(
                  value: "Friday",
                  child: Text("Friday"),
                ),

                DropdownMenuItem(
                  value: "Saturday",
                  child: Text("Saturday"),
                ),

              ],
              onChanged: (v) {},
            ),

            const SizedBox(height: 18),

            TextFormField(
              key: visitTimeKey,
              validator: validator,
              readOnly: true,
              decoration: const InputDecoration(
                labelText: "Preferred Time *",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.access_time),
                suffixIcon: Icon(Icons.arrow_drop_down),
              ),
              onTap: () {
                // showTimePicker(...)
              },
            ),

            const SizedBox(height: 30),

            //--------------------------------
            // Geo Location
            //--------------------------------

            const Text(
              "Geo Location",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 20),
            Container(
              key: geoKey,
              height: 180,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey),
              ),
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [

                    Icon(
                      Icons.map,
                      size: 60,
                      color: Colors.grey,
                    ),

                    SizedBox(height: 10),

                    Text(
                      "Map Preview",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    SizedBox(height: 5),

                    Text(
                      "Latitude & Longitude will appear here",
                    ),

                  ],
                ),
              ),
            ),

            const SizedBox(height: 15),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton.icon(
                onPressed: () {
                  // TODO:
                  // Capture Current Location

                },
                icon: const Icon(Icons.my_location),
                label: const Text("Capture Current Location"),
              ),
            ),

            const SizedBox(height: 30),

            //-----------------------------------------
            // Doctor Photograph
            //-----------------------------------------

            const Text(
              "Doctor Photograph",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 20),

            GestureDetector(
              key: imageKey,
              onTap: () {
                // TODO:
                // Pick Image

              },
              child: Container(
                height: 180,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.blue,
                    width: 2,
                  ),
                ),
                child: const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [

                      Icon(
                        Icons.add_a_photo,
                        size: 60,
                        color: Colors.blue,
                      ),

                      SizedBox(height: 12),

                      Text(
                        "Upload Doctor Photograph",
                        style: TextStyle(
                          color: Colors.blue,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 35),

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
                      "Reset",
                    ),
                  ),
                ),

                const SizedBox(width: 15),

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
                              "Doctor Created Successfully",
                            ),
                          ),
                        );
                      }
                    },
                    icon: const Icon(Icons.save),
                    label: const Text(
                      "Create Doctor",
                    ),
                  ),
                ),

              ],
            ),

            const SizedBox(height: 40),

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

                speak(
                    "Enter the doctor's full registered name.");

              });
              return _tutorialCard(

                title: "👋 Welcome",

                description:
                "This screen helps you register a doctor. "
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

                title: "Doctor Name",

                description:
                "Enter the doctor's full registered name.",

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

                title: "Mobile Number",

                description:
                "Enter doctor's mobile number.",

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

                title: "Email",

                description:
                "Doctor's email address.",

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

                title: "Specialization",

                description:
                "Choose doctor's specialization.",

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

                title: "Qualification",

                description:
                "Example: MBBS, MD, DM.",

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

                title: "Medical Registration",

                description:
                "Enter valid medical council registration number.",

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
                title: "Gender",
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
                title: "Priority",
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
                title: "Head Office",
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
                title: "Territory",
                description:
                "Select the territory assigned to this doctor.",
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
                title: "Doctor Class",
                description:
                "Doctor Class is used for business segmentation.",
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
                title: "Clinic / Hospital",
                description:
                "Enter clinic or hospital name.",
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
                title: "Address",
                description:
                "Enter complete clinic address.",
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
                title: "City",
                description:
                "Enter doctor's practicing city.",
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
                title: "State",
                description:
                "Select the state.",
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
                title: "Pincode",
                description:
                "Enter the clinic pincode.",
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
                title: "Visit Frequency",
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
                title: "Preferred Visit Day",
                description:
                "Select the preferred day to visit this doctor.",
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
                title: "Preferred Visit Time",
                description:
                "Select the preferred consultation time.",
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
                title: "Geo Location",
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
                title: "Doctor Photograph",
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
                width: 340,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    const Text(
                      "🎉 You're Ready!",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 12),

                    const Text(
                      "All mandatory fields have been explained.\n\nFill the form and tap 'Create Doctor' to save the doctor.",
                      style: TextStyle(
                        fontSize: 16,
                      ),
                    ),

                    const SizedBox(height: 20),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [

                        TextButton(
                          onPressed: () {
                            controller.skip();
                          },
                          child: const Text("Skip"),
                        ),

                        const SizedBox(width: 10),

                        TextButton(
                          onPressed: () {
                            controller.skip();
                          },
                          child: const Text("Finish"),
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
      width: 360,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 12,
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
                  color: Colors.blue.shade50,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.school,
                  color: Colors.blue,
                ),
              ),

              const SizedBox(width: 15),

              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          Text(
            description,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade700,
              height: 1.5,
            ),
          ),

          const SizedBox(height: 25),

          LinearProgressIndicator(
            value: 0.3,
            borderRadius: BorderRadius.circular(10),
          ),

          const SizedBox(height: 10),

          const Align(
            alignment: Alignment.centerRight,
            child: Text(
              "Training Guide",
              style: TextStyle(
                color: Colors.grey,
              ),
            ),
          ),

          const SizedBox(height: 20),

          Row(
            children: [

              TextButton.icon(
                onPressed: () {
                  controller.skip();
                },
                icon: const Icon(Icons.close),
                label: const Text("Skip"),
              ),

              const Spacer(),

              ElevatedButton.icon(
                onPressed: () {
                  controller.previous();
                },
                icon: const Icon(Icons.arrow_back),
                label: const Text("Back"),
              ),

              const SizedBox(width: 10),

              ElevatedButton.icon(
                onPressed: () {
                  controller.next();
                },
                icon: const Icon(Icons.arrow_forward),
                label: const Text("Next"),
              ),

            ],
          ),

        ],
      ),
    );
  }
}