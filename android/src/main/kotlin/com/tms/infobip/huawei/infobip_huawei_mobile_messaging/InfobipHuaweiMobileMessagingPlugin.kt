package com.tms.infobip.huawei.infobip_huawei_mobile_messaging

import android.app.Application
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import androidx.annotation.MainThread
import androidx.localbroadcastmanager.content.LocalBroadcastManager
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import org.infobip.mobile.messaging.Event
import org.infobip.mobile.messaging.MobileMessaging
import org.infobip.mobile.messaging.Message
import org.infobip.mobile.messaging.BroadcastParameter
import org.infobip.mobile.messaging.Installation
import org.infobip.mobile.messaging.inbox.MobileInbox
import org.infobip.mobile.messaging.inbox.MobileInboxFilterOptions
import org.infobip.mobile.messaging.inbox.Inbox
import org.infobip.mobile.messaging.inbox.InboxMessage
import org.infobip.mobile.messaging.User
import org.infobip.mobile.messaging.UserIdentity
import org.infobip.mobile.messaging.UserAttributes
import org.infobip.mobile.messaging.SuccessPending
import org.infobip.mobile.messaging.mobileapi.Result
import org.infobip.mobile.messaging.mobileapi.MobileMessagingError
import org.infobip.mobile.messaging.CustomEvent

