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
                    let alarms = await manager.alarms
                    for alarm in alarms {
                        try await manager.delete(id: alarm.id)
                        print("🗑️ Deleted alarm: \(alarm.id)")
                    }
                    print("✅ All alarms stopped")
                    return true
                } catch {
                    print("❌ Failed to stop alarms: \(error)")
                    throw error
                }
            }
            #endif
            return false
        }
    }

    // MARK: - Progressive Bell Pattern
    // Pattern: t+1, t+2, t+3, t-1, t-2, t-3, loop
    // Each offset is in seconds from base time

    func scheduleProgressiveBells(
        title: String,
        stopBtn: CustomizableAlarmButton,
        tintColor: String,
        baseTimestamp: Double,
        intervalSeconds: Double,
        secondaryBtn: CustomizableAlarmButton?,
        soundName: String?
    ) throws -> NitroModules.Promise<Bool> {
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

                var scheduledCount = 0

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
                        let alarmId = try await manager.schedule(
                            id: UUID(),
                            configuration: configuration
                        )
                        print("🔔 Bell \(index + 1) scheduled at offset \(offset): \(alarmId)")
                        scheduledCount += 1
                    } catch {
                        print("❌ Bell \(index + 1) failed: \(error)")
                    }
                }

                print("✅ Progressive bells scheduled: \(scheduledCount)/\(offsets.count)")
                return scheduledCount > 0
            }
            #endif
            return false
        }
    }

    // MARK: - Fixed Alarm

    func scheduleFixedAlarm(
        title: String,
        stopBtn: CustomizableAlarmButton,
        tintColor: String,
        secondaryBtn: CustomizableAlarmButton?,
        timestamp: Double?,
        countdown: AlarmCountdown?,
        soundName: String?
    ) throws -> NitroModules.Promise<Bool> {
        return NitroModules.Promise.async {
            #if canImport(AlarmKit)
            if #available(iOS 26.0, *) {
                let manager = AlarmManager.shared

                // Build stop button with better default icon
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

                // Build countdown duration - use nil for 0 values
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

                // Build sound - use custom sound if provided
                let sound = self.buildSound(soundName: soundName)

                let configuration = AlarmManager.AlarmConfiguration(
                    countdownDuration: countdownDuration,
                    schedule: schedule,
                    attributes: attributes,
                    sound: sound
                )

                do {
                    let alarmId = try await manager.schedule(
                        id: UUID(),
                        configuration: configuration
                    )
                    print("✅ Fixed alarm scheduled: \(alarmId)")
                    return true
                } catch {
                    print("❌ Fixed alarm failed: \(error)")
                    throw error
                }
            }
            #endif
            return false
        }
    }

    // MARK: - Relative Alarm

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
    ) throws -> NitroModules.Promise<Bool> {
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
                    let alarmId = try await manager.schedule(
                        id: UUID(),
                        configuration: configuration
                    )
                    print("✅ Relative alarm scheduled: \(alarmId)")
                    return true
                } catch {
                    print("❌ Relative alarm failed: \(error)")
                    throw error
                }
            }
            #endif
            return false
        }
    }

    // MARK: - Timer

    func scheduleTimer(
        title: String,
        stopBtn: CustomizableAlarmButton,
        tintColor: String,
        durationSeconds: Double,
        secondaryBtn: CustomizableAlarmButton?,
        soundName: String?
    ) throws -> NitroModules.Promise<Bool> {
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
                    let alarmId = try await manager.schedule(
                        id: UUID(),
                        configuration: configuration
                    )
                    print("✅ Timer scheduled: \(alarmId)")
                    return true
                } catch {
                    print("❌ Timer failed: \(error)")
                    throw error
                }
            }
            #endif
            return false
        }
    }

    // MARK: - Helpers

    /// Build sound configuration
    /// - Parameter soundName: Name of sound file WITHOUT extension (e.g., "magic" for "magic.wav")
    ///                        Sound file must be in app's main bundle
    ///                        Pass nil for default system alarm sound
    private func buildSound(soundName: String?) -> ActivityKit.AlertConfiguration.AlertSound {
        if let name = soundName, !name.isEmpty {
            // Custom sound - file must be in main bundle
            return ActivityKit.AlertConfiguration.AlertSound.named(name)
        } else {
            // Default system sound
            return ActivityKit.AlertConfiguration.AlertSound.default
        }
    }

    private func hexToColor(hex: String) -> Color {
        var hexString = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexString = hexString.replacingOccurrences(of: "#", with: "")

        // Handle 3-character hex
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