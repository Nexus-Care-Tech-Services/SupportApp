
package com.example.support

import android.content.Context
import android.hardware.Sensor
import android.hardware.SensorEvent
import android.hardware.SensorEventListener
import android.hardware.SensorManager
import android.os.PowerManager
import android.os.Handler

class ScreenControlHandler(private val context: Context) : SensorEventListener {
    private val sensorManager: SensorManager =
            context.getSystemService(Context.SENSOR_SERVICE) as SensorManager
    private val proximitySensor: Sensor? =
            sensorManager.getDefaultSensor(Sensor.TYPE_PROXIMITY)
    private val powerManager: PowerManager =
            context.getSystemService(Context.POWER_SERVICE) as PowerManager
    private val wakeLock: PowerManager.WakeLock? =
            powerManager.newWakeLock(PowerManager.PROXIMITY_SCREEN_OFF_WAKE_LOCK, "ScreenControlHandler:WakeLock")
    private val handler = Handler()
    private var screenOffRunnable: Runnable? = null

    private val SCREEN_OFF_DELAY_MS = 500L // Delay in milliseconds before turning the screen off

    fun registerSensor() {
        sensorManager.registerListener(
                this, proximitySensor, SensorManager.SENSOR_DELAY_NORMAL
        )
    }

    fun unregisterSensor() {
        proximitySensor?.let {
            sensorManager.unregisterListener(this, it)
            cancelScreenOffRunnable()
        }
    }

    private fun turnScreenOn() {
        if (!wakeLock?.isHeld!!) {
            wakeLock.acquire()
        }
        cancelScreenOffRunnable()
    }

    private fun turnScreenOff() {
        if (wakeLock?.isHeld!!) {
            wakeLock.release()
        }
        scheduleScreenOffRunnable()
    }

    private fun scheduleScreenOffRunnable() {
        cancelScreenOffRunnable()
        val runnable = Runnable { turnScreenOn() }
        screenOffRunnable = runnable
        handler.postDelayed(runnable, SCREEN_OFF_DELAY_MS)
    }

    private fun cancelScreenOffRunnable() {
        val runnable = screenOffRunnable
        if (runnable != null) {
            handler.removeCallbacks(runnable)
            screenOffRunnable = null
        }
    }

    override fun onSensorChanged(event: SensorEvent) {
        if (event.sensor.type == Sensor.TYPE_PROXIMITY) {
            val proximityValue = event.values[0]
            val maximumRange = proximitySensor?.maximumRange ?: 0f
            if (proximityValue < maximumRange) {
                turnScreenOff()
            } else {
                turnScreenOn()
            }
        }
    }

    override fun onAccuracyChanged(sensor: Sensor?, accuracy: Int) {
        // Not used in this example
    }
}
