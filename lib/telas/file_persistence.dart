import 'dart:io';

import 'package:path_provider/path_provider.dart';

class FilePersistence {
  Future _getFile() async {
    final directory = await getApplicationDocumentsDirectory();
    File localFile = File(directory.path + "/task_file.json");

    if (localFile.existsSync()) {
      return localFile;
    } else {
      return localFile.create(recursive: true);
    }
  }
}
