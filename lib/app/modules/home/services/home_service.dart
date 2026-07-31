import 'package:hartono_queueing/app/core/provider/api.dart';
import 'package:hartono_queueing/app/modules/home/models/config_model.dart';

class HomeServices {
  Api api;
  HomeServices(this.api);

  Future<ConfigModel> getAppConfig() {
    return api.getAppConfig().then((value) {
      return ConfigModel.fromJson(value.data);
    }).catchError(
      (e) {
        throw e;
      },
    );
  }
}
