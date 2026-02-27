package com.margelo.nitro.nitroiosalarmkit

import com.facebook.proguard.annotations.DoNotStrip
import com.margelo.nitro.core.Promise

@DoNotStrip
class HybridNitroIosAlarmKit : HybridNitroIosAlarmKitSpec() {

    override fun isAvailable(): Boolean {
        // AlarmKit is iOS-only
        return false
    }

    override fun requestAlarmPermission(): Promise<Boolean> {
        // No-op on Android
        return Promise.resolved(false)
    }

    override fun stopAllAlarms(): Promise<Boolean> {
        // No-op on Android
        return Promise.resolved(false)
    }

    override fun scheduleProgressiveBells(
        title: String,
        stopBtn: CustomizableAlarmButton,
        tintColor: String,
        baseTimestamp: Double,
        intervalSeconds: Double,
        secondaryBtn: CustomizableAlarmButton?,
        soundName: String?
    ): Promise<Boolean> {
        // No-op on Android
        return Promise.resolved(false)
    }

    override fun scheduleFixedAlarm(
        title: String,
        stopBtn: CustomizableAlarmButton,
        tintColor: String,
        secondaryBtn: CustomizableAlarmButton?,
        timestamp: Double?,
        countdown: AlarmCountdown?,
        soundName: String?
    ): Promise<Boolean> {
        // No-op on Android
        return Promise.resolved(false)
    }

    override fun scheduleRelativeAlarm(
        title: String,
        stopBtn: CustomizableAlarmButton,
        tintColor: String,
        hour: Double,
        minute: Double,
        repeats: Array<AlarmWeekday>,
        secondaryBtn: CustomizableAlarmButton?,
        countdown: AlarmCountdown?,
        soundName: String?
    ): Promise<Boolean> {
        // No-op on Android
        return Promise.resolved(false)
    }

    override fun scheduleTimer(
        title: String,
        stopBtn: CustomizableAlarmButton,
        tintColor: String,
        durationSeconds: Double,
        secondaryBtn: CustomizableAlarmButton?,
        soundName: String?
    ): Promise<Boolean> {
        // No-op on Android
        return Promise.resolved(false)
    }
}