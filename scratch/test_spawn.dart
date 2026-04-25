import 'dart:io';

void main() async {
  print('Attempting to spawn "whoami"...');
  try {
    final result = await Process.run('whoami', []);
    print('Exit code: ${result.exitCode}');
    print('Output: ${result.stdout}');
  } catch (e) {
    print('Error: $e');
  }
}
