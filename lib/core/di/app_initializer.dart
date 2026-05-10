import 'package:firebase_core/firebase_core.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:notification/firebase_options.dart';
import 'package:notification/services/fcm_service.dart';
import 'package:notification/services/hive_service.dart';
import 'package:notification/services/sync_service.dart';
import 'package:notification/features/auth/data/datasources/token_storage.dart';
import 'package:notification/features/auth/presentation/controllers/auth_controller.dart';

class AppInitializer {
  static Future<void> init() async {
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );

      await HiveService.openBoxes();

      await Get.find<TokenStorage>().init();

      await GoogleSignIn.instance.initialize(
        serverClientId:
            '548079551425-eg3oag6g930pasi6o4ikm46q85jaj3gs.apps.googleusercontent.com',
      );

      Get.find<AuthController>().bootstrap();

      Get.find<FcmService>().initialise();
      Get.find<SyncService>().startListening();
    } catch (e) {
      rethrow;
    }
  }
}
