import 'dart:io' show File;

import 'package:flutter/material.dart' as material show Image;
import 'package:instantgram_clone/state/image_upload/extensions/get_image_aspect_ratio.dart';
import 'package:instantgram_clone/state/image_upload/typedefs/file_path.dart';

extension GetImageFileAspectRatio on FilePath {
  Future<double> getAspectRatio() {
    final file = File(this);
    final image = material.Image.file(file);
    return image.getAspectRatio();
  }
}
