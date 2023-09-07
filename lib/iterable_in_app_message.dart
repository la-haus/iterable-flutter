import 'dart:convert';

class IterableInAppMessage {
  final String messageId;
  final int? campaignId;
  final DateTime? createdAt;
  final DateTime? expiresAt;
  final IterableInAppContent? content;
  final IterableInAppTrigger? trigger;
  final bool? saveToInbox;
  final IterableInboxMetadata? inboxMetadata;
  final bool? read;
  final double? priorityLevel;
  //TODO: review this
  final String? customPayload;
  final bool? silentInbox;

  IterableInAppMessage({
    required this.messageId,
    this.campaignId,
    this.createdAt,
    this.expiresAt,
    this.content,
    this.trigger,
    this.saveToInbox,
    this.inboxMetadata,
    this.read,
    this.priorityLevel,
    this.customPayload,
    this.silentInbox,
  });

  static IterableInAppMessage fromJson(Map<String, dynamic> jsonMessage) {
    return IterableInAppMessage(
      messageId: jsonMessage['messageId'] ?? "",
      campaignId: int.tryParse(jsonMessage['campaignId'] ?? ""),
      createdAt: jsonMessage['createdAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(jsonMessage['createdAt'])
          : null,
      expiresAt: jsonMessage['expiresAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(jsonMessage['expiresAt'])
          : null,
      content: IterableInAppContent.fromJson(jsonMessage['content']),
      trigger: IterableInAppTrigger.fromJson(jsonMessage['trigger']),
      saveToInbox: jsonMessage['saveToInbox'],
      inboxMetadata:
          IterableInboxMetadata.fromJson(jsonMessage['inboxMetadata']),
      read: jsonMessage['read'],
      priorityLevel: jsonMessage['priorityLevel'] is double
          ? jsonMessage['priorityLevel']
          : jsonMessage['priorityLevel'].toDouble(),
      customPayload: jsonMessage['customPayload'],
    );
  }
}

enum IterableInAppTriggerType {
  immediate,
  event,
  never,
}

class IterableInAppTrigger {
  final IterableInAppTriggerType? type;

  IterableInAppTrigger({
    this.type,
  });

  static IterableInAppTrigger fromJson(Map<String, dynamic> json) {
    final stringType = json['type'];

    switch (stringType) {
      case "immediate":
        return IterableInAppTrigger(
          type: IterableInAppTriggerType.immediate,
        );

      case "event":
        return IterableInAppTrigger(
          type: IterableInAppTriggerType.event,
        );

      case "never":
        return IterableInAppTrigger(
          type: IterableInAppTriggerType.never,
        );

      default:
        return IterableInAppTrigger(
          type: IterableInAppTriggerType.never,
        );
    }
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

class IterableInAppContent {
  final String? html;
  final List<double>? edgeInsets;
  final InAppBgColor? bgColor;
  final bool? shouldAnimate;

  IterableInAppContent({
    this.html,
    this.edgeInsets,
    this.bgColor,
    this.shouldAnimate,
  });

  static IterableInAppContent fromJson(Map<String, dynamic> json) {
    return IterableInAppContent(
      html: json['html'],
      edgeInsets: json['edgeInsets'] != null
          ? List<dynamic>.from(json['edgeInsets']).map((e) {
              if (e is double) {
                return e;
              } else if (e is int) {
                return e.toDouble();
              } else {
                return 0.0;
              }
            }).toList()
          : null,
      bgColor: json['bgColor'] != null
          ? InAppBgColor.fromJson(json['bgColor'])
          : null,
      shouldAnimate: json['shouldAnimate'],
    );
  }
}

class InAppBgColor {
  String? bgHexColor;
  double? bgAlpha;

  InAppBgColor(
    this.bgHexColor,
    this.bgAlpha,
  );

  static InAppBgColor fromJson(Map<String, dynamic> json) {
    return InAppBgColor(
      json['bgHexColor'],
      double.tryParse(json['bgAlpha'] ?? ""),
    );
  }
}
