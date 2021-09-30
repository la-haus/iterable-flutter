package com.lahaus.iterable_flutter

import org.json.JSONArray
import org.json.JSONObject
import org.json.JSONTokener

class MockData {

  fun getMapTest() :  Map<String, Any>{
    val json = """
    {
      "body": "IterableFlutterExamplePushContents",
      "itbl": {
      "defaultAction": {
      "type": "openApp"
    },
      "isGhostPush": false,
      "messageId": "c3d5233fab1c448abd27cfc5d6661239",
      "actionButtons": [

      ],
      "templateId": 3758351
    },
      "name": "Santi",
      "type": "test",
      "real_estate_id": "344427",
      "title": "IterableFlutterExamplePush"
    }
    """

    return  jsonStringToBundle(json)

  }

  fun jsonStringToBundle(jsonString: String):  Map<String, Any> {

      val jsonObject = toJsonObject(jsonString)
      return toMap(jsonObject)

  }

  fun toJsonObject(jsonString: String?): JSONObject {

    val jsonObject = JSONTokener(jsonString).nextValue() as JSONObject

    return jsonObject
  }

  fun toMap(jsonobj: JSONObject): Map<String, Any> {
    val map: MutableMap<String, Any> = HashMap()
    val keys = jsonobj.keys()
    while (keys.hasNext()) {
      val key = keys.next()
      var value = jsonobj[key]
      if (value is JSONArray) {
        value = toList(value as JSONArray)
      } else if (value is JSONObject) {
        value = toMap(value)
      }
      map[key] = value
    }
    return map
  }


  fun toList(array: JSONArray): List<Any> {
    val list: MutableList<Any> = ArrayList()
    for (i in 0 until array.length()) {
      var value: Any = array.get(i)
      if (value is JSONArray) {
        value = toList(value as JSONArray)
      } else if (value is JSONObject) {
        value = toMap(value)
      }
      list.add(value)
    }
    return list
  }

}