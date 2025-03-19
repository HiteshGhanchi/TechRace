import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class Contact extends StatelessWidget {
  const Contact({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
        backgroundColor: Colors.transparent,
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: 10,
            sigmaY: 10,
          ),
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.blueGrey.withOpacity(0.2),
              borderRadius: BorderRadius.circular(32),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ContactTile(
                  name: 'Pratham Shid',
                  designation: 'Executive Head',
                  phone: '8928153619',
                  icon: FontAwesomeIcons.shieldHalved,
                ),
                ContactTile(
                  name: 'Raj Sonawane',
                  designation: 'Event Head',
                  phone: '8369123034',
                  icon: FontAwesomeIcons.shield,
                ),
                ContactTile(
                  name: 'Vivek Valanj',
                  designation: 'Operations',
                  phone: '8928731857',
                  icon: FontAwesomeIcons.spaceAwesome,
                ),
                ContactTile(
                  name: 'Hitesh Ghanchi',
                  designation: 'Technical Head',
                  phone: '7506272085',
                  icon: FontAwesomeIcons.server,
                ),
                ContactTile(
                  name: 'Vedant Vaidya',
                  designation: 'Technical Head',
                  phone: '9270735616',
                  icon: FontAwesomeIcons.microchip,
                ),
              ],
            ),
          ),
        ));
  }
}

class ContactTile extends StatelessWidget {
  ContactTile({
    super.key,
    required this.name,
    required this.designation,
    required this.phone,
    required this.icon,
  });
  String name;
  String designation;
  String phone;
  IconData icon;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.all(3),
      leading: Padding(
        padding: const EdgeInsets.all(4.0),
        child: FaIcon(
          icon,
          size: 25.w,
        ),
      ),
      minLeadingWidth: 0,
      minVerticalPadding: 0,
      title: Row(
        children: [
          // Expand the text content so the buttons get proper space
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: TextStyle(fontSize: 14.sp)), // Responsive text
                Text(designation,
                    style: TextStyle(fontSize: 11.sp, color: Colors.blue)),
              ],
            ),
          ),

          // Buttons remain at the end without causing overflow
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                constraints: const BoxConstraints(minHeight: 10, minWidth: 40),
                padding: EdgeInsets.zero,
                onPressed: () {
                  launchUrl(Uri.parse('tel:$phone'));
                },
                icon: const Icon(Icons.phone),
              ),
              IconButton(
                constraints: const BoxConstraints(minHeight: 30, minWidth: 30),
                padding: EdgeInsets.zero,
                onPressed: () {
                  List nameList = name.split(' ');
                  launchUrl(
                      Uri.parse(
                          'https://api.whatsapp.com/send?phone=91$phone&text=Hi%20${nameList[0]}'),
                      mode: LaunchMode.externalApplication);
                },
                icon: const FaIcon(FontAwesomeIcons.whatsapp),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
