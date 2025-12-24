import 'dart:convert';
import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:flutter_clean_arch/core/di/setup_get_it.dart';
import 'package:flutter_clean_arch/core/exceptions/expection.dart';
import 'package:flutter_clean_arch/core/network/network_repository.dart';
import 'package:flutter_clean_arch/core/util/network_info.dart';
import 'package:http/http.dart' as http;

class NetworkRepositoryImpl implements NetworkRepository {
  final http.Client client;

  NetworkRepositoryImpl({required this.client});

  @override
  Future<Either<Failure, dynamic>> postMethod({
    required String url,
    required Map<String, dynamic> params,
  }) async {
    final bool isConnected = await globalGetIt<NetworkInfo>().isConnected;

    if (!isConnected) {
      return const Left(NetworkFailure("No internet connection"));
    }

    try {
      final response = await client.post(
        Uri.parse(url),
        body: params,
        headers: {
          HttpHeaders.contentTypeHeader: 'application/x-www-form-urlencoded',
        },
      );

      return _handleResponse(response);

    } on SocketException {
      return const Left(NetworkFailure("No internet connection"));
    } on HttpException {
      return const Left(ServerFailure("Server error occurred"));
    } on FormatException {
      return const Left(ServerFailure("Invalid response format"));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  /// Centralized response handler
  Either<Failure, dynamic> _handleResponse(http.Response response) {
    switch (response.statusCode) {
      case 200:
      case 201:
        return Right(_decodeResponse(response.body));

      case 400:
        return const Left(ServerFailure("Bad request"));

      case 401:
      case 403:
        return const Left(ServerFailure("Unauthorized access"));

      case 404:
        return const Left(ServerFailure("API not found"));

      case 500:
        return const Left(ServerFailure("Internal server error"));

      default:
        return Left(
          ServerFailure(
            "Unexpected error: ${response.statusCode}",
          ),
        );
    }
  }

  dynamic _decodeResponse(String body) {
    try {
      return json.decode(body);
    } catch (_) {
      return body;
    }
  }
}
