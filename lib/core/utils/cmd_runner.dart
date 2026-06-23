import 'dart:convert';
import 'dart:io';

class CmdRunner {
  Stream<String> runCommandStream({
    required String command,
    required List<String> arguments,
  }) async* {
    final process = await Process.start(command, arguments);

    yield* process.stdout
        .transform(utf8.decoder)
        .transform(const LineSplitter());
  }
}
