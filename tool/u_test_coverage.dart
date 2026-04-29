// Outil de vérification de couverture pour Unicorn
// Usage: dart tool/u_test_coverage.dart

import 'dart:io';

void main(List<String> args) async {
  final result = await Process.run(
    'dart',
    ['test', '--coverage=coverage'],
    runInShell: true,
  );
  stdout.write(result.stdout);
  stderr.write(result.stderr);

  final report = await Process.run(
    'dart',
    ['run', 'coverage:format_coverage', '--lcov', '--in=coverage', '--out=coverage/lcov.info', '--packages=.dart_tool/package_config.json', '--report-on=lib'],
    runInShell: true,
  );
  stdout.write(report.stdout);
  stderr.write(report.stderr);

  print('Couverture générée dans coverage/lcov.info');
}
