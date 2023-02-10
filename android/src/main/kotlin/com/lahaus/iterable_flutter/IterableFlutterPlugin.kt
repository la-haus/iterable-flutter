package com.lahaus.iterable_flutter

import android.content.Context
import android.os.Bundle
import android.os.Debug
import android.util.Log
import androidx.annotation.NonNull
import com.google.android.gms.tasks.OnCompleteListener
import com.google.firebase.messaging.*
import com.iterable.iterableapi.*
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import org.json.JSONObject
import java.util.*


/** IterableFlutterPlugin */
class IterableFlutterPlugin : FlutterPlugin, MethodCallHandler {

  private val methodChannelName = "iterable_flutter"

  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  private lateinit var channel: MethodChannel

  private lateinit var context: Context

  override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    context = flutterPluginBinding.applicationContext

    channel = MethodChannel(flutterPluginBinding.binaryMessenger, methodChannelName)
    channel.setMethodCallHandler(this)

  }

  override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {

    when (call.method) {
      "initialize" -> {
        val apiKey = call.argument<String>("apiKey") ?: ""
        val pushIntegrationName = call.argument<String>("pushIntegrationName") ?: ""
        val activeLogDebug = call.argument<Boolean>("activeLogDebug") ?: false

        if (apiKey.isNotEmpty() && pushIntegrationName.isNotEmpty()) {
          initialize(apiKey, pushIntegrationName, activeLogDebug)
        }
        result.success(null)
      }
      "setEmail" -> {
        val userEmail = call.argument<String>("email") ?: ""
        val jwt = call.argument<String>("jwt") ?: ""
        IterableApi.getInstance().setEmail(userEmail, jwt)
        result.success(null)
      }
      "setUserId" -> {
        val userId = call.argument<String>("userId") ?: ""
        val jwt = call.argument<String>("jwt") ?: ""
        IterableApi.getInstance().setUserId(userId, jwt)
        result.success(null)
      }
      "updateEmail" -> {
        val userEmail = call.argument<String>("email") ?: ""
        val jwt = call.argument<String>("jwt") ?: ""
        IterableApi.getInstance().updateEmail(userEmail, jwt)
        result.success(null)
      }
      "track" -> {
        val argumentData = call.arguments as? Map<*, *>
        
        val event = argumentData?.get("event") as String
        val dataFields = argumentData["dataFields"] as? Map<*, *>
        dataFields?.let { data ->
          val dataJson = JSONObject(data)
          IterableApi.getInstance().track(event, dataJson)
        } ?: kotlin.run {
          IterableApi.getInstance().track(event)
        }

        result.success(null)
      }
      "registerForPush" -> {
        IterableApi.getInstance().registerForPush()
        result.success(null)
      }
      "signOut" -> {
        IterableApi.getInstance().disablePush()
        result.success(null)
      }
      "checkRecentNotification" -> {
        notifyPushNotificationOpened()
        result.success(null)
      }
      "updateUser" -> {
        var userInfo = call.argument<Map<String, Any>?>("params")
        IterableApi.getInstance().updateUser(JSONObject(userInfo))
        result.success(null)
      }
      else -> {
        result.notImplemented()
      }
    }
  }

  private fun initialize(apiKey: String, pushIntegrationName: String, activeLogDebug: Boolean) {
    val configBuilder = IterableConfig.Builder()
      .setPushIntegrationName(pushIntegrationName)
      .setAutoPushRegistration(true)
      .setCustomActionHandler { _, _ ->
        notifyPushNotificationOpened()
        false
      }

    if (activeLogDebug) {
      configBuilder.setLogLevel(Log.DEBUG)
    }

    IterableApi.initialize(context, apiKey, configBuilder.build())
  }

  override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
  }

  private fun notifyPushNotificationOpened() {
    val bundleData = IterableApi.getInstance().payloadData

    bundleData?.let {
      val pushData = clearPushData(it)
      channel.invokeMethod("openedNotificationHandler", pushData)
    }
  }

  private fun clearPushData(bundleData: Bundle): Map<String, Any?> {

    val mapPushData = bundleToMap(bundleData)
    return NotificationParser().parse(mapPushData)
  }

  private fun bundleToMap(extras: Bundle): Map<String, Any?> {

    val map: MutableMap<String, Any?> = HashMap()
    val keySetValue = extras.keySet()
    val iterator: Iterator<String> = keySetValue.iterator()
    while (iterator.hasNext()) {
      val key = iterator.next()
      map[key] = extras[key]
    }

    return map
  }
}
