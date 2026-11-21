package com.makeshtech.clock

import android.os.Bundle
import android.os.Handler
import android.os.Looper
import androidx.core.view.WindowCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import kotlin.system.exitProcess

class MainActivity : FlutterActivity() {
    companion object {
        private const val EXIT_CHANNEL = "android_app_exit"
        private const val SEND_TO_BACKGROUND_METHOD = "sendToBackground"
        private const val PROCESS_EXIT_DELAY_MS = 1000L
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        WindowCompat.setDecorFitsSystemWindows(window, false)
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, EXIT_CHANNEL)
            .setMethodCallHandler { call, result ->
                if (call.method == SEND_TO_BACKGROUND_METHOD) {
                    finishAndRemoveTask()
                    result.success(null)
                    Handler(Looper.getMainLooper()).postDelayed(
                        { exitProcess(0) },
                        PROCESS_EXIT_DELAY_MS,
                    )
                } else {
                    result.notImplemented()
                }
            }
    }
}
