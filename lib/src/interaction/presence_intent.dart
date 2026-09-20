part of 'world_intent.dart';

class SetWorldContext extends WorldIntent {
  const SetWorldContext(this.contextId);
  final String contextId;
}

class ApplyWorldAvatar extends WorldIntent {
  const ApplyWorldAvatar(this.avatar);
  final WorldAvatar avatar;
}
