extension DateTimeExt on DateTime {
  String get timeDifference {
    final duration = DateTime.now().difference(this);

    if (duration.inDays < 1) {
      if (duration.inHours < 1) {
        if (duration.inMinutes < 1) {
          return "${duration.inSeconds} seconds";
        } else {
          return "${duration.inMinutes} minutes";
        }
      } else {
        return "${duration.inHours} hours";
      }
    } else if (duration.inDays < 7) {
      return "${duration.inDays} days";
    } else if (duration.inDays < 30) {
      return "${(duration.inDays / 7).floor()} weeks";
    } else if (duration.inDays < 365) {
      return "${(duration.inDays / 30).floor()} months";
    } else {
      return "${(duration.inDays / 365).floor()} years";
    }
  }
}
