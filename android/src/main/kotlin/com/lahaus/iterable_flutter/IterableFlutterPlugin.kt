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
        val userEmail = call.arguments as String
        IterableApi.getInstance().setEmail(userEmail)
        IterableApi.getInstance().registerForPush()
        result.success(null)
      }
      "setUserId" -> {
        IterableApi.getInstance().setUserId(call.arguments as String)
        IterableApi.getInstance().registerForPush()
        result.success(null)
      }
      "track" -> {
        IterableApi.getInstance().track(call.arguments as String)
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
      }
      else -> {
        result.notImplemented()
      }
    }
  }

  private fun initialize(apiKey: String, pushIntegrationName: String, activeLogDebug: Boolean) {
    val configBuilder = IterableConfig.Builder()
      .setPushIntegrationName(pushIntegrationName)
      .setAutoPushRegistration(false)
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
