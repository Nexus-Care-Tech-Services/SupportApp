import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:support/screen/auth/login_via_whatsapp_screen.dart';
import 'package:support/utils/color.dart';
import 'package:url_launcher/url_launcher.dart';

class CustomBackButton extends StatefulWidget {
  final bool isfromLoginScreen;
  final bool isListner;

  const CustomBackButton(
      {Key? key, required this.isfromLoginScreen, required this.isListner})
      : super(key: key);

  @override
  State<CustomBackButton> createState() => _CustomBackButtonState();
}

class _CustomBackButtonState extends State<CustomBackButton> {
  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        shadowColor: tabColor,
        child: Container(
          decoration: BoxDecoration(
            color: inboxCardColor,
            borderRadius: BorderRadius.circular(10),
          ),
          height: 48,
          width: 48,
          child: InkWell(
            onTap: () {
              if (!widget.isfromLoginScreen) {
                Navigator.pop(context);
              } else {
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const LoginViaWhatsApp()));
              }
            },
            child: Center(
              child: Padding(
                padding: const EdgeInsets.only(left: 6.0),
                child: Icon(
                  Icons.arrow_back_ios,
                  size: 20,
                  color: textColor,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Custom Share Button

class CustomShareButton extends StatefulWidget {
  const CustomShareButton({Key? key}) : super(key: key);

  @override
  State<CustomShareButton> createState() => _CustomShareButtonState();
}

class _CustomShareButtonState extends State<CustomShareButton> {
  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        shadowColor: tabColor,
        child: Container(
          decoration: BoxDecoration(
            color: inboxCardColor,
            borderRadius: BorderRadius.circular(10),
          ),
          height: 48,
          width: 48,
          child: InkWell(
            onTap: () {
              Share.share(
                  'https://play.google.com/store/apps/details?id=com.support2heal.app',
                  subject: 'Support Lets Talk');
            },
            child: Center(
              child: Icon(
                Icons.share,
                size: 20,
                color: textColor,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Whatsapp Share Button
//test
class WhatsappShareButton extends StatefulWidget {
  const WhatsappShareButton({Key? key}) : super(key: key);

  @override
  State<WhatsappShareButton> createState() => _WhatsappShareButtonState();
}

class _WhatsappShareButtonState extends State<WhatsappShareButton> {
  final String message =
      'https://play.google.com/store/apps/details?id=com.support2heal.app'; // Replace with your desired message

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        shadowColor: tabColor,
        child: Container(
          decoration: BoxDecoration(
            color: inboxCardColor,
            // Replace with your desired background color
            borderRadius: BorderRadius.circular(10),
          ),
          height: 48,
          width: 48,
          child: InkWell(
            onTap: () {
              _launchWhatsApp(message);
            },
            child: Center(
              child: ImageIcon(
                const AssetImage('assets/images/WhatsappIcon.png'),
                size: 30,
                color: textColor, // Replace with your desired icon color
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _launchWhatsApp(String message) async {
    var url = "https://wa.me/?text=${Uri.encodeComponent(message)}";
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      throw 'Could not launch $url';
    }
  }
}
