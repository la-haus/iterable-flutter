package com.lahaus.iterable_flutter

import java.util.HashMap

class NotificationParser {

  fun parse(dataPush: Map<String, Any?>): Map<String, Any?> {

    val mapPushData = getAllFormatInt(dataPush)
    return buildSendPushMap(mapPushData)
  }

  private fun getAllFormatInt(dataPush: Map<String, Any?>): Map<String, Any?> {
    val map: MutableMap<String, Any?> = HashMap()
    for ((key, value) in dataPush) {
      if (value is String) {
        if (value.toIntOrNull() != null) {
          val newValueInt: Int = value.toInt();
          map[key] = newValueInt;
        } else {
          map[key] = value;
        }
      }

    }
    return map;
  }

  private fun buildSendPushMap(mapPushData: Map<String, Any?>): Map<String, Any?> {
    return mapOf(
      "title" to mapPushData["title"],
      "body" to mapPushData["body"],
      "additionalData" to mapPushData
    )
  }

}
