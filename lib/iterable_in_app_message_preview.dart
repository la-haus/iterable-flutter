class IterableInAppMessagePreview {
  final String messageId;
  final DateTime? createdAt;
  final DateTime? expiresAt;
  final IterableInboxMetadata? inboxMetadata;
  final bool? read;

  IterableInAppMessagePreview({
    required this.messageId,
    this.createdAt,
    this.expiresAt,
    this.inboxMetadata,
    this.read,
  });

  static IterableInAppMessagePreview fromJson(
      Map<String, dynamic> jsonMessage) {
    return IterableInAppMessagePreview(
      messageId: jsonMessage['messageId'] ?? "",
      createdAt: jsonMessage['createdAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(jsonMessage['createdAt'])
          : null,
      expiresAt: jsonMessage['expiresAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(jsonMessage['expiresAt'])
          : null,
      inboxMetadata:
          IterableInboxMetadata.fromJson(jsonMessage['inboxMetadata']),
      read: jsonMessage['read'],
    );
  }
}

class IterableInboxMetadata {
  final String? title;
  final String? subtitle;
  final String? icon;

  IterableInboxMetadata({
    this.title,
    this.subtitle,
    this.icon,
  });

  static IterableInboxMetadata fromJson(Map<String, dynamic> json) {
    return IterableInboxMetadata(
      title: json['title'],
      subtitle: json['subtitle'],
      icon: json['icon'],
    );
  }
}
