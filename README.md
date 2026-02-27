<a href="https://gauthamvijay.com">
  <picture>
    <img alt="react-native-nitro-ios-alarm-kit" src="./docs/img/banner.png" />
  </picture>
</a>

# react-native-nitro-ios-alarm-kit

A **React Native Nitro Module** providing native iOS AlarmKit bindings for **scheduling system-level alarms** that work even when your app is closed.

- 🔵 **Apple AlarmKit API** (iOS 26+)
- ⏰ **Fixed, Repeating & Timer Alarms**
- 🧘 **Progressive Bells** for meditation apps
- 🎨 **Customizable Alarm UI**
- 🔊 **Custom Alarm Sounds**
- 🛑 **Stop Individual or All Alarms**

---

> [!IMPORTANT]
>
> - Works in both Expo & Bare (Non Expo) React Native projects.
> - iOS 26+ only — Android returns no-op (`null`/`false`/`[]`) for all methods.
> - **Requires physical device** — Simulator has limited support.
> - AlarmKit was introduced in iOS 26 (WWDC 2025).

---

## 📦 Installation
```bash
npm install react-native-nitro-ios-alarm-kit react-native-nitro-modules
```

Then run:
```bash
cd ios && pod install
```

---

## Demo

<table>
  <tr>
    <th align="center">🍏 iOS Demo</th>
    <th align="center">🔐 Permission Prompt</th>
  </tr>
  <tr>
    <td align="center">
      <img alt="iOS AlarmKit Demo" src="./docs/videos/iOS.gif" height="650" width="300"/>
    </td>
    <td align="center">
      <img alt="AlarmKit Permission" src="./docs/img/permissions.png" height="650" width="300"/>
    </td>
  </tr>
</table>

---

## ⚙️ Configuration

### iOS

Add the AlarmKit usage description to your `Info.plist`:
```xml
<key>NSAlarmKitUsageDescription</key>
<string>Your app wants to schedule alerts for alarms you create.</string>
```

### Custom Sounds

To use custom alarm sounds:

1. Add your sound file (e.g., `magic.wav`) to your Xcode project's **main bundle**
2. Supported formats: `.wav`, `.aiff`, `.caf`
3. Pass the filename **without extension** to the `soundName` parameter

### Android

No configuration needed — all methods return `false`/`null`/`[]` as AlarmKit is iOS-only.

---

## 🧠 Overview

| Feature                 | Description                                                    |
| ----------------------- | -------------------------------------------------------------- |
| **Fixed Alarms**        | Schedule one-time alarms at a specific timestamp               |
| **Relative Alarms**     | Schedule repeating alarms (daily, weekly) at a specific time   |
| **Timers**              | Schedule countdown timers that fire after a duration           |
| **Progressive Bells**   | Schedule meditation bells with pattern: t+1, t+2, t+3, t-1, t-2, t-3 |
| **Stop Alarm**          | Cancel a specific alarm by ID                                  |
| **Stop All Alarms**     | Cancel all scheduled/firing alarms                             |
| **Custom UI**           | Customize button text, colors, and SF Symbols icons            |
| **Custom Sounds**       | Use your own alarm sounds from the app bundle                  |

---

## 💡 UI Tips for Dynamic Island

The Dynamic Island has very limited space. Follow these tips for best results:

| Tip                               | Why                                          |
| --------------------------------- | -------------------------------------------- |
| **Keep titles under 15 characters** | Longer titles get truncated                  |
| **Use distinctive SF Symbol icons** | Only the icon shows in Dynamic Island        |
| **Set short app display name**    | Your `CFBundleDisplayName` shows in alarm UI |

**Good icons for Dynamic Island:**

- Stop: `checkmark.circle.fill`, `stop.circle.fill`, `xmark.circle.fill`
- Snooze: `repeat.circle.fill`, `clock.arrow.circlepath`, `zzz`
- Meditation: `leaf.fill`, `sparkles`, `wind`

---

## ⚙️ Usage

### Check Availability
```tsx
import { isAvailable } from 'react-native-nitro-ios-alarm-kit';

if (isAvailable()) {
  // AlarmKit is available (iOS 26+)
} else {
  // Fallback to local notifications
}
```

### Request Permission
```tsx
import { requestAlarmPermission } from 'react-native-nitro-ios-alarm-kit';

const authorized = await requestAlarmPermission();

if (authorized) {
  // User granted alarm permission
} else {
  // Permission denied
}
```

