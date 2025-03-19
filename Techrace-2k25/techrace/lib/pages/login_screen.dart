import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:techrace/controllers/LoginController.dart';
import 'package:techrace/utils/MStyles.dart';

class LoginScreen extends StatelessWidget {
  LoginScreen({Key? key}) : super(key: key);

  LoginController loginController = LoginController();
  final FocusNode _passwordFocusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            Column(
              children: [
                Flexible(
                  child: Material(
                    elevation: 0,
                    clipBehavior: Clip.antiAlias,
                    shape: BeveledRectangleBorder(
                      borderRadius: BorderRadius.only(
                          bottomRight: Radius.circular(200.h),
                          topLeft: Radius.circular(200.h)),
                    ),
                    child: Container(
                      decoration: const BoxDecoration(
                          color: Color(0xff2e92da),
                          border: Border(bottom: BorderSide())),
                    ),
                  ),
                ),
              ],
            ),
            Column(
              children: [
                Flexible(
                  child: Material(
                    elevation: 0,
                    clipBehavior: Clip.antiAlias,
                    shape: BeveledRectangleBorder(
                      borderRadius: BorderRadius.only(
                          bottomRight: Radius.circular(225.h),
                          topLeft: Radius.circular(225.h)),
                    ),
                    child: Container(
                      decoration: const BoxDecoration(
                          color: Color(0xff121827),
                          border: Border(bottom: BorderSide())),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(
                    "assets/images/techrace_logo.png",
                    height: 175.w,
                  ),
                  SizedBox(height: 16.w),
                  TextField(
                    controller: loginController.teamId,
                    decoration: const InputDecoration(
                        border: OutlineInputBorder(), labelText: "Team ID"),
                    textInputAction: TextInputAction.next,
                    onSubmitted: (value) {
                      _passwordFocusNode.requestFocus();
                    },
                  ),
                  SizedBox(
                    height: 16.w,
                  ),
                  Obx(
                    () => TextField(
                      focusNode: _passwordFocusNode,
                      obscureText: loginController.isHidden.value,
                      controller: loginController.password,
                      textInputAction: TextInputAction.done,
                      onSubmitted: (value) => loginController.login(),
                      decoration: InputDecoration(
                          border: const OutlineInputBorder(),
                          suffixIcon: GestureDetector(
                            onTap: () {
                              loginController.toggleHidden();
                            },
                            child: Icon(loginController.isHidden.value
                                ? Icons.visibility
                                : Icons.visibility_off),
                          ),
                          labelText: "Password"),
                    ),
                  ),
                  Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: 0.w, vertical: 30.w),
                    child: ElevatedButton(
                        onPressed: () => {
                              FocusScope.of(context).unfocus(),
                              loginController.login()
                            },
                        clipBehavior: Clip.antiAlias,
                        style: ElevatedButton.styleFrom(
                            minimumSize: const Size.fromHeight(50),
                            shape: BeveledRectangleBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10.w)))),
                        child: Text("LOGIN",
                            style: TextStyle(
                                fontSize: 18.w, fontWeight: FontWeight.w700))),
                  ),
                  SizedBox(
                    height: 100.h,
                  )
                ],
              ),
            ),
            Obx(
              () => !loginController.isLoginLoading.value
                  ? const SizedBox()
                  : TweenAnimationBuilder(
                      tween: Tween(begin: 0, end: 0.5),
                      duration: const Duration(milliseconds: 500),
                      builder:
                          (BuildContext context, Object? value, Widget? child) {
                        return Positioned.fill(
                          child: Container(
                            color: MStyles.darkBgColor
                                .withOpacity(double.parse(value.toString())),
                            child: const Center(
                                child: CircularProgressIndicator()),
                          ),
                        );
                      },
                    ),
            )
          ],
        ),
      ),
    );
  }
}
