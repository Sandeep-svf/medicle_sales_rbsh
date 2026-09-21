import 'package:flutter/material.dart';
import '../../doctor_offline/models/doctor.dart';
import '../../../utils/constants/colors.dart';
import 'order_widgets.dart';

class OrderDoctorPicker extends StatefulWidget {
  const OrderDoctorPicker({super.key, required this.doctors});
  final List<Doctor> doctors;
  @override
  State<OrderDoctorPicker> createState() => _OrderDoctorPickerState();
}

class _OrderDoctorPickerState extends State<OrderDoctorPicker> {
  String _query = '';
  @override
  Widget build(BuildContext context) {
    final terms = _query.toLowerCase().trim().split(RegExp(r'\s+'));
    final doctors = widget.doctors.where((d) {
      final text = [
        d.name,
        d.clinicName,
        d.clinicAddress,
        d.phone,
        d.areaName,
        d.specialization,
        d.headOfficeName
      ].whereType<String>().join(' ').toLowerCase();
      return terms.every(text.contains);
    }).toList()
      ..sort((a, b) => (a.name ?? '').compareTo(b.name ?? ''));
    return Theme(
        data: orderTheme(context),
        child: SafeArea(
            child: SizedBox(
          height: MediaQuery.sizeOf(context).height * .85,
          child: Padding(
            padding: EdgeInsets.only(
                bottom: MediaQuery.viewInsetsOf(context).bottom),
            child: Column(children: [
              Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 8, 12),
                  child: Row(children: [
                    const Expanded(
                        child: Text('Select doctor',
                            style: TextStyle(
                                fontSize: 21, fontWeight: FontWeight.w800))),
                    IconButton(
                        tooltip: 'Close doctor list',
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close)),
                  ])),
              Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: TextField(
                    onChanged: (value) => setState(() => _query = value),
                    decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.search),
                        hintText: 'Name, clinic, area, specialty or phone'),
                  )),
              Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text('${doctors.length} doctors · available offline',
                      style: const TextStyle(color: TColors.textSecondary))),
              Expanded(
                  child: doctors.isEmpty
                      ? const Center(
                          child: Padding(
                              padding: EdgeInsets.all(24),
                              child: Text(
                                  'No matching doctors. Try another search or download your doctor list from Offline Doctors.',
                                  textAlign: TextAlign.center)))
                      : ListView.separated(
                          itemCount: doctors.length,
                          separatorBuilder: (_, __) => const Divider(height: 1),
                          itemBuilder: (context, index) {
                            final d = doctors[index];
                            return ListTile(
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 8),
                                leading: const CircleAvatar(
                                    backgroundColor: TColors.primary_shade50,
                                    child: Icon(Icons.person_outline,
                                        color: TColors.primary)),
                                title: Text(d.name ?? 'Doctor',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w700)),
                                subtitle: Text([
                                  d.specialization,
                                  d.clinicName,
                                  d.clinicAddress,
                                  d.areaName,
                                  d.phone
                                ]
                                    .whereType<String>()
                                    .where((v) => v.isNotEmpty)
                                    .join(' · ')),
                                trailing: const Icon(Icons.chevron_right),
                                onTap: () => Navigator.pop(context, d));
                          },
                        )),
            ]),
          ),
        )));
  }
}
