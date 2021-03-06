// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// @dart=2.8
library frontend_server;

import 'dart:io';

import 'server.dart';


void main(List<String> args) async {

  ///debug
 // List<String> ss = [];
 // ss.add('--sdk-root');
 // ss.add('D:/flutter/bin/cache/artifacts/engine/common/flutter_patched_sdk/');
 // ss.add('--target=flutter');
 // ss.add('-Ddart.developer.causal_async_stacks=true');
 // ss.add('-Ddart.vm.profile=false');
 // ss.add('-Ddart.vm.product=false');
 // ss.add('--bytecode-options=source-positions,local-var-info,debugger-stops,instance-field-initializers,keep-unreachable-code,avoid-closure-call-instructions');
 // ss.add('--enable-asserts');
 // ss.add('--track-widget-creation');
 // ss.add('--no-link-platform');
 // ss.add('--packages');
 // ss.add('D:/work/flutter/ftd/example/.packages');
 // ss.add('--output-dill');
 // ss.add('D:/work/flutter/ftd/example/.dart_tool/flutter_build/56208f03b451c209dfea2f3e31df5937/app.dill');
 // ss.add('--depfile');
 // ss.add('D:/work/flutter/ftd/example/.dart_tool/flutter_build/56208f03b451c209dfea2f3e31df5937/kernel_snapshot.d');
 // ss.add('package:example/main.dart');

  final int exitCode = await starter(args);
  if (exitCode != 0) {
    exit(exitCode);
  }
}
