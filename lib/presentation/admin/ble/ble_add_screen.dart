import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:blueattend/data/model/request/ble/ble_request_model.dart';
import 'package:blueattend/presentation/admin/ble/bloc/ble_bloc.dart';

class BleAddScreen extends StatefulWidget {
  const BleAddScreen({super.key});

  @override
  State<BleAddScreen> createState() => _BleAddScreenState();
}

class _BleAddScreenState extends State<BleAddScreen> {
  final _formKey = GlobalKey<FormState>();
  final uuidController = TextEditingController(text: '19121981');
  final namaDeviceController = TextEditingController();

  String formatUuid(String input) {
    String data = input.replaceAll(RegExp(r'[^0-9a-fA-F]'), '');

    if (data.length > 32) {
      data = data.substring(0, 32);
    }

    final buffer = StringBuffer();

    for (int i = 0; i < data.length; i++) {
      buffer.write(data[i]);

      if (i == 7 || i == 11 || i == 15 || i == 19) {
        buffer.write('-');
      }
    }

    return buffer.toString();
  }

  @override
  void dispose() {
    uuidController.dispose();
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
                      "Tambah BLE",
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
                  child: BlocConsumer<BleBloc, BleState>(
                    listener: (context, state) {
                      if (state is BleOperationSuccess) {
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
                                'Nama Device',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Colors.black,
                                ),
                              ),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: namaDeviceController,
                                decoration: InputDecoration(
                                  hintText: 'Masukkan Nama Device',
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
                                    return 'Nama Device wajib diisi';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 12),
                              // Form input Ble
                              const Text(
                                'UUID',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Colors.black,
                                ),
                              ),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: uuidController,
                                decoration: InputDecoration(
                                  hintText: 'Masukkan UUID',
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
                                keyboardType: TextInputType.text,
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(
                                    RegExp(r'[0-9a-fA-F]'),
                                  ),
                                ],
                                onChanged: (value) {
                                  const prefix = '19121981';
                                  const maxLength = 32;

                                  String clean = value.replaceAll(
                                    RegExp(r'[^0-9a-fA-F]'),
                                    '',
                                  );

                                  if (!clean.startsWith(prefix)) {
                                    if (clean.length < prefix.length) {
                                      clean = prefix;
                                    } else {
                                      clean =
                                          prefix +
                                          clean.substring(prefix.length);
                                    }
                                  }
                                  if (clean.length > maxLength) {
                                    clean = clean.substring(0, maxLength);
                                  }

                                  if (uuidController.text == clean) return;

                                  uuidController.value = TextEditingValue(
                                    text: clean,
                                    selection: TextSelection.collapsed(
                                      offset: clean.length,
                                    ),
                                  );
                                },
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'UUID wajib diisi';
                                  }

                                  // wajib lengkap 32 karakter hex
                                  final clean = value.replaceAll('-', '');

                                  if (clean.length != 32) {
                                    return 'UUID harus lengkap 32 karakter';
                                  }

                                  if (!clean.startsWith('19121981')) {
                                    return 'di awal 19121981 wajib ada';
                                  }

                                  return null;
                                },
                              ),
                              const SizedBox(height: 80),
                              // Simpan Ble
                              Row(
                                children: [
                                  Expanded(
                                    child: ElevatedButton(
                                      onPressed:
                                          state is BleLoading
                                              ? null
                                              : () {
                                                if (_formKey.currentState!
                                                    .validate()) {
                                                  final rawUuid =
                                                      uuidController.text;

                                                  final formattedUuid =
                                                      formatUuid(rawUuid);
                                                  final requestModel =
                                                      BleRequestModel(
                                                        uuid: formattedUuid,
                                                        namaDevice:
                                                            namaDeviceController
                                                                .text,
                                                      );
                                                  context.read<BleBloc>().add(
                                                    BleCreateRequested(
                                                      requestModel:
                                                          requestModel,
                                                    ),
                                                  );
                                                }
                                              },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Color(0xFF6C9BD2),
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 14,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            30,
                                          ),
                                        ),
                                      ),
                                      child:
                                          state is BleLoading
                                              ? const SizedBox(
                                                height: 20,
                                                width: 20,
                                                child:
                                                    CircularProgressIndicator(
                                                      strokeWidth: 2,
                                                      color: Colors.white,
                                                    ),
                                              )
                                              : const Text(
                                                'Simpan',
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                    ),
                                  ),
                                ],
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
