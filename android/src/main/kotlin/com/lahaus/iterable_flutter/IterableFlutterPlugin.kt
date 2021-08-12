package com.lahaus.iterable_flutter

import android.content.Context
import android.util.Log
import androidx.annotation.NonNull
import com.iterable.iterableapi.IterableApi
import com.iterable.iterableapi.IterableConfig
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result


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
        IterableApi.getInstance().setEmail(call.arguments as String)
        result.success(null)
      }
      "setUserId" -> {
        IterableApi.getInstance().setUserId(call.arguments as String)
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
      else -> {
        result.notImplemented()
      }
    }
  }

  private fun initialize(apiKey: String, pushIntegrationName: String) {
    val config = IterableConfig.Builder()
        .setLogLevel(Log.DEBUG)
        .setPushIntegrationName(pushIntegrationName)
        .setAutoPushRegistration(true)
        .build()
    IterableApi.initialize(context, apiKey, config)
  }

  override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
  }
}
