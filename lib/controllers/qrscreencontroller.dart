import 'package:get/get.dart';

class QrScreenController extends GetxController {
  var isLoading = false.obs;
  var isUploadSuccessful = false.obs;
  var isBackgroundBlurred = false.obs;

  void startLoading() {
    isLoading(true);
    isBackgroundBlurred(true);
  }

  void stopLoading(bool success) {
    isLoading(false);
    isUploadSuccessful(success);
    isBackgroundBlurred(false);
  }
}
