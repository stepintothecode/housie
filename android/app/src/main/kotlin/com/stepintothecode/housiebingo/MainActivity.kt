package com.stepintothecode.housiebingo

import android.os.Bundle
import android.view.WindowManager
import io.flutter.embedding.android.FlutterActivity

class MainActivity : FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        // Ask for a seamless rotation instead of the default one.
        //
        // By default Android takes a screenshot of the old orientation and
        // rotates and stretches it while the app re-lays-out. This app builds
        // a genuinely different layout sideways, so that stretched frame looks
        // wrong rather than merely blurry.
        //
        // SEAMLESS skips the animation when the app can redraw in time, and
        // the platform falls back to the normal rotation when it cannot, so
        // this is safe on slower handsets.
        window.attributes = window.attributes.apply {
            rotationAnimation = WindowManager.LayoutParams.ROTATION_ANIMATION_SEAMLESS
        }
    }
}
