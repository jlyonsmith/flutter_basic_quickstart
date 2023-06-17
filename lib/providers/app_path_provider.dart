import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';

class IAppPathService {
  Directory getTempSubDir(String subPath) => throw Error();
  Directory getAppDocSubDir(String subPath) => throw Error();
  Directory getAppDocDir() => throw Error();
}

// This class makes getting an app sub-dir a synchronous affair
class AppPathService implements IAppPathService {
  late Directory _appDocDir;
  late Directory _tempDir;

  AppPathService._internal();

  static Future<IAppPathService> create() async {
    final appPathService = AppPathService._internal();

    appPathService._appDocDir = await getApplicationDocumentsDirectory();
    appPathService._tempDir = await getTemporaryDirectory();

    return appPathService;
  }

  @override
  Directory getTempSubDir(String subPath) {
    return Directory(path.join(_tempDir.path, subPath));
  }

  @override
  Directory getAppDocSubDir(String subPath) {
    return Directory(path.join(_appDocDir.path, subPath));
  }

  @override
  Directory getAppDocDir() {
    return _appDocDir;
  }
}

final appPathProvider = Provider((ref) => IAppPathService());
