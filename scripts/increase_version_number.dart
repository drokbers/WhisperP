import 'dart:io';

Future<void> main() async {
  await increaseVersion();
}

Future<void> increaseVersion() async {
  final pubspecFile = File('pubspec.yaml');
  final pubspecContent = await pubspecFile.readAsString();

  final regExp = RegExp(r"version: 0.0.(.*?)\+(.*?)");

  final previousVersionNumberMatch = regExp.firstMatch(pubspecContent);
  if (previousVersionNumberMatch == null) return;

  final previousVersion =
      int.tryParse("${previousVersionNumberMatch.group(1)}");

  if (previousVersion != null) {
    final finalpubspecContent = pubspecContent.replaceAll(
      'version: 0.0.$previousVersion+$previousVersion',
      'version: 0.0.${previousVersion + 1}+${previousVersion + 1}',
    );

    await pubspecFile.writeAsString(finalpubspecContent);
  } else {
    return;
  }
}
