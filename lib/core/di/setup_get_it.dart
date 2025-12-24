import 'package:flutter_clean_arch/core/util/network_info.dart';
import 'package:get_it/get_it.dart';

final GetIt globalGetIt = GetIt.instance;

Future<void> setUpGetIt() async {
  globalGetIt.registerLazySingleton<NetworkInfo>(
    () => NetworkInfoImpl(globalGetIt()),
  );
}
