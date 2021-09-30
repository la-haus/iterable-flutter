package com.lahaus.iterable_flutter

import org.junit.Test
import org.junit.Assert.*
import org.junit.Before

class NotificationParserTest {

  private lateinit var notificationParser: NotificationParser
  private lateinit var  testMap:Map<String, Any?>

  @Before
  fun setup(){
    notificationParser = NotificationParser()
    testMap = MockData().getMapTest()
  }

  @Test
  fun`parser function returns first node of the map the title of the push`() {

    val result = notificationParser.parse(testMap);

    assertEquals(result["title"], "IterableFlutterExamplePush")
  }

  @Test
  fun`parser function returns in additionalData node of the map`() {

    val result = notificationParser.parse(testMap);

    val mapData = result["additionalData"] as Map<String, Any?>

    assertEquals(mapData["type"], "test")
    assertEquals(mapData["name"], "Santi")
  }

  @Test
  fun`parser function returns map  whit values of integer type`() {

    val result = notificationParser.parse(testMap);

    val mapData = result["additionalData"] as Map<String, Any?>

    assertEquals(mapData["real_estate_id"], 344427)
  }
}