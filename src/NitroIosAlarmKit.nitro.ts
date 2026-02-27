import type { HybridObject } from 'react-native-nitro-modules';

export interface CustomizableAlarmButton {
  text: string;
  textColor: string;
  /** SF Symbol name (e.g., "checkmark.circle.fill"). Only icon shows in Dynamic Island */
  icon?: string;
}

export interface AlarmCountdown {
  /** Countdown before alarm fires (for timers) */
  preAlert?: number;
  /** Snooze duration in seconds (e.g., 300 for 5 min) */
  postAlert?: number;
}

export type AlarmWeekday =
  | 'monday'
  | 'tuesday'
  | 'wednesday'
  | 'thursday'
  | 'friday'
  | 'saturday'
  | 'sunday';

export interface NitroIosAlarmKit
  extends HybridObject<{ ios: 'swift'; android: 'kotlin' }> {
  /**
   * Check if AlarmKit is available (iOS 26+)
   */
  isAvailable(): boolean;

  /**
   * Request permission to schedule alarms (iOS 26+ only)
   * @returns true if authorized, false otherwise
   */
  requestAlarmPermission(): Promise<boolean>;

  /**
   * Stop and cancel all scheduled/firing alarms
   * @returns true if successful
   */
  stopAllAlarms(): Promise<boolean>;

  /**
   * Stop or cancel a specific alarm by ID
   * @param alarmId - UUID string of the alarm to stop
   * @returns true if successful
   */
  stopAlarm(alarmId: string): Promise<boolean>;

  /**
   * Schedule an alarm at a fixed timestamp
   *
   * @param title - Keep under 15 chars for Dynamic Island
   * @param stopBtn - Stop button config
   * @param tintColor - Hex color (e.g., "#FF6B6B")
   * @param secondaryBtn - Optional snooze button
   * @param timestamp - Unix timestamp in seconds
   * @param countdown - Snooze duration config
   * @param soundName - Sound file name without extension (e.g., "magic" for magic.wav)
   * @returns Alarm ID (UUID string) or null if failed
   */
  scheduleFixedAlarm(
    title: string,
    stopBtn: CustomizableAlarmButton,
    tintColor: string,
    secondaryBtn?: CustomizableAlarmButton,
    timestamp?: number,
    countdown?: AlarmCountdown,
    soundName?: string
  ): Promise<string | null>;

  /**
   * Schedule a repeating alarm at a specific time
   *
   * @param title - Keep under 15 chars for Dynamic Island
   * @param stopBtn - Stop button config
   * @param tintColor - Hex color
   * @param hour - Hour in 24-hour format (0-23)
   * @param minute - Minute (0-59)
   * @param repeats - Days to repeat on
   * @param secondaryBtn - Optional snooze button
   * @param countdown - Snooze duration config
   * @param soundName - Sound file name without extension
   * @returns Alarm ID (UUID string) or null if failed
   */
  scheduleRelativeAlarm(
    title: string,
    stopBtn: CustomizableAlarmButton,
    tintColor: string,
    hour: number,
    minute: number,
    repeats: AlarmWeekday[],
    secondaryBtn?: CustomizableAlarmButton,
    countdown?: AlarmCountdown,
    soundName?: string
  ): Promise<string | null>;

  /**
   * Schedule a countdown timer
   *
   * @param title - Keep under 15 chars for Dynamic Island
   * @param stopBtn - Stop button config
   * @param tintColor - Hex color
   * @param durationSeconds - Timer duration in seconds
   * @param secondaryBtn - Optional secondary button
   * @param soundName - Sound file name without extension
   * @returns Alarm ID (UUID string) or null if failed
   */
  scheduleTimer(
    title: string,
    stopBtn: CustomizableAlarmButton,
    tintColor: string,
    durationSeconds: number,
    secondaryBtn?: CustomizableAlarmButton,
    soundName?: string
  ): Promise<string | null>;

  /**
   * Schedule progressive bells with pattern: t+1, t+2, t+3, t-1, t-2, t-3
   * Useful for meditation bells that ring before and after the main time
   *
   * @param title - Keep under 15 chars for Dynamic Island
   * @param stopBtn - Stop button config
   * @param tintColor - Hex color (e.g., "#6B4EFF")
   * @param baseTimestamp - Base Unix timestamp in seconds (the "t" reference point)
   * @param intervalSeconds - Interval between bells in seconds
   * @param secondaryBtn - Optional secondary button
   * @param soundName - Sound file name without extension
   * @returns Array of scheduled alarm IDs (UUID strings)
   */
  scheduleProgressiveBells(
    title: string,
    stopBtn: CustomizableAlarmButton,
    tintColor: string,
    baseTimestamp: number,
    intervalSeconds: number,
    secondaryBtn?: CustomizableAlarmButton,
    soundName?: string
  ): Promise<string[]>;
}