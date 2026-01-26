import Foundation
import NitroModules
import AlarmKit
import SwiftUI

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
                    throw error
                }
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
        countdown: AlarmCountdown?
    ) throws -> NitroModules.Promise<Bool> {
        return NitroModules.Promise.async {
            #if canImport(AlarmKit)
            if #available(iOS 26.0, *) {
                let manager = AlarmManager.shared

                let stopButton = AlarmButton(
                    text: LocalizedStringResource(stringLiteral: stopBtn.text),
                    textColor: self.hexToColor(hex: stopBtn.textColor),
                    systemImageName: stopBtn.icon ?? "alarm"
                )

                let alert: AlarmPresentation.Alert

                if let btn = secondaryBtn {
                    let secondaryButton = AlarmButton(
                        text: LocalizedStringResource(stringLiteral: btn.text),
                        textColor: self.hexToColor(hex: btn.textColor),
                        systemImageName: btn.icon ?? "bell"
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
                    preAlert: countdown?.preAlert,
                    postAlert: countdown?.postAlert
                )

                nonisolated struct EmptyMetadata: AlarmMetadata {}

                let attributes = AlarmAttributes<EmptyMetadata>(
                    presentation: presentation,
                    tintColor: self.hexToColor(hex: tintColor)
                )

                var schedule: Alarm.Schedule? = nil

                if let timestamp = timestamp {
                    let date = Date(timeIntervalSince1970: timestamp)
                    schedule = Alarm.Schedule.fixed(date)
                }

                let configuration = AlarmManager.AlarmConfiguration(
                    countdownDuration: countdownDuration,
                    schedule: schedule,
                    attributes: attributes,
                    sound: .default
                )

                do {
                    _ = try await manager.schedule(
                        id: UUID(),
                        configuration: configuration
                    )
                    return true
                } catch {
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
        countdown: AlarmCountdown?
    ) throws -> NitroModules.Promise<Bool> {
        return NitroModules.Promise.async {
            #if canImport(AlarmKit)
            if #available(iOS 26.0, *) {
                let manager = AlarmManager.shared

                let stopButton = AlarmButton(
                    text: LocalizedStringResource(stringLiteral: stopBtn.text),
                    textColor: self.hexToColor(hex: stopBtn.textColor),
                    systemImageName: stopBtn.icon ?? "alarm"
                )

                let alert: AlarmPresentation.Alert

                if let btn = secondaryBtn {
                    let secondaryButton = AlarmButton(
                        text: LocalizedStringResource(stringLiteral: btn.text),
                        textColor: self.hexToColor(hex: btn.textColor),
                        systemImageName: btn.icon ?? "bell"
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
                    preAlert: countdown?.preAlert,
                    postAlert: countdown?.postAlert
                )

                nonisolated struct EmptyMetadata: AlarmMetadata {}

                let attributes = AlarmAttributes<EmptyMetadata>(
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

                let configuration = AlarmManager.AlarmConfiguration(
                    countdownDuration: countdownDuration,
                    schedule: .relative(relativeSchedule),
                    attributes: attributes,
                    sound: .default
                )

                do {
                    _ = try await manager.schedule(
                        id: UUID(),
                        configuration: configuration
                    )
                    return true
                } catch {
                    throw error
                }
            }
            #endif
            return false
        }
    }

    // MARK: - Helpers

    private func hexToColor(hex: String) -> Color {
        var hexString = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexString = hexString.replacingOccurrences(of: "#", with: "")

        guard hexString.count == 6 else {
            return Color.gray
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
