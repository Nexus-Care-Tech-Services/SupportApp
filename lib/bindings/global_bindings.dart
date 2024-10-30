import 'package:get/get.dart';
import 'package:support/controller/listener_home_screen_controller.dart';

class GlobalBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ListenerHomeScreenController>(
        () => ListenerHomeScreenController(),
        fenix: true);
  }
}
