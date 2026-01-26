import { useState } from 'react';
import {
  Text,
  View,
  StyleSheet,
  Pressable,
  Alert,
  Platform,
} from 'react-native';
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

    Alert.alert(
      result ? 'Permission Granted' : 'Permission Denied',
      result
        ? 'You can now schedule alarms'
        : 'Please enable alarm permission in Settings'
    );
  };

  const handleScheduleFixedAlarm = async () => {
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

  const handleScheduleDailyAlarm = async () => {
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
      7,
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
    } else {
      Alert.alert('Error', 'Failed to schedule alarm');
    }
  };

  const available = isAvailable();

  return (
    <View style={styles.container}>
      <Text style={styles.title}>⏰ iOS AlarmKit</Text>
      <Text style={styles.subtitle}>react-native-nitro-ios-alarm-kit</Text>

      <View style={styles.statusContainer}>
        <View style={styles.statusRow}>
          <Text style={styles.statusLabel}>Platform:</Text>
          <Text style={styles.statusValue}>{Platform.OS}</Text>
        </View>
        <View style={styles.statusRow}>
          <Text style={styles.statusLabel}>Available:</Text>
          <Text style={styles.statusValue}>
            {available ? '✅ Yes' : '❌ No'}
          </Text>
        </View>
        <View style={styles.statusRow}>
          <Text style={styles.statusLabel}>Authorized:</Text>
          <Text
            style={[
              styles.statusValue,
              {
                color:
                  authorized === null
                    ? '#8E8E93'
                    : authorized
                    ? '#34C759'
                    : '#FF3B30',
              },
            ]}
          >
            {authorized === null
              ? '⏳ Unknown'
              : authorized
              ? '✅ Yes'
              : '❌ No'}
          </Text>
        </View>
      </View>

      <View style={styles.buttonContainer}>
        <Pressable
          style={[styles.button, styles.primaryButton]}
          onPress={handleRequestPermission}
        >
          <Text style={styles.buttonText}>Request Permission</Text>
        </Pressable>

        <Pressable
          style={[
            styles.button,
            styles.secondaryButton,
            !authorized && styles.disabledButton,
          ]}
          onPress={handleScheduleFixedAlarm}
          disabled={!authorized}
        >
          <Text style={[styles.buttonText, !authorized && styles.disabledText]}>
            Schedule One-Time Alarm (10s)
          </Text>
        </Pressable>

        <Pressable
          style={[
            styles.button,
            styles.secondaryButton,
            !authorized && styles.disabledButton,
          ]}
          onPress={handleScheduleDailyAlarm}
          disabled={!authorized}
        >
          <Text style={[styles.buttonText, !authorized && styles.disabledText]}>
            Schedule Daily Alarm (7:00 AM)
          </Text>
        </Pressable>
      </View>

      {!available && (
        <Text style={styles.note}>
          Note: AlarmKit requires iOS 26+. On Android and older iOS versions,
          all methods return false.
        </Text>
      )}
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    alignItems: 'center',
    justifyContent: 'center',
    backgroundColor: '#F2F2F7',
    padding: 20,
  },
  title: {
    fontSize: 32,
    fontWeight: '700',
    color: '#000',
    marginBottom: 4,
  },
  subtitle: {
    fontSize: 14,
    color: '#8E8E93',
    marginBottom: 32,
  },
  statusContainer: {
    backgroundColor: '#FFFFFF',
    borderRadius: 12,
    padding: 16,
    width: '100%',
    marginBottom: 24,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.1,
    shadowRadius: 4,
    elevation: 2,
  },
  statusRow: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    paddingVertical: 8,
  },
  statusLabel: {
    fontSize: 16,
    color: '#3C3C43',
  },
  statusValue: {
    fontSize: 16,
    fontWeight: '600',
  },
  buttonContainer: {
    width: '100%',
    gap: 12,
  },
  button: {
    borderRadius: 12,
    paddingVertical: 16,
    paddingHorizontal: 24,
    alignItems: 'center',
  },
  primaryButton: {
    backgroundColor: '#007AFF',
  },
  secondaryButton: {
    backgroundColor: '#34C759',
  },
  disabledButton: {
    backgroundColor: '#C7C7CC',
  },
  buttonText: {
    color: '#FFFFFF',
    fontSize: 16,
    fontWeight: '600',
  },
  disabledText: {
    color: '#F2F2F7',
  },
  note: {
    marginTop: 24,
    fontSize: 12,
    color: '#8E8E93',
    textAlign: 'center',
    paddingHorizontal: 20,
  },
});
