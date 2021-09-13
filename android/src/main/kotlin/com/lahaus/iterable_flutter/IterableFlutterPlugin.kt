package com.lahaus.iterable_flutter

import android.content.Context
import android.os.Bundle
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

        if (apiKey.isNotEmpty() && pushIntegrationName.isNotEmpty()) {
          initialize(apiKey, pushIntegrationName)
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
      else -> {
        result.notImplemented()
      }
    }
  }

  private fun initialize(apiKey: String, pushIntegrationName: String) {
    val config = IterableConfig.Builder()
        .setLogLevel(Log.DEBUG)
        .setPushIntegrationName(pushIntegrationName)
        .setAutoPushRegistration(false)
        .setCustomActionHandler { _ , _ ->
          notifyPushNotificationOpened()
          true
        }
        .build()
    IterableApi.initialize(context, apiKey, config)

    FirebaseMessaging.getInstance().token
        .addOnCompleteListener(OnCompleteListener { task ->
          if (!task.isSuccessful) {
            Log.e("initialize error >>>", "Fetching FCM registration token failed", task.exception)
            return@OnCompleteListener
          }

          // Get new FCM registration token
          val token = task.result

          Log.e("initialize token >>>", "Fetching FCM registration token $token")
        })
  }

  private fun notifyPushNotificationOpened(){
    val bundleData = IterableApi.getInstance().payloadData
    channel.invokeMethod("openedNotificationHandler", bundleToMap(bundleData))
  }

  fun bundleToMap(extras: Bundle?): Map<String, String?> {
    return extras?.let { bundle ->
      val map: MutableMap<String, String?> = HashMap()
      val keySetValue = bundle.keySet()
      val iterator: Iterator<String> = keySetValue.iterator()
      while (iterator.hasNext()) {
        val key = iterator.next()
        map[key] = bundle.getString(key)
      }
      return map
    }?: run {
      return mapOf()
    }

  }

  override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
  }
}
