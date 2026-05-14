import Foundation
import NitroModules
import AlarmKit
import ActivityKit
import SwiftUI

// MARK: - Metadata (must be at file level, nonisolated for Swift 6 concurrency)
nonisolated struct AlarmMetadataInfo: AlarmMetadata {
    init() {}
}

class NitroIosAlarmKit: HybridNitroIosAlarmKitSpec {

    // MARK: - Availability

    func isAvailable() throws -> Bool {
        if #available(iOS 26.0, *) {
            return true
        }
        return false
    }

    // MARK: - Permissions

    func requestAlarmPermission() throws -> NitroModules.Promise<Bool> {
        return NitroModules.Promise.async {
            #if canImport(AlarmKit)
            if #available(iOS 26.0, *) {
                let manager = AlarmManager.shared
                do {
                    let state = try await manager.requestAuthorization()
                    return state == .authorized
                } catch {
                    print("❌ AlarmKit authorization error: \(error)")
                    throw error
                }
            }
            #endif
            return false
        }
    }

// MARK: - Stop All Alarms

func stopAllAlarms() throws -> NitroModules.Promise<Bool> {
    return NitroModules.Promise.async {
        #if canImport(AlarmKit)
        if #available(iOS 26.0, *) {
            let manager = AlarmManager.shared
            
            do {
                let alarms = try manager.alarms
                var successCount = 0

                for alarm in alarms {
                    do {
                        // Stop if firing, cancel if scheduled
                        if case .alerting = alarm.state {
                            try manager.stop(id: alarm.id)
                            print("⏹️ Stopped firing alarm: \(alarm.id)")
                        } else {
                            try manager.cancel(id: alarm.id)
                            print("🗑️ Cancelled alarm: \(alarm.id)")
                        }
                        successCount += 1
                    } catch {
                        print("⚠️ Failed to handle alarm \(alarm.id): \(error)")
                    }
                }

                print("✅ Handled \(successCount)/\(alarms.count) alarms")
                return successCount > 0 || alarms.isEmpty
            } catch {
                print("❌ Failed to get alarms: \(error)")
                throw error
            }
        }
        #endif
        return false
    }
}

// MARK: - Stop Single Alarm by ID

