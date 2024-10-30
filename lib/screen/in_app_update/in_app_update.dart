import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:in_app_update/in_app_update.dart';

class UpdateChecker {
  static Future<void> checkForUpdate() async {
    try {
      InAppUpdate.checkForUpdate().then((info) {
        if (kDebugMode) {
          print(info);
        }
        if (info.updateAvailability == UpdateAvailability.updateAvailable &&
            info.immediateUpdateAllowed) {
          InAppUpdate.performImmediateUpdate().catchError((e) {
            log("$e");
          });
        } else if (info.updateAvailability ==
                UpdateAvailability.updateAvailable &&
            info.flexibleUpdateAllowed) {
          InAppUpdate.startFlexibleUpdate().catchError((e) {
            log("$e");
          });
        } else {}
      }).catchError((e) {
        log("$e");
      });
    } catch (e) {
      log("$e");
    }
  }
}
