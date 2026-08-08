import 'package:blueattend/presentation/admin/sesi/qr_code_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:blueattend/presentation/admin/sesi/bloc/sesi_bloc.dart';
import 'package:blueattend/presentation/admin/sesi/sesi_add_screen.dart';
import 'package:blueattend/presentation/admin/sesi/sesi_edit_screen.dart';

class SesiScreen extends StatefulWidget {
  const SesiScreen({super.key});
  

  @override
  State<SesiScreen> createState() => _SesiScreenState();
}

class _SesiScreenState extends State<SesiScreen> {

  
  @override
  void initState() {
    super.initState();
    context.read<SesiBloc>().add(SesiRequested());
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
                      "Data Event",
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
                      if (state is SesiActionFailure) {
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
                      } else if (state is SesiOperationSuccess) {
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
                      if (state is SesiFailure) {
                        return Center(child: Text(state.error));
                      }

                      if (state is SesiLoaded) {
                        final list = state.listSesi;

                        if (list.isEmpty) {
                          return const Center(
                            child: Text("Event Belum tersedia"),
                          );
                        }

                        return ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: list.length,
                          itemBuilder: (context, index) {
                            final sesi = list[index];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: Column(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: const BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(14),
                                        topRight: Radius.circular(14),
                                      ),
                                    ),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  Text(
                                                    sesi.namaEvent,
                                                    style: const TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                  const Spacer(),
                                                  Container(
                                                    decoration:
                                                        const BoxDecoration(
                                                          color: Color(0xFF6C9BD2,),
                                                          borderRadius:
                                                            BorderRadius.all(
                                                              Radius.circular(12,),
                                                            ),
                                                        ),
                                                    height: 50,
                                                    width: 50,
                                                    child: IconButton(
                                                      icon: const Icon(Icons.qr_code_2_outlined,size: 35,),
                                                      color: Colors.black,
                                                      onPressed: () {
                                                        showDialog(
                                                          context: context,
                                                          builder: (_) {
                                                            return QrTokenDialog(
                                                              token: sesi.token,
                                                              event: sesi.namaEvent,
                                                            );
                                                          },
                                                        );
                                                      },
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              Row(
                                                children: [
                                                  const SizedBox(
                                                    width: 60,
                                                    child: Text("Mulai"),
                                                  ),
                                                  const Text(": "),
                                                  Text(
                                                    DateFormat(
                                                      'dd MMM yyyy HH:mm',
                                                      'id_ID',
                                                    ).format(sesi.waktuMulai),
                                                  ),
                                                ],
                                              ),
                                              Row(
                                                children: [
                                                  const SizedBox(
                                                    width: 60,
                                                    child: Text("Selesai"),
                                                  ),
                                                  const Text(": "),
                                                  Text(
                                                    DateFormat(
                                                      'dd MMM yyyy HH:mm',
                                                      'id_ID',
                                                    ).format(sesi.tenggatWaktu),
                                                  ),
                                                ],
                                              ),
                                              Row(
                                                children: [
                                                  const SizedBox(
                                                    width: 60,
                                                    child: Text("Token"),
                                                  ),
                                                  const Text(": "),
                                                  Text(sesi.token),
                                                ],
                                              ),
                                              Row(
                                                children: [
                                                  const SizedBox(
                                                    width: 60,
                                                    child: Text("Area"),
                                                  ),
                                                  const Text(": "),
                                                  Text(sesi.area),
                                                ],
                                              ),
                                              SizedBox(height: 10),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceEvenly,
                                                children: [
                                                  Container(
                                                    decoration:
                                                        const BoxDecoration(
                                                          color: Color(0xFFF6E7A1),
                                                          borderRadius:
                                                              BorderRadius.all(
                                                                Radius.circular(12,),
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
                                                                (context,) => BlocProvider.value(
                                                                  value:
                                                                    context.read<SesiBloc>(),
                                                                  child:
                                                                    SesiEditScreen(sesi:sesi,),
                                                                ),
                                                          ),
                                                        );

                                                        if (!context.mounted) {
                                                          return;
                                                        }
                                                        if (result != null && result == true) {
                                                          context
                                                            .read<SesiBloc>()
                                                            .add(
                                                            SesiRequested(),
                                                            );
                                                        }
                                                      },
                                                    ),
                                                  ),

                                                  Container(
                                                    decoration:
                                                        const BoxDecoration(
                                                          color: Color(0xFFF2A7A0,),
                                                          borderRadius:
                                                            BorderRadius.all(
                                                              Radius.circular(12,),
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
                                                            BuildContext
                                                            dialogContext,
                                                          ) {
                                                            return AlertDialog(
                                                              backgroundColor:
                                                                  Colors.white,
                                                              content: Padding(
                                                                padding:
                                                                    const EdgeInsets.symmetric(
                                                                      horizontal:
                                                                          15,
                                                                    ),
                                                                child: RichText(
                                                                  text: TextSpan(
                                                                    style: const TextStyle(
                                                                      color:
                                                                          Colors
                                                                              .black,
                                                                      fontSize:
                                                                          16,
                                                                    ),
                                                                    children: [
                                                                      const TextSpan(
                                                                        text:
                                                                            "Apakah anda yakin ingin menghapus sesi event ",
                                                                      ),
                                                                      TextSpan(
                                                                        text:
                                                                            "${sesi.namaEvent}?",
                                                                        style: const TextStyle(
                                                                          fontWeight:
                                                                              FontWeight.bold,
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
                                                                              Colors.black,
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
                                                                              Colors.white,
                                                                        ),
                                                                      ),
                                                                      onPressed: () {
                                                                        Navigator.of(
                                                                          dialogContext,
                                                                        ).pop();
                                                                        context
                                                                            .read<
                                                                              SesiBloc
                                                                            >()
                                                                            .add(
                                                                              SesiDeleted(
                                                                                sesi.id,
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
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.all(10),
                                    decoration: const BoxDecoration(
                                      color: Color(0xFF003C97),
                                      borderRadius: BorderRadius.only(
                                        bottomLeft: Radius.circular(14),
                                        bottomRight: Radius.circular(14),
                                      ),
                                    ),
                                    child:
                                        sesi.ble.isEmpty
                                            ? const Text(
                                              "Tidak ada BLE",
                                              style: TextStyle(
                                                color: Colors.white,
                                              ),
                                            )
                                            : Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children:
                                                  sesi.ble.map((e) {
                                                    return Text(
                                                      "${e.namaDevice} - ${e.uuid}",
                                                      style: const TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 12,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    );
                                                  }).toList(),
                                            ),
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      }

                      return const Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFF002F87),
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

      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 20),
        child: FloatingActionButton(
          backgroundColor: Color(0xFF003C97),
          onPressed: () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (_) => BlocProvider.value(
                      value: context.read<SesiBloc>(),
                      child: const SesiAddScreen(),
                    ),
              ),
            );

            if (result == true && context.mounted) {
              context.read<SesiBloc>().add(SesiRequested());
            }
          },
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
    );
  }
}
