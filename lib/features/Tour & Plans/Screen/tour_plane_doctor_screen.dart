import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../widgets/section_card.dart';
import 'package:medicle_sales_rbsh/utils/constants/text_strings.dart';
import 'package:medicle_sales_rbsh/utils/constants/sizes.dart';
import 'package:medicle_sales_rbsh/utils/constants/colors.dart';

class TourPlan extends StatefulWidget {
  const TourPlan({super.key});

  @override
  State<TourPlan> createState() => _TourPlanState();
}

class _TourPlanState extends State<TourPlan> {
  DateTimeRange? selectedRange;
  final TextEditingController searchController = TextEditingController();

  /// Weekdays
  final List<String> weekDays = [
    'Mon',
    'Tue',
    'Wed',
    'Thu',
    'Fri',
    'Sat',
    'Sun'
  ];
  final Set<String> selectedDays = {};

  /// HQ & Area
  String? selectedHeadquarter;
  String? selectedArea;

  final Map<String, List<String>> headquarterAreas = {
    'Delhi HQ': ['North Delhi', 'South Delhi', 'Gurgaon'],
    'Mumbai HQ': ['Andheri', 'Borivali', 'Navi Mumbai'],
    'Bangalore HQ': ['Whitefield', 'Electronic City'],
  };

  /// Doctors
  final List<String> doctors = [
    'Dr. Sandeep Sharma',
    'Dr. Neha Verma',
    'Dr. Amit Patel',
    'Dr. Rakesh Singh',
    'Dr. Priya Mehta',
    'Dr. Kunal Jain',
  ];

  final Set<String> selectedDoctors = {};
  List<String> filteredDoctors = [];

  @override
  void initState() {
    super.initState();
    filteredDoctors = doctors;
    searchController.addListener(_onSearch);
  }

  void _onSearch() {
    final query = searchController.text.toLowerCase();
    setState(() {
      filteredDoctors =
          doctors.where((d) => d.toLowerCase().contains(query)).toList();
    });
  }

  Future<void> _pickDateRange() async {
    final range = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
      initialDateRange: selectedRange,
    );

    if (range != null) {
      setState(() => selectedRange = range);
    }
  }

  bool get isValid =>
      selectedRange != null &&
      selectedDays.isNotEmpty &&
      selectedHeadquarter != null &&
      selectedArea != null &&
      selectedDoctors.isNotEmpty;

  void _scheduleTour() {
    final payload = {
      "startDate": selectedRange!.start.toIso8601String(),
      "endDate": selectedRange!.end.toIso8601String(),
      "days": selectedDays.toList(),
      "headquarter": selectedHeadquarter,
      "area": selectedArea,
      "doctors": selectedDoctors.toList(),
    };

    debugPrint("Tour Plan Payload → $payload");

    // TODO: API call
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      ///  Sticky CTA
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: ElevatedButton(
          onPressed: isValid ? _scheduleTour : null,
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
          child: const Text(
            TTexts.uiTextSchedulePlans,
            style: TextStyle(fontSize: TSizes.v16, fontWeight: FontWeight.bold),
          ),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ///  DATE RANGE
            SectionCard(
              title: TTexts.dateRange,
              subtitle: selectedRange == null
                  ? 'Choose your plan duration'
                  : '${DateFormat('dd MMM').format(selectedRange!.start)}'
                      ' → ${DateFormat('dd MMM yyyy').format(selectedRange!.end)}',
              icon: Icons.date_range,
              onTap: _pickDateRange,
            ),

            const SizedBox(height: TSizes.v16),

            ///  WEEK DAYS
            CardContainer(
              title: TTexts.uiTextWorkingDays,
              trailing: Text('${selectedDays.length} selected',
                  style: const TextStyle(fontSize: TSizes.v12)),
              child: Wrap(
                spacing: TSizes.v8,
                runSpacing: TSizes.v8,
                children: weekDays.map((day) {
                  final selected = selectedDays.contains(day);
                  return FilterChip(
                    label: Text(day),
                    selected: selected,
                    onSelected: (_) {
                      setState(() {
                        selected
                            ? selectedDays.remove(day)
                            : selectedDays.add(day);
                      });
                    },
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: TSizes.v16),

            ///  HEADQUARTER
            CardContainer(
              title: TTexts.uiTextHeadquarter,
              child: DropdownButtonFormField<String>(
                value: selectedHeadquarter,
                hint: const Text(TTexts.uiTextSelectHeadquarter),
                items: headquarterAreas.keys
                    .map(
                      (hq) => DropdownMenuItem(
                        value: hq,
                        child: Text(hq),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    selectedHeadquarter = value;
                    selectedArea = null;
                    selectedDoctors.clear();
                  });
                },
                decoration: const InputDecoration(border: OutlineInputBorder()),
              ),
            ),

            const SizedBox(height: TSizes.v16),

            ///  AREA
            if (selectedHeadquarter != null)
              CardContainer(
                title: TTexts.uiTextArea,
                child: DropdownButtonFormField<String>(
                  value: selectedArea,
                  hint: const Text(TTexts.uiTextSelectArea),
                  items: headquarterAreas[selectedHeadquarter]!
                      .map(
                        (area) => DropdownMenuItem(
                          value: area,
                          child: Text(area),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedArea = value;
                      selectedDoctors.clear();
                    });
                  },
                  decoration:
                      const InputDecoration(border: OutlineInputBorder()),
                ),
              ),

            const SizedBox(height: TSizes.v16),

            ///  SEARCH DOCTOR
            if (selectedHeadquarter != null && selectedArea != null) ...[
              /// 🔍 SEARCH DOCTOR
              TextField(
                controller: searchController,
                decoration: InputDecoration(
                  hintText: TTexts.uiTextSearchDoctor,
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ],

            const SizedBox(height: TSizes.v16),

            /// ️ DOCTOR LIST (VISIBLE ONLY AFTER HQ + AREA)
            if (selectedHeadquarter != null && selectedArea != null)
              CardContainer(
                title: TTexts.uiTextDoctors,
                trailing: Text('${selectedDoctors.length} selected',
                    style: const TextStyle(fontSize: TSizes.v12)),
                child: Column(
                  children: filteredDoctors.map((doctor) {
                    final selected = selectedDoctors.contains(doctor);
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: selected
                            ? TColors.materialGreen
                            : TColors.materialGrey300,
                        child: const Icon(Icons.person_2, color: TColors.white),
                      ),
                      title: Text(doctor),
                      trailing: Checkbox(
                        value: selected,
                        onChanged: (val) {
                          setState(() {
                            val!
                                ? selectedDoctors.add(doctor)
                                : selectedDoctors.remove(doctor);
                          });
                        },
                      ),
                    );
                  }).toList(),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
