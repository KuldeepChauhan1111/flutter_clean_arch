import 'package:dartz/dartz.dart';
import 'package:flutter_clean_arch/core/exceptions/expection.dart';

abstract class NetworkRepository {
  Future<Either<Failure, dynamic>> postMethod({
    required String url,
    required Map<String, dynamic> params,
  });
}
