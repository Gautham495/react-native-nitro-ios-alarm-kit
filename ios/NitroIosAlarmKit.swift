import NitroModules
import AlarmKit

class HybridNitroIosAlarmKit: HybridNitroIosAlarmKitSpec {
    
    public func isAvailable() throws -> Bool {
        if #available(iOS 26.0, *) {
            return true
        }
        return false
    }
    
    public func requestAlarmPermission() throws -> NitroModules.Promise<Bool> {
        return NitroModules.Promise.async {
            #if canImport(AlarmKit)
            if #available(iOS 26.0, *) {
                let manager = AlarmManager.shared
                do {
                    let state = try await manager.requestAuthorization()
                    return state == .authorized
                } catch {
                    print("Error in requestAuthorization: \(error)")
                    throw error
                }
            }
            #endif
            return false
        }
    }
    
    public func scheduleFixedAlarm(
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
                    textColor: Color(self.hexToColor(hex: stopBtn.textColor)),
                    systemImageName: stopBtn.icon
                )
                
                let alertPresentationAlert: AlarmPresentation.Alert
                
                if let btn = secondaryBtn {
                    let secondaryButton = AlarmButton(
                        text: LocalizedStringResource(stringLiteral: btn.text),
                        textColor: Color(self.hexToColor(hex: btn.textColor)),
                        systemImageName: btn.icon
                    )
                    
                    alertPresentationAlert = AlarmPresentation.Alert(
                        title: LocalizedStringResource(stringLiteral: title),
                        stopButton: stopButton,
                        secondaryButton: secondaryButton,
                        secondaryButtonBehavior: .countdown
                    )
                } else {
                    alertPresentationAlert = AlarmPresentation.Alert(
                        title: LocalizedStringResource(stringLiteral: title),
                        stopButton: stopButton
                    )
                }
                
                let presentation = AlarmPresentation(alert: alertPresentationAlert)
                let countdownDuration = Alarm.CountdownDuration(
                    preAlert: countdown?.preAlert,
                    postAlert: countdown?.postAlert
                )
                
                nonisolated struct EmptyMetadata: AlarmMetadata {}
                let attributes = AlarmAttributes<EmptyMetadata>(
                    presentation: presentation,
                    tintColor: Color(self.hexToColor(hex: tintColor))
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
                
                let uuid = UUID()
                do {
                    _ = try await manager.schedule(id: uuid, configuration: configuration)
                    return true
                } catch {
                    throw error
                }
            }
            #endif
            return false
        }
    }
    
    public func scheduleRelativeAlarm(
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
                    textColor: Color(self.hexToColor(hex: stopBtn.textColor)),
                    systemImageName: stopBtn.icon
                )
                
                let alertPresentationAlert: AlarmPresentation.Alert
                
                if let btn = secondaryBtn {
                    let secondaryButton = AlarmButton(
                        text: LocalizedStringResource(stringLiteral: btn.text),
                        textColor: Color(self.hexToColor(hex: btn.textColor)),
                        systemImageName: btn.icon
                    )
                    
                    alertPresentationAlert = AlarmPresentation.Alert(
                        title: LocalizedStringResource(stringLiteral: title),
                        stopButton: stopButton,
                        secondaryButton: secondaryButton,
                        secondaryButtonBehavior: .countdown
                    )
                } else {
                    alertPresentationAlert = AlarmPresentation.Alert(
                        title: LocalizedStringResource(stringLiteral: title),
                        stopButton: stopButton
                    )
                }
                
                let presentation = AlarmPresentation(alert: alertPresentationAlert)
                let countdownDuration = Alarm.CountdownDuration(
                    preAlert: countdown?.preAlert,
                    postAlert: countdown?.postAlert
                )
                
                nonisolated struct EmptyMetadata: AlarmMetadata {}
                let attributes = AlarmAttributes<EmptyMetadata>(
                    presentation: presentation,
                    tintColor: Color(self.hexToColor(hex: tintColor))
                )
                
                let time = Alarm.Schedule.Relative.Time(hour: Int(hour), minute: Int(minute))
                
                let localeWeekdays: [Locale.Weekday] = repeats.map { alarmWeekday in
                    switch alarmWeekday {
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
                let relativeSchedule = Alarm.Schedule.Relative(time: time, repeats: recurrence)
                let schedule = Alarm.Schedule.relative(relativeSchedule)
                
                let configuration = AlarmManager.AlarmConfiguration(
                    countdownDuration: countdownDuration,
                    schedule: schedule,
                    attributes: attributes,
                    sound: .default
                )
                
                let uuid = UUID()
                do {
                    _ = try await manager.schedule(id: uuid, configuration: configuration)
                    return true
                } catch {
                    throw error
                }
            }
            #endif
            return false
        }
    }
    
    // MARK: - Helper
    
    private func hexToColor(hex: String) -> UIColor {
        var cString: String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        if cString.hasPrefix("#") {
            cString.remove(at: cString.startIndex)
        }
        
        if cString.count != 6 {
            return UIColor.gray
        }
        
        var rgbValue: UInt64 = 0
        Scanner(string: cString).scanHexInt64(&rgbValue)
        
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
}