package com.lahaus.iterable_flutter

import android.util.Log
import io.flutter.BuildConfig

/**
 * Created by alex on 21/11/22.
 */
object LogUtils {
    var enabled: Boolean = true
    fun debug(message: String, tag: String = "IterableFlutterPlugin") {
        if (BuildConfig.DEBUG && enabled) {
            Log.d(tag, message);
        }
    }
}