import 'dart:async';
import 'dart:typed_data';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_beacon/flutter_beacon.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
// import 'package:qrscan/qrscan.dart';
import 'package:techracev/controllers/valcontroller.dart';
import 'package:techracev/home.dart';

import '../main.dart';

class Desk extends StatefulWidget {
  const Desk({super.key});

  @override
  State<Desk> createState() => _DeskState();
}

class _DeskState extends State<Desk> with SingleTickerProviderStateMixin {
  final ValidationController vC = Get.find();

  // List<Region> regions = <Region>[Region(identifier: 'techRace')];

  //list of teams who's beacon is detected
  List teamCodes = [];
  ValueNotifier<int> listLength = ValueNotifier(0);
  ValueNotifier<bool> validating = ValueNotifier(true);
  //beacon detection stream
  late StreamSubscription rangingStream;
  ValueNotifier<String> debugResult = ValueNotifier<String>('');
  //animation controller
  late AnimationController _controller;
  // RxBool recur = false.obs;
  RxBool isCamScan = false.obs;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    super.dispose();
    rangingStream.cancel();
    flutterBeacon.close;
    _controller.dispose();
    validating.dispose();
    listLength.dispose();
    debugResult.dispose();
  }

  @override
  Widget build(BuildContext context) {
    //stream to detect beacons
    // print(vC.regions);
    // print(vC.regions.last);
    rangingStream =
        // flutterBeacon.ranging(regions).listen((RangingResult result) async {
        flutterBeacon.ranging(vC.regions).listen((RangingResult result) async {
      // print(vC.regions);
      debugResult.value = result.beacons.toString();
      if (result.beacons.isNotEmpty) {
        for (var element in result.beacons) {
          if (!teamCodes.contains(element.proximityUUID.substring(33))) {
            teamCodes.add(element.proximityUUID.substring(33));
            listLength.value = teamCodes.length;
          }
        }
      }
    });
    return Scaffold(
      // floatingActionButtonLocation: FloatingActionButtonLocation.startTop,
      // floatingActionButton: const FloatingLogout(),
      appBar: AppBar(
        title: const Text('Desk'),
        centerTitle: true,
        actions:  [FloatingLogout()],
      ),
      body: Center(
        child: Column(
          children: [
            // Row(
            //   mainAxisSize: MainAxisSize.min,
            //   children: [
            //     Obx(() {
            //       return Switch(
            //           value: recur.value,
            //           onChanged: (value) {
            //             // setState(() {
            //             //   recur = value;
            //             // });
            //             recur.value = value;
            //           });
            //     }),
            //     const Padding(
            //       padding: EdgeInsets.symmetric(vertical: 8.0),
            //       child: Text(
            //         'Loop',
            //       ),
            //     ),
            //   ],
            // ),
            TextButton(onPressed: () async {
              isCamScan.value = !isCamScan.value;
              // if (recur) {
              //   while (true) {
              //     String? res = await scan();
              //     String status = await updateState(res as String);
              // Get.closeAllSnackbars();
              // Get.snackbar(res, status);
              // await Future.delayed(const Duration(seconds: 3));
              //   }
              // } else {
              //   String? res = await scan();
              //   String status = await updateState(res as String);
              //   Get.closeAllSnackbars();
              //   Get.snackbar(res, status);
              // }      }
            }, child: Obx(() {
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    (isCamScan.value)
                        ? Icons.qr_code_rounded
                        : Icons.qr_code_scanner_rounded,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    (isCamScan.value) ? 'Stop Scan' : 'Scan',
                  ),
                ],
              );
            })),
            Obx(() {
              if (!isCamScan.value) {
                return const SizedBox();
              }
              return SizedBox(
                height: MediaQuery.of(context).size.height * 0.3,
                width: MediaQuery.of(context).size.width * 0.8,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: MobileScanner(
                    // fit: BoxFit.contain,
                    controller: MobileScannerController(
                      detectionSpeed: DetectionSpeed.normal,
                      // facing: CameraFacing.front,
                      // torchEnabled: true,
                    ),
                    onDetect: (capture) async {
                      final List<Barcode> barcodes = capture.barcodes;
                      final Uint8List? image = capture.image;
                      for (final barcode in barcodes) {
                        // debugPrint('Barcode found! ${barcode.rawValue}');
                        if (barcode.rawValue != null &&
                            barcode.rawValue?.length == 3) {
                          final String teamId = barcode.rawValue!;

                          // if (teamCodesCompleted.contains(teamId)) {
                          //   // close all snackbar
                          //   ScaffoldMessenger.of(context).clearSnackBars();
                          //   ScaffoldMessenger.of(context).showSnackBar(
                          //     SnackBar(
                          //       backgroundColor:
                          //           Colors.blueGrey.withOpacity(0.2),
                          //       content: Text(
                          //           'Team $teamId already validated',
                          //           style: const TextStyle(
                          //             color: Colors.white,
                          //           )),
                          //       margin: const EdgeInsets.all(10),
                          //       behavior: SnackBarBehavior.floating,
                          //       //padding: const EdgeInsets.all(8),
                          //       shape: RoundedRectangleBorder(
                          //         borderRadius: BorderRadius.circular(10),
                          //       ),
                          //     ),
                          //   );
                          //   continue;
                          // }

                          // debugPrint('TeamCode: $teamId');
                          String status = await updateState(teamId).timeout(
                              const Duration(seconds: 5), onTimeout: () {
                            return 'Timeout';
                          });
                          Get.closeAllSnackbars();
                          Get.snackbar(teamId, status);
                          await Future.delayed(const Duration(seconds: 3));
                        }
                      }
                    },
                  ),
                ),
              );
            }),
            TextButton(
                onPressed: () {
                  showDialog(
                      context: context,
                      builder: (context) {
                        String teamID = '';
                        return AlertDialog(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16)),
                          backgroundColor: Colors.blueGrey.withOpacity(0.2),
                          title: const Text('Enter Team ID'),
                          content: TextField(
                            onChanged: (value) {
                              teamID = value;
                            },
                          ),
                          actions: [
                            TextButton(
                                onPressed: () async {
                                  String status = await updateState(teamID);
                                  Get.closeAllSnackbars();
                                  Get.snackbar(teamID, status,
                                      snackPosition: SnackPosition.BOTTOM);
                                  if (!mounted) return;
                                  Navigator.pop(context);
                                },
                                child: const Text('Submit'))
                          ],
                        );
                      });
                },
                child: const Text("Manual Validation")),
            Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                  // style: ButtonStyle(
                  //   backgroundColor:
                  //       MaterialStateProperty.all(Colors.white.withOpacity(0.2)),
                  // ),
                  onPressed: () {
                    if (validating.value) {
                      rangingStream.pause();
                      validating.value = false;
                      _controller.reverse();
                    } else {
                      rangingStream.resume();
                      validating.value = true;
                      _controller.forward();
                    }
                  },
                  child: ValueListenableBuilder(
                    valueListenable: validating,
                    builder: ((context, value, child) {
                      return Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          AnimatedIcon(
                              icon: AnimatedIcons.play_pause,
                              progress: _controller),
                          const SizedBox(width: 8),
                          (validating.value)
                              ? const Text('Pause Beacon Scan')
                              : const Text('Resume Beacon Scan'),
                        ],
                      );
                    }),
                  ),
                ),
                ValueListenableBuilder(
                  valueListenable: validating,
                  builder: (context, child, value) {
                    return (validating.value)
                        ? Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            child: TextButton(
                                onPressed: () {
                                  showGeneralDialog(
                                    barrierDismissible: true,
                                    barrierLabel: 'Debug',
                                    context: context,
                                    pageBuilder: ((context, animation,
                                        secondaryAnimation) {
                                      return AlertDialog(
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(16)),
                                        backgroundColor:
                                            Colors.blueGrey.withOpacity(0.2),
                                        insetPadding: const EdgeInsets.fromLTRB(
                                            16, 0, 16, 0),
                                        title: const Text('Debug'),
                                        content: ValueListenableBuilder(
                                            valueListenable: debugResult,
                                            builder: (context, value, child) {
                                              return Text(debugResult.value);
                                            }),
                                      );
                                    }),
                                  );
                                },
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.bug_report),
                                    SizedBox(width: 8),
                                    Text('Debug'),
                                  ],
                                )),
                          )
                        : Container();
                  },
                ),
              ],
            ),
            Expanded(
              child: ValueListenableBuilder(
                  valueListenable: listLength,
                  builder: (context, child, value) {
                    return ListView.builder(
                        //physics: NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: listLength.value,
                        itemBuilder: (context, index) {
                          return ListTile(
                            title: Text(
                              '${index + 1}. ${teamCodes[index]}',
                              style: const TextStyle(fontSize: 16),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                    onPressed: () async {
                                      String teamID = teamCodes[index];
                                      String status =
                                          await updateState(teamCodes[index]);
                                      if (status[0] == "S") {
                                        await Future.delayed(
                                            const Duration(seconds: 2));
                                        teamCodes.removeAt(index);
                                        listLength.value = teamCodes.length;
                                      }
                                      Get.closeAllSnackbars();
                                      Get.snackbar(teamID, status,
                                          snackPosition: SnackPosition.BOTTOM);
                                    },
                                    icon: const Icon(
                                        Icons.check_circle_outline_rounded)),
                                IconButton(
                                    onPressed: () async {
                                      // String status =
                                      //     await updateState(teamCodes[index]);
                                      // Get.closeAllSnackbars();
                                      // Get.snackbar(teamCodes[index], status);
                                      teamCodes.removeAt(index);
                                      listLength.value = teamCodes.length;
                                    },
                                    icon: const Icon(Icons.delete)),
                              ],
                            ),
                          );
                        });
                  }),
            ),
          ],
        ),
      ),
    );
  }
}

