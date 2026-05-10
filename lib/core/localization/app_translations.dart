import 'package:get/get.dart';
import 'en_us.dart';
import 'vi_vn.dart';

class AppTranslations extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {'vi_VN': viVN, 'en_US': enUS};
}
