<a href="https://gauthamvijay.com">
  <picture>
    <img alt="react-native-nitro-ios-alarm-kit" src="./docs/img/banner.png" />
  </picture>
</a>

# react-native-nitro-ios-alarm-kit

A **React Native Nitro Module** providing native iOS AlarmKit bindings for **scheduling system-level alarms** that work even when your app is closed.

- 🔵 **Apple AlarmKit API** (iOS 26+)
- ⏰ **Fixed & Repeating Alarms**
- 🎨 **Customizable Alarm UI**

---

> [!IMPORTANT]
>
> - Works in both Expo & Bare (Non Expo) React Native projects.
> - iOS 26+ only — Android returns no-op (false) for all methods.
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
      <img alt="AlarmKit Permission" src="./docs/images/permissions.png" height="650" width="300"/>
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

**Example:**

```xml
<key>NSAlarmKitUsageDescription</key>
<string>SparkHabits wants to schedule alerts for alarms you create for timer and breath meditations.</string>
```

### Android

No configuration needed — all methods return `false` as AlarmKit is iOS-only.

---

## 🧠 Overview

| Feature | Description |
| --- | --- |
| **Fixed Alarms** | Schedule one-time alarms at a specific timestamp |
| **Relative Alarms** | Schedule repeating alarms (daily, weekly) at a specific time |
| **Custom UI** | Customize button text, colors, and SF Symbols icons |
| **Countdown** | Configure pre-alert and post-alert countdown durations |

---

## ⚙️ Usage

### Check Availability

```tsx
import { isAvailable } from 'react-native-nitro-ios-alarm-kit';

if (isAvailable()) {
  // AlarmKit is available (iOS 26+)
} else {
  // Fallback to local notifications or other alarm solution
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

### Schedule a Fixed Alarm (One-Time)

```tsx
import { scheduleFixedAlarm } from 'react-native-nitro-ios-alarm-kit';

// Schedule alarm for 1 hour from now
const timestamp = Date.now() / 1000 + 3600;

const success = await scheduleFixedAlarm(
  'Wake Up!',                    // title
  {
    text: 'Stop',
    textColor: '#FFFFFF',
    icon: 'stop.fill',           // SF Symbol
  },
  '#FF5733',                     // tintColor
  undefined,                     // secondaryBtn (optional)
  timestamp,                     // Unix timestamp in seconds
  { preAlert: 60, postAlert: 120 } // countdown (optional)
);
```

### Schedule a Relative Alarm (Repeating)

```tsx
import { scheduleRelativeAlarm } from 'react-native-nitro-ios-alarm-kit';

// Schedule alarm for 8:30 AM on weekdays
const success = await scheduleRelativeAlarm(
  'Daily Standup',               // title
  {
    text: 'Dismiss',
    textColor: '#FFFFFF',
    icon: 'xmark',
  },
  '#4CAF50',                     // tintColor
  8,                             // hour (0-23)
  30,                            // minute (0-59)
  ['monday', 'tuesday', 'wednesday', 'thursday', 'friday'],
  {
    text: 'Snooze',
    textColor: '#FFFFFF',
    icon: 'clock',
  },                             // secondaryBtn (optional)
  { preAlert: 30, postAlert: 60 } // countdown (optional)
);
```

### Full Example

```tsx
import { useState } from 'react';
import { View, Text, Pressable, StyleSheet, Alert } from 'react-native';
import {
  isAvailable,
  requestAlarmPermission,
  scheduleFixedAlarm,
  scheduleRelativeAlarm,
} from 'react-native-nitro-ios-alarm-kit';

