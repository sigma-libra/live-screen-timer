package libra.sigma.live_screen_timer

import android.app.*
import android.content.*
import android.os.*
import android.content.pm.ServiceInfo
import androidx.core.app.NotificationCompat

class ScreenTimerService : Service() {

    private val CHANNEL_ID = "screen_timer_channel"
    private val NOTIFICATION_ID = 1

    private var sessionStartElapsed: Long = 0
    private val handler = Handler(Looper.getMainLooper())

    private val updateRunnable = object : Runnable {
        override fun run() {
            updateNotification()
            handler.postDelayed(this, 1000)
        }
    }

    private val screenReceiver = object : BroadcastReceiver() {
        override fun onReceive(context: Context, intent: Intent) {
            when (intent.action) {
                Intent.ACTION_USER_PRESENT -> {
                    // Screen unlocked: show fresh notification and start counting from 0
                    sessionStartElapsed = SystemClock.elapsedRealtime()
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                        startForeground(NOTIFICATION_ID, buildNotification("0h 0m 0s"), ServiceInfo.FOREGROUND_SERVICE_TYPE_SPECIAL_USE)
                    } else {
                        startForeground(NOTIFICATION_ID, buildNotification("0h 0m 0s"))
                    }
                    handler.post(updateRunnable)
                }
                Intent.ACTION_SCREEN_OFF -> {
                    // Screen off: stop counting but keep foreground to prevent Android from killing the service
                    handler.removeCallbacks(updateRunnable)
                    val manager = getSystemService(NOTIFICATION_SERVICE) as NotificationManager
                    manager.notify(NOTIFICATION_ID, buildNotification("Screen off"))
                }
            }
        }
    }

    override fun onCreate() {
        super.onCreate()
        createNotificationChannel()

        // Must register dynamically — SCREEN_OFF is not deliverable to manifest receivers
        val filter = IntentFilter().apply {
            addAction(Intent.ACTION_USER_PRESENT)
            addAction(Intent.ACTION_SCREEN_OFF)
        }
        registerReceiver(screenReceiver, filter)
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        sessionStartElapsed = SystemClock.elapsedRealtime()

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            startForeground(NOTIFICATION_ID, buildNotification("0h 0m 0s"), ServiceInfo.FOREGROUND_SERVICE_TYPE_SPECIAL_USE)
        } else {
            startForeground(NOTIFICATION_ID, buildNotification("0h 0m 0s"))
        }

        handler.post(updateRunnable)
        return START_STICKY
    }

    override fun onDestroy() {
        super.onDestroy()
        handler.removeCallbacks(updateRunnable)
        try { unregisterReceiver(screenReceiver) } catch (_: Exception) {}
    }

    override fun onBind(intent: Intent?) = null

    private fun updateNotification() {
        val elapsed = (SystemClock.elapsedRealtime() - sessionStartElapsed) / 1000
        val hours = elapsed / 3600
        val minutes = (elapsed % 3600) / 60
        val seconds = elapsed % 60
        val timeText = "${hours}h ${minutes}m ${seconds}s"
        val manager = getSystemService(NOTIFICATION_SERVICE) as NotificationManager
        manager.notify(NOTIFICATION_ID, buildNotification(timeText))
    }

    private fun buildNotification(text: String): Notification {
        return NotificationCompat.Builder(this, CHANNEL_ID)
            .setContentTitle("ScreenTime")
            .setContentText(text)
            .setSmallIcon(android.R.drawable.ic_lock_idle_alarm)
            .setOngoing(true)
            .setOnlyAlertOnce(true)
            .setSilent(true)
            .build()
    }

    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                CHANNEL_ID,
                "Screen Timer",
                NotificationManager.IMPORTANCE_LOW
            ).apply {
                setSound(null, null)
                enableVibration(false)
            }
            (getSystemService(NOTIFICATION_SERVICE) as NotificationManager)
                .createNotificationChannel(channel)
        }
    }
}
