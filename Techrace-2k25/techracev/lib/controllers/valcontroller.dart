import 'dart:io';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_beacon/flutter_beacon.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:techracev/main.dart';

class ValidationController extends GetxController {
  static const String fbChild = "dummy_teams";

  final RxBool isDateFetched = false.obs;
  final RxBool isTeamsFetched = false.obs;
  final RxList teamIds = [].obs;

  final RxList<Region> regions = <Region>[].obs;
  final box = GetStorage();

  // final RxBool stateLog = GetStorage().read('stateLog').obs ?? false.obs;
  final RxBool stateLog = false.obs;

  @override
  void onInit() async {
    super.onInit();
    // fetch team ids for validation
    final bool val = box.read('stateLog') ?? false;
    stateLog.value = val;
    await fetchRegions();
  }

  Future<void> fetchTeams() async {
    DatabaseReference ref = FirebaseDatabase.instance.ref(fbChild);
    DataSnapshot snap = await ref.get();
    if (snap.value != null) {
      // teamIds.value = snap.value.keys.toList();
      // print(snap.value?.);
      Object? data = snap.value;
      if (data is Map) {
        teamIds.value = data.keys.toList();
      }
    }
  }

  Future<void> fetchRegions() async {

    // TODO: verify scanning on iOS
    isTeamsFetched.value = false;
    // print("clueNo Fetch check controller: $clueNo");
    final bool stateLog = box.read('stateLog') ?? false;
    if (Platform.isIOS) {
      // TODO: do this on relogin i.e logout & login (verify if required! mostly yes because of the regions identifier)
      await fetchTeams();
      regions.clear();
      if (stateLog) {
        // for each team id in teamIds add a region
        // print("desk");
        for (String teamId in teamIds) {
          regions.add(Region(
            identifier: "techRace",
            proximityUUID: '00000000-0000-0000-0000-000000000$teamId',
            // major: 0,
            // minor: 0,
          ));
        }
      } else {
        // for each team id in teamIds add a region
        // print("clue");
        for (String teamId in teamIds) {
          regions.add(Region(
            identifier: "techRace$clueNo",
            proximityUUID: '00000000-0000-0000-0000-000000000$teamId',
            // major: 0,
            // minor: 0,
          ));
        }
      }
    } else {
      // just add one region
      regions.clear();
      if (stateLog) {
        // print("adesk");
        regions.add(Region(
          identifier: "techRace",
          // major: 0,
          // minor: 0,
        ));
      } else {
        // print("aclue");
        regions.add(Region(
          identifier: "techRace$clueNo",
          // major: 0,
          // minor: 0,
        ));
      }
    }
    isTeamsFetched.value = true;
  }
}
