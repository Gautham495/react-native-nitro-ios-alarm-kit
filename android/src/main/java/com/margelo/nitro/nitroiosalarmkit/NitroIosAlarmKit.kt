package com.margelo.nitro.nitroiosalarmkit

import com.facebook.proguard.annotations.DoNotStrip
import com.margelo.nitro.core.Promise

@DoNotStrip
class HybridNitroIosAlarmKit : HybridNitroIosAlarmKitSpec() {

    override fun isAvailable(): Boolean {
        return false
    }

    override fun requestAlarmPermission(): Promise<Boolean> {
        return Promise.resolved(false)
    }

    override fun stopAllAlarms(): Promise<Boolean> {
        return Promise.resolved(false)
    }

    override fun stopAlarm(alarmId: String): Promise<Boolean> {
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
    ): Promise<String?> {
        return Promise.resolved(null)
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
    ): Promise<String?> {
        return Promise.resolved(null)
    }

    override fun scheduleTimer(
        title: String,
        stopBtn: CustomizableAlarmButton,
        tintColor: String,
        durationSeconds: Double,
        secondaryBtn: CustomizableAlarmButton?,
        soundName: String?
    ): Promise<String?> {
        return Promise.resolved(null)
    }

    override fun scheduleProgressiveBells(
        title: String,
        stopBtn: CustomizableAlarmButton,
        tintColor: String,
        baseTimestamp: Double,
        intervalSeconds: Double,
        secondaryBtn: CustomizableAlarmButton?,
        soundName: String?
    ): Promise<Array<String>> {
        return Promise.resolved(emptyArray())
    }
}