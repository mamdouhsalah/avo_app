import 'dart:developer';
import 'dart:io';

import 'package:cloudinary_api/uploader/cloudinary_uploader.dart';
// ignore: implementation_imports
import 'package:cloudinary_api/src/request/model/uploader_params.dart';
import 'package:cloudinary_url_gen/cloudinary.dart';

class CloudinaryService {
  late Cloudinary _cloudinary;

  CloudinaryService() {
    _cloudinary = Cloudinary.fromStringUrl(
      "cloudinary://568273993439218:y7cAx3Lc2orrohzi6Atax29ZU68@doqsgqya9",
    );
    _cloudinary.config.urlConfig.secure = true;
  }

  Future<String> uploadImage(File file) async {
    try {
      var response = await _cloudinary.uploader().upload(file);
      if (response != null) {
        log("Cloudinary upload status code: ${response.error.toString()}");
        if (response.error != null) {
          log("Cloudinary upload error: ${response.error?.message ?? response.error}");
        }
        if (response.data != null) {
          log("Cloudinary upload secure URL: ${response.data!.secureUrl}");
          return response.data!.secureUrl ?? '';
        }
      }
      return '';
    } catch (e, stack) {
      log("Cloudinary upload exception: $e");
      log(stack.toString());
      rethrow;
    }
  }
  Future<String> uploadFile(File file, {String? resourceType}) async {
    try {
      var response = await _cloudinary.uploader().upload(
        file,
        params: UploadParams()..resourceType = resourceType ?? 'auto',
      );
      if (response != null && response.data != null) {
        return response.data!.secureUrl ?? '';
      }
      return '';
    } catch (e) {
      log("Cloudinary upload file exception: $e");
      return '';
    }
  }
}