func stopAlarm(alarmId: String) throws -> NitroModules.Promise<Bool> {
    return NitroModules.Promise.async {
        #if canImport(AlarmKit)
        if #available(iOS 26.0, *) {
            let manager = AlarmManager.shared

            guard let uuid = UUID(uuidString: alarmId) else {
                print("❌ Invalid alarm ID format: \(alarmId)")
                return false
            }

            do {
                // Find the alarm to check its state
                let alarms = try manager.alarms
                let targetAlarm = alarms.first { $0.id == uuid }

                if let alarm = targetAlarm, case .alerting = alarm.state {
                    // Alarm is currently firing - stop it
                    try manager.stop(id: uuid)
                    print("⏹️ Stopped firing alarm: \(uuid)")
                } else {
                    // Alarm is scheduled - cancel it
                    try manager.cancel(id: uuid)
                    print("🗑️ Cancelled alarm: \(uuid)")
                }
                return true
            } catch {
                print("❌ Failed to stop alarm \(alarmId): \(error)")
                throw error
            }
        }
        #endif
        return false
    }
}

    // MARK: - Fixed Alarm (returns alarm ID)

    func scheduleFixedAlarm(
        title: String,
        stopBtn: CustomizableAlarmButton,
        tintColor: String,
        secondaryBtn: CustomizableAlarmButton?,
        timestamp: Double?,
        countdown: AlarmCountdown?,
        soundName: String?
    ) throws -> NitroModules.Promise<String> {
        return NitroModules.Promise.async {
            #if canImport(AlarmKit)
            if #available(iOS 26.0, *) {
                let manager = AlarmManager.shared

                let stopButton = AlarmButton(
                    text: LocalizedStringResource(stringLiteral: stopBtn.text),
                    textColor: self.hexToColor(hex: stopBtn.textColor),
                    systemImageName: stopBtn.icon ?? "checkmark.circle.fill"
                )

                let alert: AlarmPresentation.Alert

                if let btn = secondaryBtn {
                    let secondaryButton = AlarmButton(
                        text: LocalizedStringResource(stringLiteral: btn.text),
                        textColor: self.hexToColor(hex: btn.textColor),
                        systemImageName: btn.icon ?? "repeat.circle.fill"
                    )

                    alert = AlarmPresentation.Alert(
                        title: LocalizedStringResource(stringLiteral: title),
                        stopButton: stopButton,
                        secondaryButton: secondaryButton,
                        secondaryButtonBehavior: .countdown
                    )
                } else {
                    alert = AlarmPresentation.Alert(
                        title: LocalizedStringResource(stringLiteral: title),
                        stopButton: stopButton
                    )
                }

                let presentation = AlarmPresentation(alert: alert)

                let countdownDuration = Alarm.CountdownDuration(
                    preAlert: countdown?.preAlert.flatMap { $0 > 0 ? TimeInterval($0) : nil },
                    postAlert: countdown?.postAlert.flatMap { $0 > 0 ? TimeInterval($0) : nil }
                )

                let attributes = AlarmAttributes<AlarmMetadataInfo>(
                    presentation: presentation,
                    tintColor: self.hexToColor(hex: tintColor)
                )

                var schedule: Alarm.Schedule? = nil

                if let timestamp = timestamp {
                    let date = Date(timeIntervalSince1970: timestamp)
                    schedule = Alarm.Schedule.fixed(date)
                }

                let sound = self.buildSound(soundName: soundName)

                let configuration = AlarmManager.AlarmConfiguration(
                    countdownDuration: countdownDuration,
                    schedule: schedule,
                    attributes: attributes,
                    sound: sound
                )

                do {
                    let alarmId = UUID()
                    let _ = try await manager.schedule(
                        id: alarmId,
                        configuration: configuration
                    )
                    print("✅ Fixed alarm scheduled: \(alarmId)")
                    return alarmId.uuidString
                } catch {
                    print("❌ Fixed alarm failed: \(error)")
                    throw error
                }
            }
            #endif
            return ""
        }
    }

    // MARK: - Relative Alarm (returns alarm ID)

    func scheduleRelativeAlarm(
        title: String,
        stopBtn: CustomizableAlarmButton,
        tintColor: String,
        hour: Double,
        minute: Double,
        repeats: [AlarmWeekday],
        secondaryBtn: CustomizableAlarmButton?,
        countdown: AlarmCountdown?,
        soundName: String?
    ) throws -> NitroModules.Promise<String> {
        return NitroModules.Promise.async {
            #if canImport(AlarmKit)
            if #available(iOS 26.0, *) {
                let manager = AlarmManager.shared

                let stopButton = AlarmButton(
                    text: LocalizedStringResource(stringLiteral: stopBtn.text),
                    textColor: self.hexToColor(hex: stopBtn.textColor),
                    systemImageName: stopBtn.icon ?? "checkmark.circle.fill"
                )

                let alert: AlarmPresentation.Alert

                if let btn = secondaryBtn {
                    let secondaryButton = AlarmButton(
                        text: LocalizedStringResource(stringLiteral: btn.text),
                        textColor: self.hexToColor(hex: btn.textColor),
                        systemImageName: btn.icon ?? "repeat.circle.fill"
                    )

                    alert = AlarmPresentation.Alert(
                        title: LocalizedStringResource(stringLiteral: title),
                        stopButton: stopButton,
                        secondaryButton: secondaryButton,
                        secondaryButtonBehavior: .countdown
                    )
                } else {
                    alert = AlarmPresentation.Alert(
                        title: LocalizedStringResource(stringLiteral: title),
                        stopButton: stopButton
                    )
                }

                let presentation = AlarmPresentation(alert: alert)

                let countdownDuration = Alarm.CountdownDuration(
                    preAlert: countdown?.preAlert.flatMap { $0 > 0 ? TimeInterval($0) : nil },
                    postAlert: countdown?.postAlert.flatMap { $0 > 0 ? TimeInterval($0) : nil }
                )

                let attributes = AlarmAttributes<AlarmMetadataInfo>(
                    presentation: presentation,
                    tintColor: self.hexToColor(hex: tintColor)
                )

                let time = Alarm.Schedule.Relative.Time(
                    hour: Int(hour),
                    minute: Int(minute)
                )

                let localeWeekdays: [Locale.Weekday] = repeats.map {
                    switch $0 {
                    case .monday: return .monday
                    case .tuesday: return .tuesday
                    case .wednesday: return .wednesday
                    case .thursday: return .thursday
                    case .friday: return .friday
                    case .saturday: return .saturday
                    case .sunday: return .sunday
                    }
                }

                let recurrence = Alarm.Schedule.Relative.Recurrence.weekly(localeWeekdays)
                let relativeSchedule = Alarm.Schedule.Relative(
                    time: time,
                    repeats: recurrence
                )

                let sound = self.buildSound(soundName: soundName)

                let configuration = AlarmManager.AlarmConfiguration(
                    countdownDuration: countdownDuration,
                    schedule: .relative(relativeSchedule),
                    attributes: attributes,
                    sound: sound
                )

                do {
                    let alarmId = UUID()
                    let _ = try await manager.schedule(
                        id: alarmId,
                        configuration: configuration
                    )
                    print("✅ Relative alarm scheduled: \(alarmId)")
                    return alarmId.uuidString
                } catch {
                    print("❌ Relative alarm failed: \(error)")
                    throw error
                }
            }
            #endif
            return ""
        }
    }

    // MARK: - Timer (returns alarm ID)

    func scheduleTimer(
        title: String,
        stopBtn: CustomizableAlarmButton,
        tintColor: String,
        durationSeconds: Double,
        secondaryBtn: CustomizableAlarmButton?,
        soundName: String?
    ) throws -> NitroModules.Promise<String> {
        return NitroModules.Promise.async {
            #if canImport(AlarmKit)
            if #available(iOS 26.0, *) {
                let manager = AlarmManager.shared

                let stopButton = AlarmButton(
                    text: LocalizedStringResource(stringLiteral: stopBtn.text),
                    textColor: self.hexToColor(hex: stopBtn.textColor),
                    systemImageName: stopBtn.icon ?? "checkmark.circle.fill"
                )

                let alert: AlarmPresentation.Alert

                if let btn = secondaryBtn {
                    let secondaryButton = AlarmButton(
                        text: LocalizedStringResource(stringLiteral: btn.text),
                        textColor: self.hexToColor(hex: btn.textColor),
                        systemImageName: btn.icon ?? "repeat.circle.fill"
                    )

                    alert = AlarmPresentation.Alert(
                        title: LocalizedStringResource(stringLiteral: title),
                        stopButton: stopButton,
                        secondaryButton: secondaryButton,
                        secondaryButtonBehavior: .countdown
                    )
                } else {
                    alert = AlarmPresentation.Alert(
                        title: LocalizedStringResource(stringLiteral: title),
                        stopButton: stopButton
                    )
                }

                let presentation = AlarmPresentation(alert: alert)

                let attributes = AlarmAttributes<AlarmMetadataInfo>(
                    presentation: presentation,
                    tintColor: self.hexToColor(hex: tintColor)
                )

                let sound = self.buildSound(soundName: soundName)

                let configuration = AlarmManager.AlarmConfiguration.timer(
                    duration: TimeInterval(durationSeconds),
                    attributes: attributes,
                    sound: sound
                )

                do {
                    let alarmId = UUID()
                    let _ = try await manager.schedule(
                        id: alarmId,
                        configuration: configuration
                    )
                    print("✅ Timer scheduled: \(alarmId)")
                    return alarmId.uuidString
                } catch {
                    print("❌ Timer failed: \(error)")
                    throw error
                }
            }
            #endif
            return ""
        }
    }

    // MARK: - Progressive Bells (returns array of alarm IDs)

    func scheduleProgressiveBells(
        title: String,
        stopBtn: CustomizableAlarmButton,
        tintColor: String,
        baseTimestamp: Double,
        intervalSeconds: Double,
        secondaryBtn: CustomizableAlarmButton?,
        soundName: String?
    ) throws -> NitroModules.Promise<[String]> {
        return NitroModules.Promise.async {
            #if canImport(AlarmKit)
            if #available(iOS 26.0, *) {
                let manager = AlarmManager.shared

                // Progressive pattern: +1, +2, +3, -1, -2, -3 (relative to interval)
                let offsets: [Double] = [1, 2, 3, -1, -2, -3]

                let stopButton = AlarmButton(
                    text: LocalizedStringResource(stringLiteral: stopBtn.text),
                    textColor: self.hexToColor(hex: stopBtn.textColor),
                    systemImageName: stopBtn.icon ?? "checkmark.circle.fill"
                )

                let alert: AlarmPresentation.Alert

                if let btn = secondaryBtn {
                    let secondaryButton = AlarmButton(
                        text: LocalizedStringResource(stringLiteral: btn.text),
                        textColor: self.hexToColor(hex: btn.textColor),
                        systemImageName: btn.icon ?? "repeat.circle.fill"
                    )

                    alert = AlarmPresentation.Alert(
                        title: LocalizedStringResource(stringLiteral: title),
                        stopButton: stopButton,
                        secondaryButton: secondaryButton,
                        secondaryButtonBehavior: .countdown
                    )
                } else {
                    alert = AlarmPresentation.Alert(
                        title: LocalizedStringResource(stringLiteral: title),
                        stopButton: stopButton
                    )
                }

                let presentation = AlarmPresentation(alert: alert)

                let attributes = AlarmAttributes<AlarmMetadataInfo>(
                    presentation: presentation,
                    tintColor: self.hexToColor(hex: tintColor)
                )

                let sound = self.buildSound(soundName: soundName)

                var scheduledIds: [String] = []

                for (index, offset) in offsets.enumerated() {
                    // Calculate bell time: base + (offset * interval)
                    let bellTimestamp = baseTimestamp + (offset * intervalSeconds)
                    let bellDate = Date(timeIntervalSince1970: bellTimestamp)

                    // Skip if in the past
                    guard bellDate > Date() else {
                        print("⏭️ Skipping past bell at offset \(offset)")
                        continue
                    }

                    let schedule = Alarm.Schedule.fixed(bellDate)

                    let configuration = AlarmManager.AlarmConfiguration(
                        countdownDuration: nil,
                        schedule: schedule,
                        attributes: attributes,
                        sound: sound
                    )

                    do {
                        let alarmId = UUID()
                        let _ = try await manager.schedule(
                            id: alarmId,
                            configuration: configuration
                        )
                        print("🔔 Bell \(index + 1) scheduled at offset \(offset): \(alarmId)")
                        scheduledIds.append(alarmId.uuidString)
                    } catch {
                        print("❌ Bell \(index + 1) failed: \(error)")
                    }
                }

                print("✅ Progressive bells scheduled: \(scheduledIds.count)/\(offsets.count)")
                return scheduledIds
            }
            #endif
            return []
        }
    }

    // MARK: - Auto-Stop Alarm v2 (stops after N rings)

