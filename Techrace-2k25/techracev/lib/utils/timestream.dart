import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:get/get.dart';
import 'package:techracev/controllers/valcontroller.dart';

// import 'package:techrace/utils/timer.dart';
DateTime time = DateTime.now();

class TimeStream {
  final ValidationController _vC = Get.find();

  FirebaseDatabase database = FirebaseDatabase.instance;
  late DatabaseReference ref;
  late Stream<DatabaseEvent> stream;
  late StreamSubscription<DatabaseEvent> sub1;
  TimeStream() {
    ref = FirebaseDatabase.instance.ref("/start_datetime");
    stream = ref.onValue;
    sub1 = stream.listen((DatabaseEvent event) {
      // print(event.snapshot.value);
      try {
        time = DateTime.parse(event.snapshot.value as String);
        _vC.isDateFetched.value = true;
        // print("Time: $time");
        // TODO: Test on throttled internet connection
      } catch (e) {
        // print("Error: $e");
        Get.snackbar(
            "Error Fetching Game Start Time", "Please restart the application");
      }
    });
  }
}
