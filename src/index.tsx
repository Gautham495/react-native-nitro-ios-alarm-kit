import { NitroModules } from 'react-native-nitro-modules';
import type {
  NitroIosAlarmKit,
  CustomizableAlarmButton,
  AlarmCountdown,
  AlarmWeekday,
} from './NitroIosAlarmKit.nitro';

export type {
  NitroIosAlarmKit,
  CustomizableAlarmButton,
  AlarmCountdown,
  AlarmWeekday,
};

const NitroIosAlarmKitHybridObject =
  NitroModules.createHybridObject<NitroIosAlarmKit>('NitroIosAlarmKit');

/**
 * Check if AlarmKit is available (iOS 26+ only)
 */
export function isAvailable(): boolean {
  return NitroIosAlarmKitHybridObject.isAvailable();
}

/**
 * Request permission to schedule alarms
 * @returns true if authorized, false otherwise
 */
export function requestAlarmPermission(): Promise<boolean> {
  return NitroIosAlarmKitHybridObject.requestAlarmPermission();
}

/**
 * Stop and delete all scheduled alarms
 * @returns true if successful
 */
export function stopAllAlarms(): Promise<boolean> {
  return NitroIosAlarmKitHybridObject.stopAllAlarms();
}

/**
 * Schedule progressive bells with pattern: t+1, t+2, t+3, t-1, t-2, t-3
 * Useful for meditation bells that ring before and after the main time
 *
 * @param title - Bell title (keep under 15 chars for Dynamic Island)
 * @param stopBtn - Stop button configuration
 * @param tintColor - Hex color for alarm UI (e.g., "#FF6B6B")
 * @param baseTimestamp - Base Unix timestamp in seconds (the "t" reference point)
 * @param intervalSeconds - Interval between bells in seconds
 * @param secondaryBtn - Optional secondary button
 * @param soundName - Custom sound file name without extension
 *
 * @example
 * // Schedule bells around a 10-minute meditation at 8:00 AM
 * // With 60-second intervals: bells at 8:01, 8:02, 8:03, 7:59, 7:58, 7:57
 * scheduleProgressiveBells(
 *   "Meditation",
 *   { text: "Done", textColor: "#FFFFFF" },
 *   "#6B4EFF",
 *   Date.now() / 1000 + 600, // 10 mins from now
 *   60 // 1 minute interval
 * );
 */
export function scheduleProgressiveBells(
  title: string,
  stopBtn: CustomizableAlarmButton,
  tintColor: string,
  baseTimestamp: number,
  intervalSeconds: number,
  secondaryBtn?: CustomizableAlarmButton,
  soundName?: string
): Promise<boolean> {
  return NitroIosAlarmKitHybridObject.scheduleProgressiveBells(
    title,
    stopBtn,
    tintColor,
    baseTimestamp,
    intervalSeconds,
    secondaryBtn,
    soundName
  );
}

/**
 * Schedule an alarm at a fixed timestamp
 *
 * @param title - Alarm title (keep under 15 chars for Dynamic Island)
 * @param stopBtn - Stop button configuration
 * @param tintColor - Hex color for alarm UI (e.g., "#FF6B6B")
 * @param secondaryBtn - Optional snooze/secondary button
 * @param timestamp - Unix timestamp in seconds (must be in future)
 * @param countdown - Optional snooze duration configuration
 * @param soundName - Custom sound file name without extension (e.g., "magic" for magic.wav)
 */
export function scheduleFixedAlarm(
  title: string,
  stopBtn: CustomizableAlarmButton,
  tintColor: string,
  secondaryBtn?: CustomizableAlarmButton,
  timestamp?: number,
  countdown?: AlarmCountdown,
  soundName?: string
): Promise<boolean> {
  return NitroIosAlarmKitHybridObject.scheduleFixedAlarm(
    title,
    stopBtn,
    tintColor,
    secondaryBtn,
    timestamp,
    countdown,
    soundName
  );
}

/**
 * Schedule a repeating alarm at a specific time
 *
 * @param title - Alarm title (keep under 15 chars for Dynamic Island)
 * @param stopBtn - Stop button configuration
 * @param tintColor - Hex color for alarm UI
 * @param hour - Hour in 24-hour format (0-23)
 * @param minute - Minute (0-59)
 * @param repeats - Array of weekdays to repeat on
 * @param secondaryBtn - Optional snooze button
 * @param countdown - Optional snooze duration
 * @param soundName - Custom sound file name without extension
 */
export function scheduleRelativeAlarm(
  title: string,
  stopBtn: CustomizableAlarmButton,
  tintColor: string,
  hour: number,
  minute: number,
  repeats: AlarmWeekday[],
  secondaryBtn?: CustomizableAlarmButton,
  countdown?: AlarmCountdown,
  soundName?: string
): Promise<boolean> {
  return NitroIosAlarmKitHybridObject.scheduleRelativeAlarm(
    title,
    stopBtn,
    tintColor,
    hour,
    minute,
    repeats,
    secondaryBtn,
    countdown,
    soundName
  );
}

/**
 * Schedule a countdown timer
 *
 * @param title - Timer title (keep under 15 chars for Dynamic Island)
 * @param stopBtn - Stop button configuration
 * @param tintColor - Hex color for timer UI
 * @param durationSeconds - Timer duration in seconds
 * @param secondaryBtn - Optional secondary button
 * @param soundName - Custom sound file name without extension
 */
export function scheduleTimer(
  title: string,
  stopBtn: CustomizableAlarmButton,
  tintColor: string,
  durationSeconds: number,
  secondaryBtn?: CustomizableAlarmButton,
  soundName?: string
): Promise<boolean> {
  return NitroIosAlarmKitHybridObject.scheduleTimer(
    title,
    stopBtn,
    tintColor,
    durationSeconds,
    secondaryBtn,
    soundName
  );
}

export default {
  isAvailable,
  requestAlarmPermission,
  stopAllAlarms,
  scheduleProgressiveBells,
  scheduleFixedAlarm,
  scheduleRelativeAlarm,
  scheduleTimer,
};