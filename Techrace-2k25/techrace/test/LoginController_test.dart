import 'dart:math';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_storage/get_storage.dart';
import 'package:techrace/api/api.dart';
import 'package:techrace/firebase_options.dart';
import 'package:techrace/controllers/LoginController.dart';
import 'package:techrace/utils/MLocalStorage.dart';

void main() {
  test("Logasync in", () async {

    await GetStorage.init();
    WidgetsFlutterBinding.ensureInitialized(); //Firebase


 // works in hiding bottom navigation bar
    // await Firebase.initializeApp(
    //   name: 'techracedev23',
    //   // options: DefaultFirebaseOptions.iOS,
    //   options: DefaultFirebaseOptions.currentPlatform,
    // );

    // await Firebase.initializeApp();
    // WidgetsFlutterBinding.ensureInitialized();
    // Api.BASE_URL = "https://1069-2405-201-3d-506c-e1a5-d713-b39a-899.in.ngrok.io";

    // Api.BASE_URL = "server link ";
    final LoginController loginController = LoginController();
    loginController.teamId.text = "345";
    loginController.password.text = "345";

    loginController.login();

    expect(MLocalStorage().getTeamID(), loginController.teamId.text);
    expect(MLocalStorage().getClueData()["clue"], TypeMatcher<String>);

  });
}