### Schedule a Timer (Countdown)
```tsx
import { scheduleTimer } from 'react-native-nitro-ios-alarm-kit';

// Schedule a 5-minute timer
const alarmId = await scheduleTimer(
  'Done! 🎉',           // title (keep SHORT!)
  {
    text: 'Stop',
    textColor: '#FFFFFF',
    icon: 'checkmark.circle.fill',
  },
  '#FF6B6B',            // tintColor
  300,                  // 5 minutes in seconds
  {
    text: 'Snooze',
    textColor: '#FFFFFF',
    icon: 'repeat.circle.fill',
  },
  'magic'               // Custom sound: magic.wav (optional)
);

if (alarmId) {
  console.log('Timer scheduled with ID:', alarmId);
}
```

### Schedule a Fixed Alarm (One-Time)
```tsx
import { scheduleFixedAlarm } from 'react-native-nitro-ios-alarm-kit';

// Schedule alarm for 1 hour from now
const timestamp = Date.now() / 1000 + 3600;

const alarmId = await scheduleFixedAlarm(
  'Wake Up!',           // title (keep SHORT!)
  {
    text: 'Stop',
    textColor: '#FFFFFF',
    icon: 'checkmark.circle.fill',
  },
  '#FF5733',            // tintColor
  {
    text: 'Snooze',
    textColor: '#FFFFFF',
    icon: 'repeat.circle.fill',
  },
  timestamp,            // Unix timestamp in seconds
  { postAlert: 540 },   // 9-min snooze (like iOS default)
  'alarm_sound'         // Custom sound (optional)
);

if (alarmId) {
  console.log('Alarm scheduled with ID:', alarmId);
}
```

### Schedule a Relative Alarm (Repeating)
```tsx
import { scheduleRelativeAlarm } from 'react-native-nitro-ios-alarm-kit';

// Schedule alarm for 7:00 AM on weekdays
const alarmId = await scheduleRelativeAlarm(
  'Wake Up!',           // title (keep SHORT!)
  {
    text: 'Stop',
    textColor: '#FFFFFF',
    icon: 'sun.max.fill',
  },
  '#FF9500',            // tintColor
  7,                    // hour (0-23)
  0,                    // minute (0-59)
  ['monday', 'tuesday', 'wednesday', 'thursday', 'friday'],
  {
    text: 'Snooze',
    textColor: '#FFFFFF',
    icon: 'moon.zzz.fill',
  },
  { postAlert: 540 },   // 9-min snooze
  'morning_alarm'       // Custom sound (optional)
);

if (alarmId) {
  console.log('Daily alarm scheduled with ID:', alarmId);
}
```

### Schedule Progressive Bells (Meditation)

Perfect for meditation apps! Schedules bells in pattern: **t+1, t+2, t+3, t-1, t-2, t-3** where t is the base time and the number is multiplied by the interval.
```tsx
import { scheduleProgressiveBells } from 'react-native-nitro-ios-alarm-kit';

// Schedule bells around a meditation session ending in 10 minutes
// With 30-second intervals: bells at t+30s, t+60s, t+90s, t-30s, t-60s, t-90s
const baseTimestamp = Date.now() / 1000 + 600; // 10 mins from now

const bellIds = await scheduleProgressiveBells(
  'Breathe',            // title (keep SHORT!)
  {
    text: 'OK',
    textColor: '#FFFFFF',
    icon: 'leaf.fill',
  },
  '#4ECDC4',            // tintColor
  baseTimestamp,        // Base time (the "t" reference point)
  30,                   // 30-second intervals
  undefined,            // No secondary button
  'singing_bowl'        // Custom sound (optional)
);

console.log(`Scheduled ${bellIds.length} bells:`, bellIds);
```

### Stop a Specific Alarm
```tsx
import { stopAlarm } from 'react-native-nitro-ios-alarm-kit';

// Stop/cancel a specific alarm by ID
const success = await stopAlarm(alarmId);

if (success) {
  console.log('Alarm stopped');
}
```

### Stop All Alarms
```tsx
import { stopAllAlarms } from 'react-native-nitro-ios-alarm-kit';

// Stop/cancel all scheduled and firing alarms
const success = await stopAllAlarms();

if (success) {
  console.log('All alarms stopped');
}
```

---

## 📖 API Reference

### `isAvailable(): boolean`

Returns `true` if AlarmKit is available (iOS 26+), `false` otherwise.

---

### `requestAlarmPermission(): Promise<boolean>`

Requests permission to schedule alarms.

**Returns:** `true` if authorized, `false` otherwise.

---

### `stopAlarm(alarmId): Promise<boolean>`

Stops or cancels a specific alarm by ID.

