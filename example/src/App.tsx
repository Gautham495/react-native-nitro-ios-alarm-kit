import { useState, useCallback } from 'react';
import {
  Text,
  View,
  StyleSheet,
  Pressable,
  Alert,
  Platform,
  ScrollView,
  SafeAreaView,
} from 'react-native';
import {
  isAvailable,
  requestAlarmPermission,
  scheduleFixedAlarm,
  scheduleRelativeAlarm,
  scheduleTimer,
  scheduleProgressiveBells,
  stopAlarm,
  stopAllAlarms,
} from 'react-native-nitro-ios-alarm-kit';

export default function App() {
  const [authorized, setAuthorized] = useState<boolean | null>(null);
  const [scheduledAlarms, setScheduledAlarms] = useState<string[]>([]);

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

  const addAlarmId = useCallback((id: string | null) => {
    if (id) {
      setScheduledAlarms((prev) => [...prev, id]);
    }
  }, []);

  const handleScheduleTimer = async () => {
    if (!authorized) {
      Alert.alert('Permission Required', 'Please grant alarm permission first');
      return;
    }

    const alarmId = await scheduleTimer(
      'Done! 🎉',
      {
        text: 'Stop',
        textColor: '#FFFFFF',
        icon: 'checkmark.circle.fill',
      },
      '#FF6B6B',
      5,
      {
        text: 'Snooze',
        textColor: '#FFFFFF',
        icon: 'repeat.circle.fill',
      },
      'magic'
    );

    if (alarmId) {
      addAlarmId(alarmId);
      Alert.alert('Success', `Timer set for 5 seconds\nID: ${alarmId.slice(0, 8)}...`);
    } else {
      Alert.alert('Error', 'Failed to schedule timer');
    }
  };

  const handleScheduleFixedAlarm = async () => {
    if (!authorized) {
      Alert.alert('Permission Required', 'Please grant alarm permission first');
      return;
    }

    const timestamp = Date.now() / 1000 + 10;

    const alarmId = await scheduleFixedAlarm(
      'Time Up!',
      {
        text: 'Done',
        textColor: '#FFFFFF',
        icon: 'checkmark.circle.fill',
      },
      '#007AFF',
      {
        text: 'Snooze',
        textColor: '#FFFFFF',
        icon: 'repeat.circle.fill',
      },
      timestamp,
      { postAlert: 60 },
      undefined
    );

    if (alarmId) {
      addAlarmId(alarmId);
      Alert.alert('Success', `Alarm scheduled for 10 seconds\nID: ${alarmId.slice(0, 8)}...`);
    } else {
      Alert.alert('Error', 'Failed to schedule alarm');
    }
  };

  const handleScheduleDailyAlarm = async () => {
    if (!authorized) {
      Alert.alert('Permission Required', 'Please grant alarm permission first');
      return;
    }

    const alarmId = await scheduleRelativeAlarm(
      'Wake Up!',
      {
        text: 'Stop',
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
      { postAlert: 540 },
      undefined
    );

    if (alarmId) {
      addAlarmId(alarmId);
      Alert.alert('Success', `Daily alarm scheduled for 7:00 AM\nID: ${alarmId.slice(0, 8)}...`);
    } else {
      Alert.alert('Error', 'Failed to schedule alarm');
    }
  };

  const handleScheduleProgressiveBells = async () => {
    if (!authorized) {
      Alert.alert('Permission Required', 'Please grant alarm permission first');
      return;
    }

    // Schedule bells around 30 seconds from now with 5-second intervals
    const baseTimestamp = Date.now() / 1000 + 30;

    const alarmIds = await scheduleProgressiveBells(
      'Breathe',
      {
        text: 'OK',
        textColor: '#FFFFFF',
        icon: 'leaf.fill',
      },
      '#4ECDC4',
      baseTimestamp,
      5, // 5 second intervals
      undefined,
      'bell'
    );

    if (alarmIds.length > 0) {
      setScheduledAlarms((prev) => [...prev, ...alarmIds]);
      Alert.alert(
        'Success',
        `${alarmIds.length} bells scheduled\nPattern: t+5s, t+10s, t+15s, t-5s, t-10s, t-15s`
      );
    } else {
      Alert.alert('Error', 'Failed to schedule bells');
    }
  };

  const handleStopLastAlarm = async () => {
    if (scheduledAlarms.length === 0) {
      Alert.alert('No Alarms', 'No alarms to stop');
      return;
    }

    const lastAlarmId = scheduledAlarms[scheduledAlarms.length - 1] || '';
    
    const success = await stopAlarm(lastAlarmId);

    if (success) {
      setScheduledAlarms((prev) => prev.slice(0, -1));
      Alert.alert('Success', `Stopped alarm: ${lastAlarmId.slice(0, 8)}...`);
    } else {
      Alert.alert('Error', 'Failed to stop alarm');
    }
  };

  const handleStopAllAlarms = async () => {
    if (scheduledAlarms.length === 0) {
      Alert.alert('No Alarms', 'No alarms to stop');
      return;
    }

    Alert.alert(
      'Stop All Alarms',
      `Are you sure you want to stop all ${scheduledAlarms.length} alarm(s)?`,
      [
        { text: 'Cancel', style: 'cancel' },
        {
          text: 'Stop All',
          style: 'destructive',
          onPress: async () => {
            const success = await stopAllAlarms();
            if (success) {
              setScheduledAlarms([]);
              Alert.alert('Success', 'All alarms stopped');
            } else {
              Alert.alert('Error', 'Failed to stop alarms');
            }
          },
        },
      ]
    );
  };

  const available = isAvailable();

  return (
    <SafeAreaView style={styles.safeArea}>
      <ScrollView
        style={styles.scrollView}
        contentContainerStyle={styles.scrollContent}
      >
        <View style={styles.container}>
          <Text style={styles.title}>⏰ iOS AlarmKit</Text>
          <Text style={styles.subtitle}>react-native-nitro-ios-alarm-kit</Text>

          {/* Status Card */}
          <View style={styles.card}>
            <Text style={styles.cardTitle}>Status</Text>
            <View style={styles.statusRow}>
              <Text style={styles.statusLabel}>Platform</Text>
              <Text style={styles.statusValue}>{Platform.OS}</Text>
            </View>
            <View style={styles.statusRow}>
              <Text style={styles.statusLabel}>Available</Text>
              <Text style={[styles.statusValue, { color: available ? '#34C759' : '#FF3B30' }]}>
                {available ? '✅ Yes' : '❌ No'}
              </Text>
            </View>
            <View style={styles.statusRow}>
              <Text style={styles.statusLabel}>Authorized</Text>
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
                {authorized === null ? '⏳ Unknown' : authorized ? '✅ Yes' : '❌ No'}
              </Text>
            </View>
            <View style={styles.statusRow}>
              <Text style={styles.statusLabel}>Scheduled</Text>
              <Text style={styles.statusValue}>{scheduledAlarms.length} alarm(s)</Text>
            </View>
          </View>

          {/* Permission Button */}
          <View style={styles.section}>
            <Text style={styles.sectionTitle}>Permission</Text>
            <Pressable
              style={[styles.button, styles.primaryButton]}
              onPress={handleRequestPermission}
            >
              <Text style={styles.buttonText}>🔐 Request Permission</Text>
            </Pressable>
          </View>

          {/* Schedule Buttons */}
          <View style={styles.section}>
            <Text style={styles.sectionTitle}>Schedule Alarms</Text>

            <Pressable
              style={[styles.button, styles.timerButton, !authorized && styles.disabledButton]}
              onPress={handleScheduleTimer}
              disabled={!authorized}
            >
              <Text style={[styles.buttonText, !authorized && styles.disabledText]}>
                ⏱️ Timer (5 seconds)
              </Text>
            </Pressable>

            <Pressable
              style={[styles.button, styles.alarmButton, !authorized && styles.disabledButton]}
              onPress={handleScheduleFixedAlarm}
              disabled={!authorized}
            >
              <Text style={[styles.buttonText, !authorized && styles.disabledText]}>
                🔔 Fixed Alarm (10 seconds)
              </Text>
            </Pressable>

            <Pressable
              style={[styles.button, styles.dailyButton, !authorized && styles.disabledButton]}
              onPress={handleScheduleDailyAlarm}
              disabled={!authorized}
            >
              <Text style={[styles.buttonText, !authorized && styles.disabledText]}>
                ☀️ Daily Alarm (7:00 AM)
              </Text>
            </Pressable>

            <Pressable
              style={[styles.button, styles.bellsButton, !authorized && styles.disabledButton]}
              onPress={handleScheduleProgressiveBells}
              disabled={!authorized}
            >
              <Text style={[styles.buttonText, !authorized && styles.disabledText]}>
                🧘 Progressive Bells (Meditation)
              </Text>
            </Pressable>
          </View>

          {/* Stop Buttons */}
          <View style={styles.section}>
            <Text style={styles.sectionTitle}>Manage Alarms</Text>

            <Pressable
              style={[
                styles.button,
                styles.stopButton,
                scheduledAlarms.length === 0 && styles.disabledButton,
              ]}
              onPress={handleStopLastAlarm}
              disabled={scheduledAlarms.length === 0}
            >
              <Text
                style={[
                  styles.buttonText,
                  scheduledAlarms.length === 0 && styles.disabledText,
                ]}
              >
                ⏹️ Stop Last Alarm
              </Text>
            </Pressable>

            <Pressable
              style={[
                styles.button,
                styles.stopAllButton,
                scheduledAlarms.length === 0 && styles.disabledButton,
              ]}
              onPress={handleStopAllAlarms}
              disabled={scheduledAlarms.length === 0}
            >
              <Text
                style={[
                  styles.buttonText,
                  scheduledAlarms.length === 0 && styles.disabledText,
                ]}
              >
                🛑 Stop All Alarms
              </Text>
            </Pressable>
          </View>

          {/* Tips */}
          <View style={styles.card}>
            <Text style={styles.cardTitle}>💡 Tips</Text>
            <Text style={styles.tipText}>• Keep titles under 15 characters</Text>
            <Text style={styles.tipText}>• Use distinctive SF Symbol icons</Text>
            <Text style={styles.tipText}>• Add sound files to app bundle</Text>
            <Text style={styles.tipText}>• Progressive bells: t+1, t+2, t+3, t-1, t-2, t-3</Text>
          </View>

          {!available && (
            <Text style={styles.note}>
              ⚠️ AlarmKit requires iOS 26+ on a physical device.
            </Text>
          )}
        </View>
      </ScrollView>
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  safeArea: {
    flex: 1,
    backgroundColor: '#F2F2F7',
  },
  scrollView: {
    flex: 1,
  },
  scrollContent: {
    paddingBottom: 40,
  },
  container: {
    flex: 1,
    padding: 20,
  },
  title: {
    fontSize: 32,
    fontWeight: '700',
    color: '#000',
    textAlign: 'center',
    marginTop: 20,
  },
  subtitle: {
    fontSize: 14,
    color: '#8E8E93',
    textAlign: 'center',
    marginBottom: 24,
  },
  card: {
    backgroundColor: '#FFFFFF',
    borderRadius: 12,
    padding: 16,
    marginBottom: 16,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.1,
    shadowRadius: 4,
    elevation: 2,
  },
  cardTitle: {
    fontSize: 16,
    fontWeight: '600',
    color: '#000',
    marginBottom: 12,
  },
  statusRow: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    paddingVertical: 6,
  },
  statusLabel: {
    fontSize: 15,
    color: '#3C3C43',
  },
  statusValue: {
    fontSize: 15,
    fontWeight: '600',
    color: '#000',
  },
  section: {
    marginBottom: 16,
    gap: 10,
  },
  sectionTitle: {
    fontSize: 13,
    fontWeight: '600',
    color: '#8E8E93',
    textTransform: 'uppercase',
    marginBottom: 4,
    marginLeft: 4,
  },
  button: {
    borderRadius: 12,
    paddingVertical: 14,
    paddingHorizontal: 20,
    alignItems: 'center',
  },
  primaryButton: {
    backgroundColor: '#007AFF',
  },
  timerButton: {
    backgroundColor: '#FF6B6B',
  },
  alarmButton: {
    backgroundColor: '#34C759',
  },
  dailyButton: {
    backgroundColor: '#FF9500',
  },
  bellsButton: {
    backgroundColor: '#4ECDC4',
  },
  stopButton: {
    backgroundColor: '#8E8E93',
  },
  stopAllButton: {
    backgroundColor: '#FF3B30',
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
  tipText: {
    fontSize: 14,
    color: '#3C3C43',
    marginBottom: 4,
  },
  note: {
    fontSize: 13,
    color: '#FF9500',
    textAlign: 'center',
    marginTop: 8,
  },
});