class InfobipHuaweiMobileMessagingPlugin :
    FlutterPlugin,
    MethodChannel.MethodCallHandler,
    EventChannel.StreamHandler {

    private lateinit var methodChannel: MethodChannel
    private lateinit var tokenEvents: EventChannel
    private lateinit var messageEvents: EventChannel
    private lateinit var tapEvents: EventChannel
    private var appContext: Context? = null

    private var tokenSink: EventChannel.EventSink? = null
    private var messageSink: EventChannel.EventSink? = null
    private var tapSink: EventChannel.EventSink? = null

    private var lbm: LocalBroadcastManager? = null

    private var receiversRegistered: Boolean = false

    private val tokenReceiver = object : BroadcastReceiver() {
        override fun onReceive(context: Context?, intent: Intent?) {
            val token = intent?.getStringExtra(BroadcastParameter.EXTRA_CLOUD_TOKEN)
            tokenSink?.success(token)
        }
    }

    private val registrationReceiver = object : BroadcastReceiver() {
        override fun onReceive(context: Context?, intent: Intent?) {
            // Push Registration ID can be forwarded if you need it on Dart side:
            // val regId = intent?.getStringExtra(BroadcastParameter.EXTRA_INFOBIP_ID)
            // tokenSink?.success("REGISTRATION:$regId")
        }
    }

    private val installationReceiver = object : BroadcastReceiver() {
        override fun onReceive(context: Context?, intent: Intent?) {
            // If you need full installation payload:
            // val inst = Installation.createFrom(intent?.extras)
        }
    }

    private val messageReceiver = object : BroadcastReceiver() {
        override fun onReceive(context: Context?, intent: Intent?) {
            val msg = Message.createFrom(intent?.extras)
            // Map minimal safe fields
            val map = hashMapOf<String, Any?>(
                "messageId" to (msg.messageId ?: ""),
                "title" to msg.title,
                "body" to msg.body,
                "customPayload" to (msg.customPayload?.toString()),
                "sound" to msg.sound
            )
            messageSink?.success(map)
        }
    }

    private val notificationTappedReceiver = object : BroadcastReceiver() {
        override fun onReceive(context: Context?, intent: Intent?) {
            val msg = Message.createFrom(intent?.extras)
            val map = hashMapOf<String, Any?>(
                "messageId" to (msg.messageId ?: ""),
                "title" to msg.title,
                "body" to msg.body,
                "customPayload" to (msg.customPayload?.toString())
            )
            tapSink?.success(map)
        }
    }

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        appContext = binding.applicationContext
        methodChannel = MethodChannel(binding.binaryMessenger, "infobip_huawei_mobile_messaging/methods")
        methodChannel.setMethodCallHandler(this)

        tokenEvents = EventChannel(binding.binaryMessenger, "infobip_huawei_mobile_messaging/events/token")
        tokenEvents.setStreamHandler(object : EventChannel.StreamHandler {
            override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                tokenSink = events
            }
            override fun onCancel(arguments: Any?) {
                tokenSink = null
            }
        })

        messageEvents = EventChannel(binding.binaryMessenger, "infobip_huawei_mobile_messaging/events/message")
        messageEvents.setStreamHandler(object : EventChannel.StreamHandler {
            override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                messageSink = events
            }
            override fun onCancel(arguments: Any?) { messageSink = null }
        })

        tapEvents = EventChannel(binding.binaryMessenger, "infobip_huawei_mobile_messaging/events/notification_tap")
        tapEvents.setStreamHandler(object : EventChannel.StreamHandler {
            override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                tapSink = events
            }
            override fun onCancel(arguments: Any?) { tapSink = null }
        })

        lbm = LocalBroadcastManager.getInstance(appContext!!)
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        val ctx = appContext
        if (ctx == null) {
            result.error("no_context", "Plugin is not attached to a context.", null)
            return
        }
        when (call.method) {
            "initialize" -> {
                    ensureReceiversRegistered()
                    val ctx = appContext!!
                    val hmsAvailable = try {
                        val code = com.huawei.hms.api.HuaweiApiAvailability.getInstance()
                            .isHuaweiMobileServicesAvailable(ctx)
                        code == com.huawei.hms.api.ConnectionResult.SUCCESS
                    } catch (_: Throwable) { false }

                    if (!hmsAvailable) {
                        // Skip push init on non-HMS devices; still return success so the app runs
                        result.success(true)
                        return
                    }

                    MobileMessaging.Builder(ctx.applicationContext as Application).build()
                    result.success(true)
            }
            "getToken" -> {
                // The token is exposed via TOKEN_RECEIVED event.
                // Returning null here; clients should listen on onToken stream.
                result.success(null)
            }
            "setUserIdentity" -> {
                val externalUserId = call.argument<String>("externalUserId")
                val attributes = call.argument<Map<String, Any?>>("attributes")
                val identity = UserIdentity().apply { this.externalUserId = externalUserId }
                val userAttrs = UserAttributes() // Keep empty here; Huawei SDK UserAttributes has no generic put API
                MobileMessaging.getInstance(ctx).personalize(identity, userAttrs, object : MobileMessaging.ResultListener<User>() {
                    override fun onResult(r: Result<User, MobileMessagingError>) {
                        val err = r.error
                        if (err != null) {
                            result.error(err.code ?: "personalize_error", err.message, null)
                        } else {
                            result.success(true)
                        }
                    }
                })
            }
            "setTags" -> {
                val tags = call.argument<List<String>>("tags") ?: emptyList()
                val user = User()
                user.setTags(HashSet(tags))
                MobileMessaging.getInstance(ctx).saveUser(user, object : MobileMessaging.ResultListener<User>() {
                    override fun onResult(r: Result<User, MobileMessagingError>) {
                        val err = r.error
                        if (err != null) {
                            result.error(err.code ?: "set_tags_error", err.message, null)
                        } else {
                            result.success(true)
                        }
                    }
                })
            }
            "trackEvent" -> {
                val name = call.argument<String>("name") ?: "event"
                // NOTE: Huawei SDK expects a map of custom attributes; using an empty map for now to ensure compatibility.
                val event = CustomEvent(name, emptyMap())
                MobileMessaging.getInstance(ctx).submitEvent(event, null)
                result.success(true)
            }
            "enableInAppMessages" -> {
                val enabled = call.argument<Boolean>("enabled") ?: true
                try {
                    val mm = MobileMessaging.getInstance(ctx)
                    val m = mm::class.java.getMethod("setInAppEnabled", java.lang.Boolean.TYPE)
                    m.invoke(mm, enabled)
                    result.success(true)
                } catch (nsme: NoSuchMethodException) {
                    result.error("not_supported", "setInAppEnabled is not available in this Huawei SDK build", null)
                } catch (t: Throwable) {
                    result.error("inapp_error", t.message, null)
                }
            }

            "syncInbox" -> {
                // Fetch inbox using either JWT token + externalUserId or only externalUserId (Sandbox)
                val externalUserId = call.argument<String>("externalUserId")
                if (externalUserId.isNullOrBlank()) {
                    result.error("arg_missing", "externalUserId is required for Inbox", null)
                    return
                }
                val accessToken = call.argument<String>("accessToken") // optional JWT (Base64)

                // Optional filters
                val fromMillis = call.argument<Long>("fromDateTime")
                val toMillis = call.argument<Long>("toDateTime")
                val topic = call.argument<String>("topic")
                val topics = call.argument<List<String>>("topics")
                val limit = call.argument<Int>("limit")

                val fromDate = fromMillis?.let { java.util.Date(it) }
                val toDate = toMillis?.let { java.util.Date(it) }
                val filter: MobileInboxFilterOptions? = when {
                    topics != null -> MobileInboxFilterOptions(fromDate, toDate, topics, limit)
                    else -> MobileInboxFilterOptions(fromDate, toDate, topic, limit)
                }

                val listener = object : MobileMessaging.ResultListener<Inbox>() {
                    override fun onResult(r: Result<Inbox, MobileMessagingError>) {
                        val err = r.error
                        if (err != null) {
                            result.error(err.code ?: "inbox_error", err.message, null)
                            return
                        }
                        val inbox = r.data
                        val payload = hashMapOf<String, Any?>(
                            "countTotal" to inbox?.countTotal,
                            "countUnread" to inbox?.countUnread,
                            "countTotalFiltered" to inbox?.countTotalFiltered,
                            "countUnreadFiltered" to inbox?.countUnreadFiltered,
                            "messages" to (inbox?.messages?.map { it.toMap() } ?: emptyList<Map<String, Any?>>())
                        )
                        result.success(payload)
                    }
                }

                if (!accessToken.isNullOrBlank()) {
                    MobileInbox.getInstance(ctx).fetchInbox(accessToken, externalUserId, filter, listener)
                } else {
                    MobileInbox.getInstance(ctx).fetchInbox(externalUserId, filter, listener)
                }
            }

            "getInbox" -> {
                // Alias to syncInbox for backward compatibility
                val args = hashMapOf<String, Any?>()
                args["externalUserId"] = call.argument<String>("externalUserId")
                args["accessToken"] = call.argument<String>("accessToken")
                args["fromDateTime"] = call.argument<Long>("fromDateTime")
                args["toDateTime"] = call.argument<Long>("toDateTime")
                args["topic"] = call.argument<String>("topic")
                args["topics"] = call.argument<List<String>>("topics")
                args["limit"] = call.argument<Int>("limit")

                // Reinvoke the same path as syncInbox with the same result
                // by creating a synthetic MethodCall
                onMethodCall(MethodCall("syncInbox", args), result)
            }

            "markInboxSeen" -> {
                val externalUserId = call.argument<String>("externalUserId")
                val messageIds = call.argument<List<String>>("messageIds") ?: emptyList()
                if (externalUserId.isNullOrBlank()) {
                    result.error("arg_missing", "externalUserId is required", null)
                    return
                }
                if (messageIds.isEmpty()) {
                    result.error("arg_missing", "messageIds is required", null)
                    return
                }
                MobileInbox.getInstance(ctx).setSeen(externalUserId, messageIds.toTypedArray(),
                    object : MobileMessaging.ResultListener<Array<String>>() {
                        override fun onResult(r: Result<Array<String>, MobileMessagingError>) {
                            val err = r.error
                            if (err != null) {
                                result.error(err.code ?: "inbox_error", err.message, null)
                            } else {
                                // Return the ids which were marked seen
                                result.success(r.data?.toList())
                            }
                        }
                    })
            }

            "deleteInboxMessage" -> {
                // Not supported by Huawei Inbox client SDK. Use server API to delete.
                result.error(
                    "not_supported",
                    "Client-side delete is not available in Huawei Inbox SDK; delete via server API.",
                    null
                )
            }
            "diagnose" -> {
                val ctx = appContext!!
                val map = hashMapOf<String, Any?>()
                try {
                    val hmsAvail = com.huawei.hms.api.HuaweiApiAvailability.getInstance()
                        .isHuaweiMobileServicesAvailable(ctx)
                    map["hmsStatus"] = hmsAvail // 0 == SUCCESS
                } catch (t: Throwable) {
                    map["hmsStatus"] = -1
                    map["hmsError"] = t.message
                }
                // Check HMS Core / Huawei ID packages
                fun installed(pkg: String): Boolean = try {
                    ctx.packageManager.getPackageInfo(pkg, 0); true
                } catch (_: Exception) { false }

                map["hasHuaweiID"] = installed("com.huawei.hwid")   // Huawei ID / HMS Core
                map["hasHMS"]      = installed("com.huawei.hms")    // Some devices use this

                // Check strings
                val appId = try { ctx.getString(
                    ctx.resources.getIdentifier("app_id","string", ctx.packageName)
                ) } catch (_: Exception) { "" }
                val infobipCode = try { ctx.getString(
                    ctx.resources.getIdentifier("infobip_application_code","string", ctx.packageName)
                ) } catch (_: Exception) { "" }
                map["appIdPresent"] = appId.isNotEmpty()
                map["infobipCodePresent"] = infobipCode.isNotEmpty()

                result.success(map)
            }
            else -> result.notImplemented()
        }
    }
    private fun InboxMessage.toMap(): Map<String, Any?> = hashMapOf(
        "messageId" to messageId,
        "title" to title,
        "body" to body,
        "receivedTimestamp" to (sentTimestamp ?: 0L),
        "customPayload" to customPayload?.toString(),
        "topic" to topic,
        "seen" to isSeen
    )
    @MainThread
    private fun ensureReceiversRegistered() {
        val ctx = appContext ?: return
        val mgr = lbm ?: return
        if (receiversRegistered) return
        // Subscribe to core library events (per Library events wiki)
        mgr.registerReceiver(tokenReceiver, IntentFilter(Event.TOKEN_RECEIVED.key))
        mgr.registerReceiver(registrationReceiver, IntentFilter(Event.REGISTRATION_CREATED.key))
        mgr.registerReceiver(installationReceiver, IntentFilter(Event.INSTALLATION_UPDATED.key))
        mgr.registerReceiver(messageReceiver, IntentFilter(Event.MESSAGE_RECEIVED.key))
        mgr.registerReceiver(notificationTappedReceiver, IntentFilter(Event.NOTIFICATION_TAPPED.key))
        receiversRegistered = true
    }
    @MainThread
    private fun unregisterReceivers() {
        val manager = lbm ?: return
        if (!receiversRegistered) return
        try { manager.unregisterReceiver(tokenReceiver) } catch (_: Exception) {}
        try { manager.unregisterReceiver(registrationReceiver) } catch (_: Exception) {}
        try { manager.unregisterReceiver(installationReceiver) } catch (_: Exception) {}
        try { manager.unregisterReceiver(messageReceiver) } catch (_: Exception) {}
        try { manager.unregisterReceiver(notificationTappedReceiver) } catch (_: Exception) {}
        receiversRegistered = false
    }

    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) { /* not used */ }
    override fun onCancel(arguments: Any?) { /* not used */ }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        methodChannel.setMethodCallHandler(null)
        unregisterReceivers()
        tokenSink = null; messageSink = null; tapSink = null
        appContext = null
        lbm = null
    }
}