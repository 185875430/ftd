// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:io';

import 'package:package_config/package_config.dart';

import 'artifacts.dart';
import 'base/common.dart';
import 'base/file_system.dart';
import 'build_system/build_system.dart';
import 'build_system/targets/common.dart';
import 'cache.dart';
import 'compile.dart';
import 'dart/package_map.dart';
import 'globals.dart' as globals;

const String frontendServerDartSnapshot = 'frontend_server.dart.snapshot';

class DillTransform {
  static String ftName = 'ftd';

  static Future<Directory> getPackagePathFromConfig(
      String packageConfigPath, String packageName) async {
    final PackageConfig packageConfig = await loadPackageConfigWithLogging(
      globals.fs.file(packageConfigPath),
      logger: globals.logger,
    );
    if ((packageConfig?.packages?.length ?? 0) > 0) {
      final Package ftdPackage = packageConfig.packages.toList().firstWhere(
              (Package element) => element.name == packageName,
          orElse: () => null);
      if(ftdPackage!=null){
        return globals.fs.directory(ftdPackage.root.toFilePath());
      }
    }
    return null;
  }

  static Future<Directory> getFlutterFrontendServerDirectory(
      String packagesPath) async {
    return globals.fs.directory(globals.fs.path.join(
        (await getPackagePathFromConfig(packagesPath, ftName)).absolute.path,
        'lib',
        'src',
        'flutter_frontend_server'));
  }

  static Future<bool> ftPackagesEnabled() async {
    String packagesPath = globals.fs.path.join(globals.fs.currentDirectory.path,'.packages');
    final Directory ftDirectory = await getPackagePathFromConfig(packagesPath, ftName);
    if(ftDirectory == null || !ftDirectory.existsSync()){
      return false;
    }
    final File pubSpecFile = globals.fs.file(globals.fs.path.join(ftDirectory.path,'pubspec.yaml'));
    if(!pubSpecFile.existsSync()){
      return false;
    }
    return await checkFtFlutterFrontendServerSnapshot(globals.fs.path.join(globals.fs.currentDirectory.path, globalPackagesPath));
  }

  static Future<bool> checkFtFlutterFrontendServerSnapshot(
      String packagesPath) async {
    //packagesPath修改成自己example的路径，那么后面的getFlutterFrontendServerDirectory就是找依赖的第三方库中的flutter_package中的flutterFrontendServerDirectory文件路径
    final Directory flutterFrontendServerDirectory =
    await getFlutterFrontendServerDirectory(packagesPath); //获取flutter_package下的flutter_frontend_server文件夹路径
    final String ftFlutterFrontendServerSnapshot = globals.fs.path.join(
        flutterFrontendServerDirectory.absolute.path,
        frontendServerDartSnapshot);
    final String defaultFlutterFrontendServerSnapshot = globals.artifacts
        .getArtifactPath(Artifact.frontendServerSnapshotForEngineDartSdk);
    if (!globals.fs.file(ftFlutterFrontendServerSnapshot).existsSync()) {
      final String dartSdkDir = await getDartSdkDependency(
          (await getPackagePathFromConfig(packagesPath, ftName))
              .absolute
              .path);
      final String frontendServerPackageConfigJsonFile =
          '${flutterFrontendServerDirectory.absolute.path}/package_config.json';
      final String rebasedFrontendServerPackageConfigJsonFile =
          '${flutterFrontendServerDirectory.absolute.path}/rebased_package_config.json';
      String frontendServerPackageConfigJson = globals.fs
          .file(frontendServerPackageConfigJsonFile)
          .readAsStringSync();
      frontendServerPackageConfigJson = frontendServerPackageConfigJson
          .replaceAll('../../../third_party/dart/', dartSdkDir);
      globals.fs
          .file(rebasedFrontendServerPackageConfigJsonFile)
          .writeAsStringSync(frontendServerPackageConfigJson);

      final List<String> commands = <String>[
        globals.artifacts.getArtifactPath(Artifact.engineDartBinary),
        '--deterministic',
        '--packages=$rebasedFrontendServerPackageConfigJsonFile',
        '--snapshot=$ftFlutterFrontendServerSnapshot',
        '--snapshot-kind=kernel',
        '${flutterFrontendServerDirectory.absolute.path}/starter.dart'
      ];
      final ProcessResult processResult =
      await globals.processManager.run(commands);
      globals.fs.file(rebasedFrontendServerPackageConfigJsonFile).deleteSync();
      if (processResult.exitCode != 0 ||
          globals.fs.file(ftFlutterFrontendServerSnapshot).existsSync() ==
              false) {
        throwToolExit(
            'ft unexpected error: ${processResult.stderr.toString()}');
      }
    }
    if (globals.fs.file(defaultFlutterFrontendServerSnapshot).existsSync()) {
      globals.fs.file(defaultFlutterFrontendServerSnapshot).deleteSync();
    }
    globals.fs
        .file(ftFlutterFrontendServerSnapshot)
        .copySync(defaultFlutterFrontendServerSnapshot);
    return true;
  }

  static Future<String> getDartSdkDependency(String ftPackageDir) async {
    final ProcessResult processResult = await globals.processManager.run(
        <String>[
          globals.fs.path.join(
              globals.artifacts.getArtifactPath(Artifact.engineDartSdkPath),
              'bin',
              'pub'),
          'get',
          '--verbosity=warning'
        ],
        workingDirectory: ftPackageDir,
        environment: <String, String>{'FLUTTER_ROOT': Cache.flutterRoot});
    if (processResult.exitCode != 0) {
      throwToolExit(
          'ft unexpected error: ${processResult.stderr.toString()}');
    }
    final Directory kernelDir = await getPackagePathFromConfig(
        globals.fs.path.join(ftPackageDir, globalPackagesPath), 'kernel');
    return kernelDir.parent.parent.uri.toString();
  }

  Future<void> runBuildDillCommand(Environment environment) async {
    final Directory ftPackageDir =
        globals.fs.currentDirectory;
    final Directory previousDirectory = globals.fs.currentDirectory;
    globals.fs.currentDirectory = ftPackageDir;
    final String relativeDir = environment.outputDir.absolute.path
        .substring(environment.projectDir.absolute.path.length +1);
    final String outputDir = globals.fs.path.join(ftPackageDir.path, relativeDir);
    final String buildDir =
    globals.fs.path.join(ftPackageDir.path, '.dart_tool', 'flutter_build');
    final Map<String, String> defines = environment.defines;
    defines[kTargetFile] = globals.fs.path
        .join(ftPackageDir.path, 'lib', 'main.dart');

    final Environment auxEnvironment = Environment(
        projectDir: ftPackageDir,
        outputDir: globals.fs.directory(outputDir),
        cacheDir: environment.cacheDir,
        flutterRootDir: environment.flutterRootDir,
        fileSystem: environment.fileSystem,
        logger: environment.logger,
        artifacts: environment.artifacts,
        processManager: environment.processManager,
        engineVersion: environment.engineVersion,
        buildDir: globals.fs.directory(buildDir),
        defines: defines,
        inputs: environment.inputs);
    const KernelSnapshot auxKernelSnapshot = KernelSnapshot();
    await auxKernelSnapshot.buildImpl(auxEnvironment);
    final File originalDillFile = globals.fs.file(
        globals.fs.path.join(environment.buildDir.absolute.path, 'app.dill'));
    print('originalDillFile = ${originalDillFile.path}');
    globals.fs.currentDirectory = previousDirectory;
  }
}