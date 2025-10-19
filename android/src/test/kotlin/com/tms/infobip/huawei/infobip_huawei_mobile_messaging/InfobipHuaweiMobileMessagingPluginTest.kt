package com.tms.infobip.huawei.infobip_huawei_mobile_messaging

import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import org.junit.Test
import org.mockito.Mockito

/**
 * Unit tests for the Kotlin bridge of the plugin.
 *
 * These tests avoid calling methods that require HMS/engine context (like "initialize"),
 * and instead verify behavior for methods that don't depend on a bound context.
 */
internal class InfobipHuaweiMobileMessagingPluginTest {

    @Test
    fun onMethodCall_getToken_returnsNull() {
        val plugin = InfobipHuaweiMobileMessagingPlugin()
        val call = MethodCall("getToken", null)
        val mockResult: MethodChannel.Result = Mockito.mock(MethodChannel.Result::class.java)

        plugin.onMethodCall(call, mockResult)

        // Our implementation returns success(null) and relies on the token stream for updates.
        Mockito.verify(mockResult).success(null)
        Mockito.verifyNoMoreInteractions(mockResult)
    }

    @Test
    fun onMethodCall_unknownMethod_resultsInNotImplemented() {
        val plugin = InfobipHuaweiMobileMessagingPlugin()
        val call = MethodCall("unknownMethod", null)
        val mockResult: MethodChannel.Result = Mockito.mock(MethodChannel.Result::class.java)

        plugin.onMethodCall(call, mockResult)

        Mockito.verify(mockResult).notImplemented()
        Mockito.verifyNoMoreInteractions(mockResult)
    }
}
