package com.nitroiosalarmkit

import com.margelo.nitro.core.Promise

data class CustomizableAlarmButton(
    val text: String,
    val textColor: String,
    val icon: String
)

data class AlarmCountdown(
    val preAlert: Double?,
    val postAlert: Double?
)

enum class AlarmWeekday {
    monday,
    tuesday,
    wednesday,
    thursday,
    friday,
    saturday,
    sunday
}

class HybridNitroIosAlarmKit : HybridNitroIosAlarmKitSpec() {

    override fun isAvailable(): Boolean {
        // AlarmKit is iOS 26+ only
        return false
    }

    override fun requestAlarmPermission(): Promise<Boolean> {
        // No-op on Android - AlarmKit is iOS 26+ only
        return Promise.resolved(false)
    }

    override fun scheduleFixedAlarm(
        title: String,
        stopBtn: CustomizableAlarmButton,
        tintColor: String,
        secondaryBtn: CustomizableAlarmButton?,
        timestamp: Double?,
        countdown: AlarmCountdown?
    ): Promise<Boolean> {
        // No-op on Android - AlarmKit is iOS 26+ only
        return Promise.resolved(false)
    }

    override fun scheduleRelativeAlarm(
        title: String,
        stopBtn: CustomizableAlarmButton,
        tintColor: String,
        hour: Double,
        minute: Double,
        repeats: List<AlarmWeekday>,
        secondaryBtn: CustomizableAlarmButton?,
        countdown: AlarmCountdown?
    ): Promise<Boolean> {
        // No-op on Android - AlarmKit is iOS 26+ only
        return Promise.resolved(false)
    }
}