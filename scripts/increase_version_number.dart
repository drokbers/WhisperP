import 'dart:io';

Future<void> main() async {
  await increaseVersion();
}

Future<void> increaseVersion() async {
  final pubcpecFile = File('pubspec.yaml');
  final pubcpecContent = await pubcpecFile.readAsString();

  final regExp = RegExp(r"version: 0.0.(.*?)\+(.*?)");

  final previousVersionNumberMatch = regExp.firstMatch(pubcpecContent);
  if (previousVersionNumberMatch == null) return;

  final previousVersion =
      int.tryParse("${previousVersionNumberMatch.group(1)}");

  if (previousVersion != null) {
    final finalPubcpecContent = pubcpecContent.replaceAll(
      'version: 0.0.$previousVersion+$previousVersion',
      'version: 0.0.${previousVersion + 1}+${previousVersion + 1}',
    );

    await pubcpecFile.writeAsString(finalPubcpecContent);
  } else
    return;
}