| Parameter | Type     | Required | Description                    |
| --------- | -------- | -------- | ------------------------------ |
| `alarmId` | `string` | ✅       | UUID string of alarm to stop   |

**Returns:** `true` if successful, `false` otherwise.

---

### `stopAllAlarms(): Promise<boolean>`

Stops all scheduled and currently firing alarms.

**Returns:** `true` if successful, `false` otherwise.

---

### `scheduleTimer(...): Promise<string | null>`

Schedules a countdown timer that fires after the specified duration.

| Parameter         | Type                      | Required | Description                         |
| ----------------- | ------------------------- | -------- | ----------------------------------- |
| `title`           | `string`                  | ✅       | Timer title (keep under 15 chars)   |
| `stopBtn`         | `CustomizableAlarmButton` | ✅       | Primary stop button configuration   |
| `tintColor`       | `string`                  | ✅       | Hex color (e.g., `#FF6B6B`)         |
| `durationSeconds` | `number`                  | ✅       | Timer duration in seconds           |
| `secondaryBtn`    | `CustomizableAlarmButton` | ❌       | Optional secondary button           |
| `soundName`       | `string`                  | ❌       | Sound file name without extension   |

**Returns:** Alarm ID (UUID string) or `null` if failed.

---

### `scheduleFixedAlarm(...): Promise<string | null>`

Schedules a one-time alarm at a specific Unix timestamp.

| Parameter      | Type                      | Required | Description                          |
| -------------- | ------------------------- | -------- | ------------------------------------ |
| `title`        | `string`                  | ✅       | Alarm title (keep under 15 chars)    |
| `stopBtn`      | `CustomizableAlarmButton` | ✅       | Primary stop button configuration    |
| `tintColor`    | `string`                  | ✅       | Hex color (e.g., `#FF5733`)          |
| `secondaryBtn` | `CustomizableAlarmButton` | ❌       | Optional secondary button (Snooze)   |
| `timestamp`    | `number`                  | ❌       | Unix timestamp in seconds            |
| `countdown`    | `AlarmCountdown`          | ❌       | Snooze duration configuration        |
| `soundName`    | `string`                  | ❌       | Sound file name without extension    |

**Returns:** Alarm ID (UUID string) or `null` if failed.

---

### `scheduleRelativeAlarm(...): Promise<string | null>`

Schedules a repeating alarm at a specific time on given weekdays.

| Parameter      | Type                      | Required | Description                        |
| -------------- | ------------------------- | -------- | ---------------------------------- |
| `title`        | `string`                  | ✅       | Alarm title (keep under 15 chars)  |
| `stopBtn`      | `CustomizableAlarmButton` | ✅       | Primary stop button configuration  |
| `tintColor`    | `string`                  | ✅       | Hex color                          |
| `hour`         | `number`                  | ✅       | Hour (0-23)                        |
| `minute`       | `number`                  | ✅       | Minute (0-59)                      |
| `repeats`      | `AlarmWeekday[]`          | ✅       | Days to repeat                     |
| `secondaryBtn` | `CustomizableAlarmButton` | ❌       | Optional secondary button          |
| `countdown`    | `AlarmCountdown`          | ❌       | Snooze duration configuration      |
| `soundName`    | `string`                  | ❌       | Sound file name without extension  |

**Returns:** Alarm ID (UUID string) or `null` if failed.

---

### `scheduleProgressiveBells(...): Promise<string[]>`

Schedules meditation bells with progressive pattern: **t+1, t+2, t+3, t-1, t-2, t-3**.

| Parameter         | Type                      | Required | Description                                 |
| ----------------- | ------------------------- | -------- | ------------------------------------------- |
| `title`           | `string`                  | ✅       | Bell title (keep under 15 chars)            |
| `stopBtn`         | `CustomizableAlarmButton` | ✅       | Stop button configuration                   |
| `tintColor`       | `string`                  | ✅       | Hex color (e.g., `#4ECDC4`)                 |
| `baseTimestamp`   | `number`                  | ✅       | Base Unix timestamp (the "t" reference)     |
| `intervalSeconds` | `number`                  | ✅       | Interval between bells in seconds           |
| `secondaryBtn`    | `CustomizableAlarmButton` | ❌       | Optional secondary button                   |
| `soundName`       | `string`                  | ❌       | Sound file name without extension           |

**Returns:** Array of alarm IDs (UUID strings) for scheduled bells.

**Example timeline with `intervalSeconds = 30` and `baseTimestamp = t`:**

