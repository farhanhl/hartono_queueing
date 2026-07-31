import 'package:get_storage/get_storage.dart';
import 'package:hartono_queueing/app/utilities/app_const.dart';

mixin LocalService {
  final box = GetStorage();

  Future<bool> saveCode(String code) async {
    await box.remove(INPUT_CODE);
    await box.write(INPUT_CODE, code);
    return true;
  }

  Future<String> getCode() async {
    final code = await box.read(INPUT_CODE) ?? "";
    if (code.isEmpty) {
      throw Exception("Kode tidak ditemukan di local storage.");
    }
    return code;
  }

  Future<void> deleteCode() async {
    await box.remove(INPUT_CODE);
  }
}