export default function App() {
  const [authorized, setAuthorized] = useState<boolean | null>(null);

  const handleRequestPermission = async () => {
    if (!isAvailable()) {
      Alert.alert('Not Available', 'AlarmKit requires iOS 26+');
      return;
    }

    const result = await requestAlarmPermission();
    setAuthorized(result);
  };

  const handleScheduleAlarm = async () => {
    if (!authorized) {
      Alert.alert('Permission Required', 'Please grant alarm permission first');
      return;
    }

    // Schedule alarm for 10 seconds from now
    const timestamp = Date.now() / 1000 + 10;

    const success = await scheduleFixedAlarm(
      'Timer Complete! 🎉',
      {
        text: 'Stop',
        textColor: '#FFFFFF',
        icon: 'stop.fill',
      },
      '#007AFF',
      undefined,
      timestamp,
      { preAlert: 5, postAlert: 10 }
    );

    if (success) {
      Alert.alert('Success', 'Alarm scheduled for 10 seconds from now');
    } else {
      Alert.alert('Error', 'Failed to schedule alarm');
    }
  };

  const handleScheduleDaily = async () => {
    if (!authorized) {
      Alert.alert('Permission Required', 'Please grant alarm permission first');
      return;
    }

    const success = await scheduleRelativeAlarm(
      'Good Morning! ☀️',
      {
        text: 'Wake Up',
        textColor: '#FFFFFF',
        icon: 'sun.max.fill',
      },
      '#FF9500',
      7,  // 7:00 AM
      0,
      ['monday', 'tuesday', 'wednesday', 'thursday', 'friday'],
      {
        text: 'Snooze',
        textColor: '#FFFFFF',
        icon: 'moon.zzz.fill',
      },
      { preAlert: 60, postAlert: 120 }
    );

    if (success) {
      Alert.alert('Success', 'Daily alarm scheduled for 7:00 AM on weekdays');
    }
  };

  return (
    <View style={styles.container}>
      <Text style={styles.title}>iOS AlarmKit Demo</Text>

      <Text style={styles.status}>
        Available: {isAvailable() ? '✅ Yes' : '❌ No'}
      </Text>
      <Text style={styles.status}>
        Authorized: {authorized === null ? '⏳ Unknown' : authorized ? '✅ Yes' : '❌ No'}
      </Text>

      <Pressable style={styles.button} onPress={handleRequestPermission}>
        <Text style={styles.buttonText}>Request Permission</Text>
      </Pressable>

      <Pressable style={styles.button} onPress={handleScheduleAlarm}>
        <Text style={styles.buttonText}>Schedule One-Time Alarm</Text>
      </Pressable>

      <Pressable style={styles.button} onPress={handleScheduleDaily}>
        <Text style={styles.buttonText}>Schedule Daily Alarm</Text>
      </Pressable>
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    padding: 20,
    backgroundColor: '#f4f6f8',
    alignItems: 'center',
    justifyContent: 'center',
    gap: 16,
  },
  title: {
    fontSize: 24,
    fontWeight: '700',
    marginBottom: 20,
  },
  status: {
    fontSize: 16,
    color: '#666',
  },
  button: {
    backgroundColor: '#007AFF',
    borderRadius: 12,
    paddingVertical: 14,
    paddingHorizontal: 24,
    width: '100%',
  },
  buttonText: {
    color: '#FFFFFF',
    fontSize: 16,
    fontWeight: '600',
    textAlign: 'center',
  },
});
```

---

## 📖 API Reference

### `isAvailable(): boolean`

Returns `true` if AlarmKit is available (iOS 26+), `false` otherwise.

### `requestAlarmPermission(): Promise<boolean>`

Requests permission to schedule alarms. Returns `true` if authorized, `false` otherwise.

### `scheduleFixedAlarm(title, stopBtn, tintColor, secondaryBtn?, timestamp?, countdown?): Promise<boolean>`

Schedules a one-time alarm at a specific Unix timestamp.

| Parameter | Type | Required | Description |
| --- | --- | --- | --- |
| `title` | `string` | ✅ | Alarm title displayed to user |
| `stopBtn` | `CustomizableAlarmButton` | ✅ | Primary stop button configuration |
| `tintColor` | `string` | ✅ | Hex color for alarm UI (e.g., `#FF5733`) |
| `secondaryBtn` | `CustomizableAlarmButton` | ❌ | Optional secondary button (e.g., Snooze) |
| `timestamp` | `number` | ❌ | Unix timestamp in seconds |
| `countdown` | `AlarmCountdown` | ❌ | Pre/post alert durations |

### `scheduleRelativeAlarm(title, stopBtn, tintColor, hour, minute, repeats, secondaryBtn?, countdown?): Promise<boolean>`

Schedules a repeating alarm at a specific time on given weekdays.

| Parameter | Type | Required | Description |
| --- | --- | --- | --- |
| `title` | `string` | ✅ | Alarm title displayed to user |
| `stopBtn` | `CustomizableAlarmButton` | ✅ | Primary stop button configuration |
| `tintColor` | `string` | ✅ | Hex color for alarm UI |
| `hour` | `number` | ✅ | Hour (0-23) |
| `minute` | `number` | ✅ | Minute (0-59) |
| `repeats` | `AlarmWeekday[]` | ✅ | Days to repeat |
| `secondaryBtn` | `CustomizableAlarmButton` | ❌ | Optional secondary button |
| `countdown` | `AlarmCountdown` | ❌ | Pre/post alert durations |

---

## 🎨 Types

```typescript
interface CustomizableAlarmButton {
  text: string;        // Button label
  textColor: string;   // Hex color (e.g., '#FFFFFF')
  icon?: string;       // SF Symbol name (e.g., 'stop.fill')
}

interface AlarmCountdown {
  preAlert?: number;   // Seconds before alarm to start countdown
  postAlert?: number;  // Seconds after alarm before auto-dismiss
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

## 🧩 Platform Support

| Platform | Status |
| --- | --- |
| **iOS 26+** | ✅ Fully Supported |
| **iOS < 26** | ⚠️ Returns `false` |
| **iOS Simulator** | ⚠️ Limited support |
| **Android** | ❌ No-op (returns `false`) |

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