| Bell | Offset | Time        |
| ---- | ------ | ----------- |
| 1    | +1     | t + 30s     |
| 2    | +2     | t + 60s     |
| 3    | +3     | t + 90s     |
| 4    | -1     | t - 30s     |
| 5    | -2     | t - 60s     |
| 6    | -3     | t - 90s     |

---

## 🎨 Types
```typescript
interface CustomizableAlarmButton {
  text: string;       // Button label
  textColor: string;  // Hex color (e.g., '#FFFFFF')
  icon?: string;      // SF Symbol name (e.g., 'checkmark.circle.fill')
}

interface AlarmCountdown {
  preAlert?: number;  // Seconds before alarm (for countdown display)
  postAlert?: number; // Snooze duration in seconds
}

type AlarmWeekday =
  | 'monday'
  | 'tuesday'
  | 'wednesday'
  | 'thursday'
  | 'friday'
  | 'saturday'
  | 'sunday';
```

---

## 🔄 Complete Usage Example
```tsx
import { useState } from 'react';
import { View, Text, Pressable, Alert } from 'react-native';
import {
  isAvailable,
  requestAlarmPermission,
  scheduleTimer,
  scheduleFixedAlarm,
  scheduleProgressiveBells,
  stopAlarm,
  stopAllAlarms,
} from 'react-native-nitro-ios-alarm-kit';

export default function App() {
  const [authorized, setAuthorized] = useState(false);
  const [alarmIds, setAlarmIds] = useState<string[]>([]);

  // 1. Check availability & request permission
  const handleSetup = async () => {
    if (!isAvailable()) {
      Alert.alert('Error', 'AlarmKit requires iOS 26+');
      return;
    }
    const result = await requestAlarmPermission();
    setAuthorized(result);
  };

  // 2. Schedule a timer
  const handleTimer = async () => {
    const id = await scheduleTimer(
      'Done!',
      { text: 'Stop', textColor: '#FFF', icon: 'checkmark.circle.fill' },
      '#FF6B6B',
      10 // 10 seconds
    );
    if (id) setAlarmIds((prev) => [...prev, id]);
  };

  // 3. Schedule meditation bells
  const handleBells = async () => {
    const ids = await scheduleProgressiveBells(
      'Breathe',
      { text: 'OK', textColor: '#FFF', icon: 'leaf.fill' },
      '#4ECDC4',
      Date.now() / 1000 + 60, // Base: 1 min from now
      10 // 10-second intervals
    );
    setAlarmIds((prev) => [...prev, ...ids]);
  };

  // 4. Stop last alarm
  const handleStopLast = async () => {
    if (alarmIds.length === 0) return;
    const lastId = alarmIds[alarmIds.length - 1];
    const success = await stopAlarm(lastId);
    if (success) setAlarmIds((prev) => prev.slice(0, -1));
  };

  // 5. Stop all alarms
  const handleStopAll = async () => {
    const success = await stopAllAlarms();
    if (success) setAlarmIds([]);
  };

  return (
    <View style={{ flex: 1, justifyContent: 'center', padding: 20, gap: 12 }}>
      <Text>Scheduled: {alarmIds.length} alarm(s)</Text>
      <Pressable onPress={handleSetup}>
        <Text>🔐 Request Permission</Text>
      </Pressable>
      <Pressable onPress={handleTimer} disabled={!authorized}>
        <Text>⏱️ Schedule Timer</Text>
      </Pressable>
      <Pressable onPress={handleBells} disabled={!authorized}>
        <Text>🧘 Schedule Bells</Text>
      </Pressable>
      <Pressable onPress={handleStopLast}>
        <Text>⏹️ Stop Last</Text>
      </Pressable>
      <Pressable onPress={handleStopAll}>
        <Text>🛑 Stop All</Text>
      </Pressable>
    </View>
  );
}
```

---

## 🧩 Platform Support

| Platform          | Status                              |
| ----------------- | ----------------------------------- |
| **iOS 26+**       | ✅ Fully Supported                  |
| **iOS < 26**      | ⚠️ Returns `false`/`null`/`[]`      |
| **iOS Simulator** | ⚠️ Limited (permissions only)       |
| **Android**       | ❌ No-op (returns `false`/`null`/`[]`) |

---

## 🤝 Contributing

Pull requests welcome!

- [Development Workflow](CONTRIBUTING.md#development-workflow)
- [Sending a PR](CONTRIBUTING.md#sending-a-pull-request)
- [Code of Conduct](CODE_OF_CONDUCT.md)

---

## 🪪 License

MIT © [**Gautham Vijayan**](https://gauthamvijay.com)

---

Made with ❤️ and [**Nitro Modules**](https://nitro.margelo.com)