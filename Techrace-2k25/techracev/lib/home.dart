import 'package:flutter/material.dart';
import 'package:get/get.dart';
// import 'package:get/get_navigation/get_navigation.dart';
// import 'package:get/instance_manager.dart';
import 'package:get_storage/get_storage.dart';
import 'package:techracev/controllers/valcontroller.dart';
import 'package:techracev/gamevalidate.dart';
import 'package:techracev/login.dart';
import 'package:techracev/main.dart';
import 'package:techracev/utils/desk.dart';

class Home extends StatelessWidget {
  Home({super.key});

  // final bool stateLog = GetStorage().read('stateLog') ?? false;
  final ValidationController vC = Get.find();
  @override
  Widget build(BuildContext context) {
    // return (clueNo != 0) ?  HomeLog() : const Login();
    return Obx(
      () {
        if (!vC.isTeamsFetched.value) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
    else if (vC.stateLog.value == true) {
      return const Desk();
    } else if (clueNo != 0) {
      return HomeLog();
    } else {
      return const Login();
    }
      },
    );
    
  }
}

class HomeLog extends StatelessWidget {
  HomeLog({
    Key? key,
  }) : super(key: key);

  final ValidationController vC = Get.find();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.centerTop,
      floatingActionButton: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            InkWell(
              borderRadius: BorderRadius.circular(32),
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
                                box.erase();
                                clueNo = 0;
                                // Remove any route in the stack
                                Navigator.of(context)
                                    .popUntil((route) => false);
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => Home()),
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
                    child: Icon(
                      Icons.login,
                      size: 32,
                    ),
                  )),
            ),
            Chip(
              label: Text(
                'Clue No: $clueNo',
                style: const TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
      ),
      body: Center(
        child: Obx(() {
          if (vC.isDateFetched.value == false ||
              vC.isTeamsFetched.value == false) {
            return const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(
                  height: 16,
                ),
                Chip(
                    label: Text(
                  "Fetching Game Start Time & Users",
                  style: TextStyle(fontSize: 16),
                ))
              ],
            );
          }

          return TextButton(
            style: ButtonStyle(
              padding: MaterialStateProperty.all(const EdgeInsets.all(16)),
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const Validate(),
                ),
              );
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.check_circle_outline,
                  size: 36,
                ),
                // add a vertical divider
                Container(
                  height: 36,
                  width: 1,
                  color: Colors.white54,
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                ),
                const Text(
                  'Start Validation',
                  style: TextStyle(fontSize: 24),
                ),
              ],
            ),
          );
        }),
      ),
      // ),
    );
  }
}
