import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:blueattend/data/model/request/sesi/sesi_request_model.dart';
import 'package:blueattend/presentation/admin/sesi/bloc/sesi_bloc.dart';
import 'package:blueattend/presentation/admin/ble/bloc/ble_bloc.dart';

class SesiAddScreen extends StatefulWidget {
  const SesiAddScreen({super.key});

  @override
  State<SesiAddScreen> createState() => _SesiAddScreenState();
}

class _SesiAddScreenState extends State<SesiAddScreen> {
  final _formKey = GlobalKey<FormState>();

  final namaEventController = TextEditingController();
  final tokenController = TextEditingController();

  DateTime? waktuMulai;
  DateTime? tenggatWaktu;

  final waktuMulaiController = TextEditingController();
  final tenggatController = TextEditingController();

  final formatter = DateFormat('d MMMM yyyy HH:mm', 'id_ID');

  final List<String> selectedBle = [];

  final List<String> area = [
    "Sangat Dekat",
    "Dekat",
    "Menengah",
    "Cukup Jauh",
    "Jauh",
  ];

  String? selectedArea;

  @override
  void initState() {
    super.initState();
    context.read<BleBloc>().add(BleRequested());
  }

  @override
  void dispose() {
    namaEventController.dispose();
    tokenController.dispose();
    waktuMulaiController.dispose();
    tenggatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: const Color(0xFFEAF3FF),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              height: 60,
              width: double.infinity,
              color: Color(0xFF003C97),
              child: Stack(
                children: [
                  Positioned(
                    right: -20,
                    top: -30,
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: Color(0xFFFFF8E1),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),

                  Positioned(
                    right: -60,
                    bottom: -60,
                    child: Container(
                      width: 150,
                      height: 110,
                      decoration: const BoxDecoration(
                        color: Color(0xFF6C9BD2),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),

                  Positioned(
                    left: 10,
                    top: 0,
                    bottom: 0,
                    child: IconButton(
                      icon: const Icon(
                        Icons.arrow_circle_left_outlined,
                        color: Colors.white,
                        size: 35,
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),

                  const Center(
                    child: Text(
                      "Tambah Event",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF6C9BD2), Color(0xFFFFF8E1)],
                  ),
                ),
                child: SafeArea(
                  child: BlocConsumer<SesiBloc, SesiState>(
                    listener: (context, state) {
                      if (state is SesiOperationSuccess) {
                        Navigator.pop(context, true);
                      }
                    },
                    builder: (context, state) {
                      return SingleChildScrollView(
                        padding: const EdgeInsets.all(20),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Nama Event',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: namaEventController,
                                decoration: InputDecoration(
                                  hintText: 'Masukkan nama olahraga',
                                  filled: true,
                                  fillColor: Colors.white,
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 14,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(50),
                                    borderSide: BorderSide.none,
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Nama olahraga wajib diisi';
                                  }
                                  return null;
                                },
                              ),

                              const SizedBox(height: 12),
                              const Text(
                                'Token',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: tokenController,
                                decoration: InputDecoration(
                                  hintText: 'Masukkan token',
                                  filled: true,
                                  fillColor: Colors.white,
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 14,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(50),
                                    borderSide: BorderSide.none,
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Token wajib diisi';
                                  }
                                  return null;
                                },
                              ),

                              const SizedBox(height: 12),
                              const Text(
                                'Waktu Mulai',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: waktuMulaiController,
                                readOnly: true,
                                decoration: InputDecoration(
                                  hintText: 'Pilih waktu mulai',
                                  filled: true,
                                  fillColor: Colors.white,
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 14,
                                  ),
                                  suffixIcon: Icon(Icons.calendar_today),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(50),
                                    borderSide: BorderSide.none,
                                  ),
                                ),
                                onTap: () async {
                                  final date = await showDatePicker(
                                    context: context,
                                    locale: const Locale('id', 'ID'),
                                    firstDate: DateTime.now(),
                                    lastDate: DateTime(2100),
                                    initialDate: DateTime.now(),
                                  );
                                  if (date == null) return;
                                  
                                  if (!context.mounted) return;
                                  final time = await showTimePicker(
                                    context: context,
                                    initialTime: TimeOfDay.now(),
                                    builder: (context, child) {
                                      return Localizations.override(
                                        context: context,
                                        child: child,
                                      );
                                    },
                                  );
                                  if (time == null) return;

                                  final dt = DateTime(
                                    date.year,
                                    date.month,
                                    date.day,
                                    time.hour,
                                    time.minute,
                                  );

                                  setState(() {
                                    waktuMulai = dt;
                                    waktuMulaiController.text = formatter
                                        .format(dt);
                                  });
                                },
                                validator:
                                    (value) =>
                                        waktuMulai == null
                                            ? "Wajib dipilih"
                                            : null,
                              ),

                              const SizedBox(height: 12),
                              const Text(
                                'Waktu Selesai',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: tenggatController,
                                readOnly: true,
                                decoration: InputDecoration(
                                  hintText: 'Pilih waktu selesai',
                                  filled: true,
                                  fillColor: Colors.white,
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 14,
                                  ),
                                  suffixIcon: Icon(Icons.calendar_today),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(50),
                                    borderSide: BorderSide.none,
                                  ),
                                ),
                                onTap: () async {
                                  final date = await showDatePicker(
                                    context: context,
                                    locale: const Locale('id', 'ID'),
                                    firstDate: DateTime.now(),
                                    lastDate: DateTime(2100),
                                    initialDate: DateTime.now(),
                                  );
                                  if (date == null) return;

                                  if (!context.mounted) return;
                                  final time = await showTimePicker(
                                    context: context,
                                    initialTime: TimeOfDay.now(),
                                  );
                                  if (time == null) return;

                                  final dt = DateTime(
                                    date.year,
                                    date.month,
                                    date.day,
                                    time.hour,
                                    time.minute,
                                  );

                                  setState(() {
                                    tenggatWaktu = dt;
                                    tenggatController.text = formatter.format(
                                      dt,
                                    );
                                  });
                                },
                                validator: (value) {
                                  if (tenggatWaktu == null) {
                                    return "Wajib dipilih";
                                  }

                                  if (waktuMulai != null &&
                                      !tenggatWaktu!.isAfter(waktuMulai!)) {
                                    return "Waktu selesai harus setelah waktu mulai";
                                  }

                                  return null;
                                },
                              ),

                              const SizedBox(height: 12),
                              const Text(
                                'Area',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 8),
                              DropdownButtonFormField<String>(
                                value: selectedArea,
                                decoration: InputDecoration(
                                  hintText: 'Pilih Area',
                                  filled: true,
                                  fillColor: Colors.white,
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 14,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(50),
                                    borderSide: BorderSide.none,
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(50),
                                    borderSide: const BorderSide(
                                      color: Color(0xFF6C9BD2),
                                      width: 2,
                                    ),
                                  ),
                                ),
                                items:
                                    area.map((value) {
                                      return DropdownMenuItem<String>(
                                        value: value,
                                        child: Text(value),
                                      );
                                    }).toList(),
                                onChanged: (val) {
                                  setState(() {
                                    selectedArea = val;
                                  });
                                },
                                validator:
                                    (value) =>
                                        value == null
                                            ? 'Area wajib dipilih'
                                            : null,
                              ),

                              const SizedBox(height: 12),
                              const Text(
                                'BLE',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 8),

                              BlocBuilder<BleBloc, BleState>(
                                builder: (context, state) {
                                  if (state is BleLoading) {
                                    return const Center(
                                      child: CircularProgressIndicator(
                                            color: Color(0xFF002F87),
                                          ),
                                    );
                                  }

                                  if (state is BleLoaded) {
                                    return Column(
                                      children:
                                          state.listBle.map((ble) {
                                            return CheckboxListTile(
                                              activeColor: Color(0xFF003C97),
                                              title: Text(ble.namaDevice),
                                              value: selectedBle.contains(
                                                ble.uuid,
                                              ),
                                              onChanged: (val) {
                                                setState(() {
                                                  if (val == true) {
                                                    selectedBle.add(ble.uuid);
                                                  } else {
                                                    selectedBle.remove(
                                                      ble.uuid,
                                                    );
                                                  }
                                                });
                                              },
                                            );
                                          }).toList(),
                                    );
                                  }

                                  return const SizedBox();
                                },
                              ),

                              const SizedBox(height: 40),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Color(0xFF6C9BD2),
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 14,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                  ),
                                  onPressed:
                                      state is SesiLoading
                                          ? null
                                          : () {
                                            if (_formKey.currentState!
                                                .validate()) {
                                              if (selectedBle.isEmpty) {
                                                ScaffoldMessenger.of(
                                                  context,
                                                ).showSnackBar(
                                                  SnackBar(
                                                    content: Text(
                                                      "Ble wajib dipilih",
                                                      style: const TextStyle(
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                                    backgroundColor: Colors.red,
                                                    behavior:
                                                        SnackBarBehavior
                                                            .floating,
                                                    margin:
                                                        const EdgeInsets.symmetric(
                                                          horizontal: 20,
                                                          vertical: 10,
                                                        ),
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            12,
                                                          ),
                                                    ),
                                                    elevation: 6,
                                                    duration: const Duration(
                                                      seconds: 3,
                                                    ),
                                                  ),
                                                );
                                                return;
                                              }

                                              context.read<SesiBloc>().add(
                                                SesiCreateRequested(
                                                  requestModel:
                                                      SesiRequestModel(
                                                        namaEvent:
                                                            namaEventController
                                                                .text,
                                                        token:
                                                            tokenController
                                                                .text,
                                                        waktuMulai: waktuMulai!,
                                                        tenggatWaktu:
                                                            tenggatWaktu!,
                                                        area: selectedArea!,
                                                        ble: selectedBle,
                                                      ),
                                                ),
                                              );
                                            }
                                          },
                                  child:
                                      state is SesiLoading
                                          ? const CircularProgressIndicator(
                                            color: Colors.white,
                                          )
                                          : const Text(
                                            "Simpan",
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
