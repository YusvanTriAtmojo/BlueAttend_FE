import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:blueattend/data/model/request/sesi/sesi_request_model.dart';
import 'package:blueattend/data/model/response/get_all_sesi_response_model.dart';
import 'package:blueattend/presentation/admin/sesi/bloc/sesi_bloc.dart';
import 'package:blueattend/presentation/admin/ble/bloc/ble_bloc.dart';

class SesiEditScreen extends StatefulWidget {
  final Sesi sesi;

  const SesiEditScreen({super.key, required this.sesi});

  @override
  State<SesiEditScreen> createState() => _SesiEditScreenState();
}

class _SesiEditScreenState extends State<SesiEditScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController namaEventController;
  late final TextEditingController tokenController;
  late final TextEditingController waktuMulaiController;
  late final TextEditingController tenggatController;

  late DateTime waktuMulai;
  late DateTime tenggatWaktu;
  final DateFormat formatter = DateFormat('d MMMM yyyy HH:mm', 'id_ID');

  final List<String> selectedBle = [];

  final List<String> area = [
    'Sangat Dekat',
    'Dekat',
    'Menengah',
    'Cukup Jauh',
    'Jauh',
  ];

  String? selectedArea;

  @override
  void initState() {
    super.initState();

    namaEventController = TextEditingController(text: widget.sesi.namaEvent);

    tokenController = TextEditingController(text: widget.sesi.token);
    waktuMulai = widget.sesi.waktuMulai;
    tenggatWaktu = widget.sesi.tenggatWaktu;

    waktuMulaiController = TextEditingController(
      text: formatter.format(waktuMulai),
    );

    tenggatController = TextEditingController(
      text: formatter.format(tenggatWaktu),
    );

    selectedBle.addAll(widget.sesi.ble.map((e) => e.uuid).toList());

    context.read<BleBloc>().add(BleRequested());

    selectedArea = widget.sesi.area;
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
                      "Mengubah Event",
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
                                  filled: true,
                                  fillColor: Colors.white,
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
                                  filled: true,
                                  fillColor: Colors.white,
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
                                  color: Colors.black,
                                ),
                              ),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: waktuMulaiController,
                                readOnly: true,
                                decoration: InputDecoration(
                                  hintText: 'Pilih tanggal & waktu',
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
                                  suffixIcon: const Icon(Icons.calendar_today),
                                ),
                                onTap: () async {
                                  DateTime initial = waktuMulai;

                                  DateTime firstDate;

                                  if (waktuMulai.isAfter(tenggatWaktu)) {
                                    firstDate = DateTime.now();
                                  } else {
                                    firstDate = waktuMulai;
                                  }

                                  final pickedDate = await showDatePicker(
                                    context: context,
                                    initialDate: initial,
                                    firstDate: firstDate,
                                    lastDate: DateTime(2100),
                                  );

                                  if (pickedDate == null) return;
                                  if (!context.mounted) return;
                                  final pickedTime = await showTimePicker(
                                    context: context,
                                    initialTime: TimeOfDay(
                                      hour: waktuMulai.hour,
                                      minute: waktuMulai.minute,
                                    ),
                                  );

                                  if (pickedTime == null) return;

                                  final finalDateTime = DateTime(
                                    pickedDate.year,
                                    pickedDate.month,
                                    pickedDate.day,
                                    pickedTime.hour,
                                    pickedTime.minute,
                                  );

                                  setState(() {
                                    waktuMulai = finalDateTime;
                                    waktuMulaiController.text = formatter
                                        .format(finalDateTime);
                                  });
                                },
                              ),

                              const SizedBox(height: 12),

                              const Text(
                                'Waktu Selesai',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Colors.black,
                                ),
                              ),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: tenggatController,
                                readOnly: true,
                                decoration: InputDecoration(
                                  hintText: 'Pilih tanggal & waktu',
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
                                  suffixIcon: const Icon(Icons.calendar_today),
                                ),
                                onTap: () async {
                                  if (tenggatWaktu.isBefore(waktuMulai)) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          "Silakan ubah kembali waktu mulai agar sama dengan waktu selesai, lalu ubah waktu selesai terlebih dahulu",
                                          style: const TextStyle(
                                            color: Colors.white,
                                          ),
                                        ),
                                        backgroundColor: Colors.red,
                                        behavior: SnackBarBehavior.floating,
                                        margin: const EdgeInsets.symmetric(
                                          horizontal: 20,
                                          vertical: 10,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        elevation: 6,
                                        duration: const Duration(seconds: 3),
                                      ),
                                    );
                                    return;
                                  }

                                  final pickedDate = await showDatePicker(
                                    context: context,
                                    initialDate: tenggatWaktu,
                                    firstDate: waktuMulai,
                                    lastDate: DateTime(2100),
                                  );

                                  if (pickedDate == null) return;

                                  if (!context.mounted) return;
                                  final pickedTime = await showTimePicker(
                                    context: context,
                                    initialTime: TimeOfDay(
                                      hour: tenggatWaktu.hour,
                                      minute: tenggatWaktu.minute,
                                    ),
                                  );

                                  if (pickedTime == null) return;

                                  final finalDateTime = DateTime(
                                    pickedDate.year,
                                    pickedDate.month,
                                    pickedDate.day,
                                    pickedTime.hour,
                                    pickedTime.minute,
                                  );

                                  if (!context.mounted) return;
                                  if (!finalDateTime.isAfter(waktuMulai)) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          "Waktu selesai harus setelah waktu mulai",
                                          style: const TextStyle(
                                            color: Colors.white,
                                          ),
                                        ),
                                        backgroundColor: Colors.red,
                                        behavior: SnackBarBehavior.floating,
                                        margin: const EdgeInsets.symmetric(
                                          horizontal: 20,
                                          vertical: 10,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        elevation: 6,
                                        duration: const Duration(seconds: 3),
                                      ),
                                    );
                                    return;
                                  }

                                  setState(() {
                                    tenggatWaktu = finalDateTime;
                                    tenggatController.text = formatter.format(
                                      finalDateTime,
                                    );
                                  });
                                },
                                validator: (value) {
                                  if (tenggatWaktu.isBefore(waktuMulai)) {
                                    return 'Waktu selesai harus setelah waktu mulai';
                                  }
                                  return null;
                                },
                              ),

                              const SizedBox(height: 10),
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
                                builder: (context, stateBle) {
                                  if (stateBle is BleLoading) {
                                    return const Center(
                                      child: CircularProgressIndicator(
                                        color: Color(0xFF002F87),
                                      ),
                                    );
                                  }

                                  if (stateBle is BleLoaded) {
                                    return Column(
                                      children:
                                          stateBle.listBle.map((ble) {
                                            final isChecked = selectedBle
                                                .contains(ble.uuid);

                                            return CheckboxListTile(
                                              activeColor: Color(0xFF003C97),
                                              title: Text(ble.namaDevice),
                                              value: isChecked,
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

                              const SizedBox(height: 30),
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
                                  onPressed: () {
                                    if (_formKey.currentState!.validate()) {
                                      context.read<SesiBloc>().add(
                                        SesiUpdateRequested(
                                          id: widget.sesi.id,
                                          requestModel: SesiRequestModel(
                                            namaEvent: namaEventController.text,
                                            token: tokenController.text,
                                            waktuMulai: waktuMulai,
                                            tenggatWaktu: tenggatWaktu,
                                            ble: selectedBle,
                                            area: selectedArea!,
                                          ),
                                        ),
                                      );
                                    }
                                  },
                                  child: const Text(
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
