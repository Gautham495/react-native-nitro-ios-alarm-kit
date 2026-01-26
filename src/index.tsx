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
 * Schedule an alarm at a fixed timestamp
 */
export function scheduleFixedAlarm(
  title: string,
  stopBtn: CustomizableAlarmButton,
  tintColor: string,
  secondaryBtn?: CustomizableAlarmButton,
  timestamp?: number,
  countdown?: AlarmCountdown
): Promise<boolean> {
  return NitroIosAlarmKitHybridObject.scheduleFixedAlarm(
    title,
    stopBtn,
    tintColor,
    secondaryBtn,
    timestamp,
    countdown
  );
}

/**
 * Schedule a repeating alarm at a specific time
 */
export function scheduleRelativeAlarm(
  title: string,
  stopBtn: CustomizableAlarmButton,
  tintColor: string,
  hour: number,
  minute: number,
  repeats: AlarmWeekday[],
  secondaryBtn?: CustomizableAlarmButton,
  countdown?: AlarmCountdown
): Promise<boolean> {
  return NitroIosAlarmKitHybridObject.scheduleRelativeAlarm(
    title,
    stopBtn,
    tintColor,
    hour,
    minute,
    repeats,
    secondaryBtn,
    countdown
  );
}

export default {
  isAvailable,
  requestAlarmPermission,
  scheduleFixedAlarm,
  scheduleRelativeAlarm,
};