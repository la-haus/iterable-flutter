Map<dynamic, dynamic> buildPushNotificationMetadataAndroid() {
  return {
    'title': 'HiPush',
    'body': 'test',
    'additionalData': {
      'keyMap':
          "{\"keyMap2\":\"value2\",\"keyMap1\":\"value1\",\"keyMap4\":\"value4\"}",
      'keyMapChild':
          "{\"keyMapChild1\":\"value2\",\"keyMapChild2\":\"value3\",\"keyMapChild3\" "
              ":{\"keyMapChild32\":\"value3\",\"keyMapChild31\":\"value2\",\"keyMapChild34\":\"value4\"}}",
      'itbl': {
        "defaultAction": {"type": "openApp"},
        "isGhostPush": false,
        "messageId": "messageIdValue",
        "actionButtons": [],
        "templateId": 10
      },
      'keyNumber': 1,
      'body': 'test',
      'title': 'HiPush',
      'actionIdentifier': 'default',
      'key': 'value1'
    }
  };
}

Map<dynamic, dynamic> buildPushNotificationMetadataIOS() {
  return {
    'title': 'HiPush',
    'additionalData': {
      'keyMap': {'keyMap1': 'value1', 'keyMap2': 'value2', 'keyMap4': 'value4'},
      'itbl': {
        'messageId': 'messageValue',
        'defaultAction': {'type': 'openApp'},
        'templateId': 10,
        'actionButtons': [],
        'isGhostPush': false
      },
      'keyMapChild': {
        'keyMapChild3': {
          'keyMapChild31': 'value2',
          'keyMapChild32': 'value3',
          'keyMapChild34': 'value4'
        },
        'keyMapChild2': 'value3',
        'keyMapChild1': 'value2'
      },
      'key': 'value1',
      'aps': {
        'alert': {'title': 'HiPush', 'body': 'test'},
        'interruption-level': 'active'
      },
      'keyNumber': 1
    },
    'body': 'test'
  };
}