class FloatingLogout extends StatelessWidget {
   FloatingLogout({
    super.key,
  });

  final ValidationController vC = Get.find();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          InkWell(
            //make it circular and blue in colour
            borderRadius: BorderRadius.circular(32),
            //overlayColor: MaterialStateProperty.all(Colors.blue),

            onTap: () async {
              showGeneralDialog(
                  barrierDismissible: true,
                  barrierLabel: '',
                  context: context,
                  pageBuilder: (context, animation, secondaryAnimation) =>
                      AlertDialog(
                        title: const Text('Are you sure you want to logout?'),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: const Text('No'),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                              Navigator.pop(context);
                              final box = GetStorage();
                              vC.stateLog.value = false;
                              box.erase();
                              clueNo = 0;
                              // Navigator.popUntil(context, (route) {
                              //   return route.isFirst;
                              // });
                              // Navigator.pushAndRemoveUntil(context, , (route) => false)
                              // Navigator.push(context, MaterialPageRoute(
                              //   builder: (context) => const Login(),));
                              // Remove any route in the stack
                              Navigator.of(context).popUntil((route) => false);

// Add the first route. Note MyApp() would be your first widget to the app.
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => Home()),
                              );
                            },
                            child: const Text('Yes'),
                          ),
                        ],
                      ));
              // final box = GetStorage();
              // box.erase();
              // Navigator.popUntil(context, (route) {
              //   return route.isFirst;
              // });
            },
            child: Container(
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(32),
                ),
                child: const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Icon(Icons.login),
                )),
          ),
        ],
      ),
    );
  }
}

Future<String> updateState(String res) async {
  try {
    DatabaseReference teamRef =
        // FirebaseDatabase.instance.ref('dummy_teams/$res');
        FirebaseDatabase.instance.ref('${ValidationController.fbChild}/$res');
    DatabaseEvent snapshot = await teamRef.once();
    // if (!snapshot.isBlank) {
    //   return "Team not found";
    // }
    if (snapshot.snapshot.value == null) {
      return "Team not found";
    }
    final stateRef = await teamRef.child('state').once();
    // if (snapshot.snapshot.exists && snapshot.snapshot.value['state'] == "WaitingForGameStart") {
    //   return "Team already validated";
    // }
    if (stateRef.snapshot.value == "WaitingForGameStart") {
      return "Team already validated";
    }
    else if (stateRef.snapshot.value == "WaitingForReg") {
      await teamRef.update({"state": "WaitingForGameStart"});
      return "Successful";
    }
    return "Error";

    // await teamRef.update({"state": "WaitingForGameStart"});
    // return "Successful";
  } catch (e) {
    //print("Error: $e");
    return 'Error';
  }
}
