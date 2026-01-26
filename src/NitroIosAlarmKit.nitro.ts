import type { HybridObject } from 'react-native-nitro-modules';

export interface CustomizableAlarmButton {
  text: string;
  textColor: string;
  icon?: string;
}

export interface AlarmCountdown {
  preAlert?: number;
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
   * Request permission to schedule alarms (iOS 26+ only)
   * @returns true if authorized, false otherwise
   */
  requestAlarmPermission(): Promise<boolean>;

  /**
   * Schedule an alarm at a fixed timestamp
   */
  scheduleFixedAlarm(
    title: string,
    stopBtn: CustomizableAlarmButton,
    tintColor: string,
    secondaryBtn?: CustomizableAlarmButton,
    timestamp?: number,
    countdown?: AlarmCountdown
  ): Promise<boolean>;

  /**
   * Schedule a repeating alarm at a specific time
   */
  scheduleRelativeAlarm(
    title: string,
    stopBtn: CustomizableAlarmButton,
    tintColor: string,
    hour: number,
    minute: number,
    repeats: AlarmWeekday[],
    secondaryBtn?: CustomizableAlarmButton,
    countdown?: AlarmCountdown
  ): Promise<boolean>;

  /**
   * Check if AlarmKit is available (iOS 26+)
   */
  isAvailable(): boolean;
}