func scheduleAutoStopAlarm(
    title: String,
    stopBtn: CustomizableAlarmButton,
    tintColor: String,
    ringCount: Double,
    ringDurationSeconds: Double?,
    secondaryBtn: CustomizableAlarmButton?,
    timestamp: Double?,
    countdown: AlarmCountdown?,
    soundName: String?
) throws -> NitroModules.Promise<String> {
    return NitroModules.Promise.async {
        #if canImport(AlarmKit)
        if #available(iOS 26.0, *) {
            let manager = AlarmManager.shared

            let stopButton = AlarmButton(
                text: LocalizedStringResource(stringLiteral: stopBtn.text),
                textColor: self.hexToColor(hex: stopBtn.textColor),
                systemImageName: stopBtn.icon ?? "checkmark.circle.fill"
            )

            let alert: AlarmPresentation.Alert

            if let btn = secondaryBtn {
                let secondaryButton = AlarmButton(
                    text: LocalizedStringResource(stringLiteral: btn.text),
                    textColor: self.hexToColor(hex: btn.textColor),
                    systemImageName: btn.icon ?? "repeat.circle.fill"
                )

                alert = AlarmPresentation.Alert(
                    title: LocalizedStringResource(stringLiteral: title),
                    stopButton: stopButton,
                    secondaryButton: secondaryButton,
                    secondaryButtonBehavior: .countdown
                )
            } else {
                alert = AlarmPresentation.Alert(
                    title: LocalizedStringResource(stringLiteral: title),
                    stopButton: stopButton
                )
            }

            let presentation = AlarmPresentation(alert: alert)

            let countdownDuration = Alarm.CountdownDuration(
                preAlert: countdown?.preAlert.flatMap { $0 > 0 ? TimeInterval($0) : nil },
                postAlert: countdown?.postAlert.flatMap { $0 > 0 ? TimeInterval($0) : nil }
            )

            let attributes = AlarmAttributes<AlarmMetadataInfo>(
                presentation: presentation,
                tintColor: self.hexToColor(hex: tintColor)
            )

            var schedule: Alarm.Schedule? = nil

            if let timestamp = timestamp {
                let date = Date(timeIntervalSince1970: timestamp)
                schedule = Alarm.Schedule.fixed(date)
            }

            let sound = self.buildSound(soundName: soundName)

            let configuration = AlarmManager.AlarmConfiguration(
                countdownDuration: countdownDuration,
                schedule: schedule,
                attributes: attributes,
                sound: sound
            )

            do {
                let alarmId = UUID()
                let _ = try await manager.schedule(
                    id: alarmId,
                    configuration: configuration
                )
                print("✅ Auto-stop alarm scheduled: \(alarmId)")

                // Auto-stop after ringCount * ringDuration
                let perRing = ringDurationSeconds ?? 5.0
                let clampedCount = max(1.0, min(ringCount, 10.0))
                let totalDuration = clampedCount * perRing

                Task {
                    try? await Task.sleep(nanoseconds: UInt64(totalDuration * 1_000_000_000))

                    // Only stop if still alerting
                    let alarms = try? manager.alarms
                    let stillFiring = alarms?.first { $0.id == alarmId && {
                        if case .alerting = $0.state { return true }
                        return false
                    }() }

                    if stillFiring != nil {
                        try? manager.stop(id: alarmId)
                        print("🔕 Auto-stopped alarm after \(Int(clampedCount)) rings: \(alarmId)")
                    }
                }

                return alarmId.uuidString
            } catch {
                print("❌ Auto-stop alarm failed: \(error)")
                throw error
            }
        }
        #endif
        return ""
    }
}

    // MARK: - Helpers

    private func buildSound(soundName: String?) -> ActivityKit.AlertConfiguration.AlertSound {
        if let name = soundName, !name.isEmpty {
            return ActivityKit.AlertConfiguration.AlertSound.named(name)
        } else {
            return ActivityKit.AlertConfiguration.AlertSound.default
        }
    }

    private func hexToColor(hex: String) -> Color {
        var hexString = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexString = hexString.replacingOccurrences(of: "#", with: "")

        if hexString.count == 3 {
            hexString = hexString.map { "\($0)\($0)" }.joined()
        }

        guard hexString.count == 6 else {
            return Color.blue
        }

        var rgbValue: UInt64 = 0
        Scanner(string: hexString).scanHexInt64(&rgbValue)

        return Color(
            red: Double((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: Double((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: Double(rgbValue & 0x0000FF) / 255.0
        )
    }
}