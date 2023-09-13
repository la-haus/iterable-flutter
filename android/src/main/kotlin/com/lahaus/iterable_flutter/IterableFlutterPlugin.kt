package com.lahaus.iterable_flutter

import android.app.Activity
import android.app.Application
import android.content.Context
import android.content.Intent
import android.os.Bundle
import android.util.Log
import androidx.fragment.app.FragmentActivity
import com.google.gson.Gson
import com.iterable.iterableapi.*
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry.NewIntentListener
import org.json.JSONException
import org.json.JSONObject
import java.util.regex.Pattern


/** IterableFlutterPlugin */
class IterableFlutterPlugin : FlutterPlugin, MethodCallHandler, ActivityAware, NewIntentListener,
    Application.ActivityLifecycleCallbacks {

    private val methodChannelName = "iterable_flutter"

    /// The MethodChannel that will the communication between Flutter and native Android
    ///
    /// This local reference serves to register the plugin with the Flutter Engine and unregister it
    /// when the Flutter Engine is detached from the Activity
    private lateinit var channel: MethodChannel

    private var context: Context? = null
    private var activity: Activity? = null
    private var activityPluginBinding: ActivityPluginBinding? = null

    // IterableAPI crashes when processing an appLink without being initialized
    // persist the appLink here and handle after Iterable has ben initialized
    private var isInitialized: Boolean = false
    private var pendingAppLinkUrl: String? = null

    // Hold reference to MobileInboxActivity to dismiss when handling actions
    private var mobileInboxActivity: MobileInboxActivity? = null

    // region FlutterPlugin
    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        context = flutterPluginBinding.applicationContext

        channel = MethodChannel(flutterPluginBinding.binaryMessenger, methodChannelName)
        channel.setMethodCallHandler(this)

    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
        activityPluginBinding = null
        activity = null
        context = null
    }
    // endregion

    // region MethodCallHandler
    override fun onMethodCall(call: MethodCall, result: Result) {

        when (call.method) {
            "initialize" -> {
                val apiKey = call.argument<String>("apiKey") ?: ""
                val pushIntegrationName = call.argument<String>("pushIntegrationName") ?: ""
                val activeLogDebug = call.argument<Boolean>("activeLogDebug") ?: false
                val allowedProtocols =
                    call.argument<List<String>>("allowedProtocols") ?: emptyList()

                if (apiKey.isNotEmpty() && pushIntegrationName.isNotEmpty()) {
                    initialize(apiKey, pushIntegrationName, activeLogDebug, allowedProtocols)
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
                val userInfo = call.argument<Map<String, Any>?>("params")
                IterableApi.getInstance().updateUser(JSONObject(userInfo))
                result.success(null)
            }

            "showMobileInbox" -> {
                val screenTitle = call.argument<String>("screenTitle")
                val noMessagesTitle = call.argument<String>("noMessagesTitle")
                val noMessagesBody = call.argument<String>("noMessagesBody")
                activity?.let { context ->
                    val intent = Intent(context, MobileInboxActivity::class.java).apply {
                        screenTitle?.let { putExtra("activityTitle", it) }
                        noMessagesTitle?.let { putExtra("noMessagesTitle", it) }
                        noMessagesBody?.let { putExtra("noMessagesBody", it) }
                    }
                    context.startActivity(intent)
                }
                result.success(null)
            }

            "getUnreadInboxMessagesCount" -> {
                result.success(IterableApi.getInstance().inAppManager.unreadInboxMessagesCount)
            }

            "getInboxMessages" -> {
                val messages = IterableApi.getInstance().inAppManager.inboxMessages
                val messagesJson = messages.map {it.toMessagePreviewJsonObject().toString() }
                result.success(messagesJson)
            }

            "showInboxMessage" -> {
                // Mandatory "messageId" parameter
                val messageId = call.argument<String>("messageId")
                // Find message from inbox
                val message = IterableApi.getInstance().inAppManager.inboxMessages.firstOrNull {
                    it.messageId == messageId
                }
                // Show message
                message?.let {
                    IterableApi.getInstance().inAppManager.showMessage(
                        message,
                        false,
                        { _ -> result.success(true)},
                        IterableInAppLocation.IN_APP,
                    )
                } ?: run {
                    result.success(false)
                }
            }

            "dismissPresentedInboxMessage" -> {
                val fragment = (activity as? FragmentActivity)?.supportFragmentManager?.fragments?.firstOrNull { it is IterableInAppFragmentHTMLNotification }
                (activity as? FragmentActivity)?.supportFragmentManager?.beginTransaction()?.remove(fragment!!)?.commitAllowingStateLoss()
            }

            else -> {
                result.notImplemented()
            }
        }
    }

    private fun initialize(
        apiKey: String,
        pushIntegrationName: String,
        activeLogDebug: Boolean,
        allowedProtocols: List<String>
    ) {
        val configBuilder = IterableConfig.Builder()
            .setPushIntegrationName(pushIntegrationName)
            .setAutoPushRegistration(false)
//            .setUseInMemoryStorageForInApps(true)
            .setInAppHandler {
                IterableInAppHandler.InAppResponse.SHOW
            }
            .setAllowedProtocols(allowedProtocols.toTypedArray())
            .setUrlHandler { _, context ->
                notifyIterableAction(context)
                true
            }
            .setCustomActionHandler { _, context ->
                notifyIterableAction(context)
                true
            }

        if (activeLogDebug) {
            configBuilder.setLogLevel(Log.DEBUG)
        }
        LogUtils.enabled = activeLogDebug

        context?.let { IterableApi.initialize(it, apiKey, configBuilder.build()) }

        // Maybe handle pending app link
        isInitialized = true
        pendingAppLinkUrl?.let { IterableApi.getInstance().handleAppLink(it) }
    }

    private fun notifyIterableAction(context: IterableActionContext) {
        val source: String = when (context.source) {
            IterableActionSource.PUSH -> {
                if (IterableApi.getInstance().payloadData != null) {
                    return notifyPushNotificationOpened()
                } else {
                    "push"
                }
            }

            IterableActionSource.APP_LINK -> "appLink"
            IterableActionSource.IN_APP -> "inApp"
        }
        val actionData = mapOf(
            "itbl" to mapOf(
                "defaultAction" to mapOf(
                    "type" to context.action.type,
                    "data" to context.action.data
                )
            ),
            "source" to source,
        )

        // Maybe dismiss mobile inbox
        mobileInboxActivity?.finish()

        LogUtils.debug("notifyIterableAction with data $actionData")
        channel.invokeMethod("actionHandler", actionData)
    }

    // region Push
    private fun notifyPushNotificationOpened() {
        val bundleData = IterableApi.getInstance().payloadData
        bundleData?.let {
            val pushData = bundleToMap(it).toMutableMap()
            pushData["source"] = "push"
            LogUtils.debug("notifyPushNotificationOpened with data $pushData")
            channel.invokeMethod("actionHandler", pushData)
        }
    }

    private fun bundleToMap(extras: Bundle): Map<String, Any?> {

        val map: MutableMap<String, Any?> = HashMap()
        val keySetValue = extras.keySet()
        val iterator: Iterator<String> = keySetValue.iterator()
        while (iterator.hasNext()) {
            val key = iterator.next()
            val value = extras.get(key)
            if (value is Bundle) {
                map[key] = bundleToMap(value)
            } else {
                map[key] = value
            }
        }

        return map
    }
    // endregion

    // region AppLinks
    private fun handleIntent(intent: Intent?): Boolean {
        // Check intent contains an Iterable AppLink
        if (intent == null) return false
        if (intent.action != Intent.ACTION_VIEW) return false
        val url = intent.dataString ?: return false
        if (!isIterableDeeplink(url)) return false
        LogUtils.debug("handleIntent with Iterable deeplink $url")
        // Overwrite the intent to make sure we don't open the deep link
        // again when the user opens our app later from the task manager
        activity?.intent = Intent(Intent.ACTION_MAIN)
        // Handle app link in Iterable's Url Handler
        return if (isInitialized) {
            return IterableApi.getInstance().handleAppLink(url)
        } else {
            pendingAppLinkUrl = url
            true
        }
    }

    private fun isIterableDeeplink(url: String): Boolean {
        val deeplinkPattern = Pattern.compile(IterableConstants.ITBL_DEEPLINK_IDENTIFIER)
        val m = deeplinkPattern.matcher(url)
        if (m.find()) {
            return true
        }
        return false
    }

    // region ActivityAware: handle Intent for App Links
    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        LogUtils.debug("onAttachedToActivity called: ${binding.activity}")
        binding.activity.let {
            this.activity = it
            it.application.registerActivityLifecycleCallbacks(this)
            if (it is FlutterFragmentActivity) {
                handleIntent(it.intent)
            }
        }
        activityPluginBinding = binding
        activityPluginBinding?.addOnNewIntentListener(this)
    }

    override fun onDetachedFromActivity() {
        LogUtils.debug("onDetachedFromActivity called")
        activityPluginBinding?.removeOnNewIntentListener(this)
        this.activity?.application?.unregisterActivityLifecycleCallbacks(this)
        this.activity = null
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) =
        onAttachedToActivity(binding)

    override fun onDetachedFromActivityForConfigChanges() = onDetachedFromActivity()
    // endregion

    // region NewIntentListener: handle Intent for App Links
    override fun onNewIntent(intent: Intent): Boolean = handleIntent(intent)
    // endregion

    // region Application.ActivityLifecycleCallbacks:
    // - handle Intent for App Links
    // - dismiss mobile inbox to handle url/actions
    override fun onActivityCreated(activity: Activity, savedInstanceState: Bundle?) {
        LogUtils.debug("onActivityCreated called: $activity")
        handleIntent(activity.intent)
        if (activity is MobileInboxActivity) {
            mobileInboxActivity = activity
        }
    }

    override fun onActivityStarted(activity: Activity) {
        // Do nothing
    }

    override fun onActivityResumed(activity: Activity) {
        // Do nothing
    }

    override fun onActivityPaused(activity: Activity) {
        // Do nothing
    }

    override fun onActivityStopped(activity: Activity) {
        // Do nothing
    }

    override fun onActivitySaveInstanceState(activity: Activity, outState: Bundle) {
        // Do nothing
    }

    override fun onActivityDestroyed(activity: Activity) {
        LogUtils.debug("onActivityDestroyed called: $activity")
        if (activity is MobileInboxActivity) {
            mobileInboxActivity = null
        }
    }
    // endregion
    // endregion

    // region InAppMessage

    fun IterableInAppMessage.InboxMetadata.toJsonObject(): JSONObject {
        val inboxMetadataJson = JSONObject()

        try {
            inboxMetadataJson.putOpt(IterableConstants.ITERABLE_IN_APP_INBOX_TITLE, this.title)
            inboxMetadataJson.putOpt(
                IterableConstants.ITERABLE_IN_APP_INBOX_SUBTITLE,
                this.subtitle
            )
            inboxMetadataJson.putOpt(IterableConstants.ITERABLE_IN_APP_INBOX_ICON, this.icon)
        } catch (e: JSONException) {
            IterableLogger.e("Error while serializing inbox metadata", e.toString())
        }
        return inboxMetadataJson;
    }

    fun IterableInAppMessage.toMessagePreviewJsonObject(): JSONObject {

        val messageJson = JSONObject()

        try {
            messageJson.putOpt(IterableConstants.KEY_MESSAGE_ID, messageId)

            if (createdAt != null) {
                messageJson.putOpt(
                    IterableConstants.ITERABLE_IN_APP_CREATED_AT,
                    createdAt.time
                )
            }
            if (expiresAt != null) {
                messageJson.putOpt(
                    IterableConstants.ITERABLE_IN_APP_EXPIRES_AT,
                    expiresAt.time
                )
            }

            if (inboxMetadata != null) {
                messageJson.putOpt(
                    IterableConstants.ITERABLE_IN_APP_INBOX_METADATA,
                    inboxMetadata!!.toJsonObject()
                )
            }

            messageJson.putOpt(IterableConstants.ITERABLE_IN_APP_READ, this.isRead);

        } catch (e: JSONException) {

            IterableLogger.e("Error while serializing an in-app message", e.toString())
        }
        return messageJson
    }

    // endregion
}



