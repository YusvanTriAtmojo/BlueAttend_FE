import 'package:blueattend/service/service_ble_advertise.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:blueattend/data/model/response/get_all_ble_response_model.dart';
import 'package:blueattend/presentation/admin/ble/bloc/ble_bloc.dart';
import 'package:blueattend/presentation/admin/ble/ble_add_screen.dart';
import 'package:blueattend/presentation/admin/ble/ble_edit_screen.dart';

class BleScreen extends StatefulWidget {
  const BleScreen({super.key});

  @override
  State<BleScreen> createState() => _BleScreenState();
}

class _BleScreenState extends State<BleScreen> {
  int? advertisingBleId;

  @override
  void initState() {
    super.initState();
    context.read<BleBloc>().add(BleRequested());
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
                        color: Color(0xFF6C9BD2),
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
                        color: Color(0xFFFFF8E1),
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
                      "Data BLE",
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
                      if (state is BleActionFailure) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Row(
                              children: [
                                Icon(Icons.error_outline, color: Colors.white),
                                SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    state.error,
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            backgroundColor: Color(0xFFF2A7A0),
                            behavior: SnackBarBehavior.floating,
                            margin: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 10,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 3,
                            duration: const Duration(seconds: 3),
                          ),
                        );
                      } else if (state is BleOperationSuccess) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Row(
                              children: [
                                Icon(Icons.check_circle, color: Colors.white),
                                SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    state.message,
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            backgroundColor: Color(0xFF81C784),
                            behavior: SnackBarBehavior.floating,
                            margin: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 10,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 3,
                            duration: const Duration(seconds: 3),
                          ),
                        );
                      }
                    },
                    builder: (context, state) {
                      if (state is BleLoading) {
                        return const Center(
                          child: CircularProgressIndicator(
                            color: Color(0xFF002F87),
                          ),
                        );
                      } else if (state is BleLoadFailure) {
                        return Center(
                          child: Text('Gagal memuat data: ${state.error}'),
                        );
                      } else if (state is BleLoaded) {
                        final List<Ble> bleList = state.listBle;
                        if (bleList.isEmpty) {
                          return const Center(
                            child: Text("Ble belum tersedia"),
                          );
                        }
                        // Daftar Kategori
                        return ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: bleList.length,
                          itemBuilder: (context, index) {
                            final ble = bleList[index];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 30),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.7),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Column(
                                  children: [
                                    const SizedBox(height: 15),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          ble.namaDevice,
                                          style: const TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black,
                                          ),
                                        ),
                                        Switch(
                                          value: advertisingBleId == ble.id,
                                          activeColor: const Color(0xFF6C9BD2),
                                          onChanged: (value) async {
                                            if (value) {
                                              await ServiceBleAdvertiser.startAdvertising();

                                              setState(() {
                                                advertisingBleId = ble.id;
                                              });
                                            } else {
                                              await ServiceBleAdvertiser.stopAdvertising();

                                              setState(() {
                                                advertisingBleId = null;
                                              });
                                            }
                                          },
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 10),
                                    Text(
                                      ble.uuid,
                                      style: const TextStyle(
                                        fontSize: 15,
                                        color: Colors.black,
                                      ),
                                    ),
                                    SizedBox(height: 10),
                                    // edit kategori
                                    Padding(
                                      padding: const EdgeInsets.only(
                                        bottom: 10,
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Container(
                                            decoration: const BoxDecoration(
                                              color: Color(0xFFF6E7A1),
                                              borderRadius: BorderRadius.all(
                                                Radius.circular(12),
                                              ),
                                            ),
                                            height: 40,
                                            width: 40,
                                            child: IconButton(
                                              icon: const Icon(
                                                Icons.edit,
                                                color: Colors.black,
                                              ),
                                              onPressed: () async {
                                                final result = await Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder:
                                                        (context) =>
                                                            BlocProvider.value(
                                                              value:
                                                                  context
                                                                      .read<
                                                                        BleBloc
                                                                      >(),
                                                              child:
                                                                  BleEditScreen(
                                                                    ble: ble,
                                                                  ),
                                                            ),
                                                  ),
                                                );

                                                if (!context.mounted) return;
                                                if (result != null &&
                                                    result == true) {
                                                  context.read<BleBloc>().add(
                                                    BleRequested(),
                                                  );
                                                }
                                              },
                                            ),
                                          ),
                                          SizedBox(width: 20),
                                          Container(
                                            decoration: const BoxDecoration(
                                              color: Color(0xFFF2A7A0),
                                              borderRadius: BorderRadius.all(
                                                Radius.circular(12),
                                              ),
                                            ),
                                            height: 40,
                                            width: 40,
                                            child: IconButton(
                                              icon: const Icon(
                                                Icons.delete,
                                                color: Colors.black,
                                              ),
                                              onPressed: () {
                                                showDialog(
                                                  context: context,
                                                  builder: (
                                                    BuildContext dialogContext,
                                                  ) {
                                                    return AlertDialog(
                                                      backgroundColor:
                                                          Colors.white,
                                                      content: Padding(
                                                        padding:
                                                            const EdgeInsets.symmetric(
                                                              horizontal: 15,
                                                            ),
                                                        child: RichText(
                                                          text: TextSpan(
                                                            style:
                                                                const TextStyle(
                                                                  color:
                                                                      Colors
                                                                          .black,
                                                                  fontSize: 16,
                                                                ),
                                                            children: [
                                                              const TextSpan(
                                                                text:
                                                                    "Apakah anda yakin ingin menghapus ",
                                                              ),
                                                              TextSpan(
                                                                text:
                                                                    "${ble.namaDevice}?",
                                                                style: const TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                      actions: [
                                                        Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceEvenly,
                                                          children: [
                                                            TextButton(
                                                              child: const Text(
                                                                "Batal",
                                                                style: TextStyle(
                                                                  color:
                                                                      Colors
                                                                          .black,
                                                                ),
                                                              ),
                                                              onPressed:
                                                                  () =>
                                                                      Navigator.of(
                                                                        dialogContext,
                                                                      ).pop(),
                                                            ),
                                                            ElevatedButton(
                                                              style: ElevatedButton.styleFrom(
                                                                backgroundColor:
                                                                    Color(
                                                                      0xFF6C9BD2,
                                                                    ),
                                                              ),
                                                              child: const Text(
                                                                "Oke",
                                                                style: TextStyle(
                                                                  color:
                                                                      Colors
                                                                          .white,
                                                                ),
                                                              ),
                                                              onPressed: () {
                                                                Navigator.of(
                                                                  dialogContext,
                                                                ).pop();
                                                                context
                                                                    .read<
                                                                      BleBloc
                                                                    >()
                                                                    .add(
                                                                      BleDeleted(
                                                                        ble.id,
                                                                      ),
                                                                    );
                                                              },
                                                            ),
                                                          ],
                                                        ),
                                                      ],
                                                    );
                                                  },
                                                );
                                              },
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      } else {
                        return const Center();
                      }
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),

      // tambah Ble
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 20),
        child: FloatingActionButton(
          onPressed: () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (context) => BlocProvider.value(
                      value: context.read<BleBloc>(),
                      child: BleAddScreen(),
                    ),
              ),
            );

            if (!context.mounted) return;
            if (result != null && result == true) {
              context.read<BleBloc>().add(BleRequested());
            }
          },
          backgroundColor: Color(0xFF003C97),
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
    );
  }
}
