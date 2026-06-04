#include <ESP8266WiFi.h>
#include <MFRC522.h>
#include <SPI.h>
#include <Firebase_ESP_Client.h>
#include <addons/TokenHelper.h>
#include <DHT.h>
#include <time.h>
#include <NTPClient.h>
#include <WiFiUdp.h>
#include <secrets.h>



// Pin Definitions
#define SS_PIN D4    // RFID SS
#define RST_PIN D0   // RFID RST
#define PIR_PIN D8     // PIR Sensor
#define LDR_PIN A0     // Light Sensor
#define LED_RFID D1    // RFID Status LED (Red)
#define LED_PIR_LDR D2 // PIR/LDR Control LED (Green)
#define DHT_PIN D3     // DHT11 Sensor (moved from D5)
#define BUZZER_PIN D9 // Buzzer (moved from D6)
#define DHT_TYPE DHT11 // DHT11 sensor type

// Thresholds and Intervals
#define LDR_DARK_THRESHOLD 300  // Below this = dark
#define LED_TIMEOUT 10000       // 10 seconds auto-off for PIR/LDR LED
#define TEMP_THRESHOLD 31       // Temperature threshold (31°C)
#define BUZZER_DURATION 5000    // Buzzer sounds for 5 seconds
#define UPDATE_INTERVAL 1000    // Send data every 1 second

// Firestore Paths
#define STATUS_PATH "status"
#define LIGHT_PATH "light/value"
#define MOTION_PATH "motion/value"
#define TEMP_PATH "temperature/value"
#define HUMIDITY_PATH "humidity/value"
#define RFID_LOGS_PATH "rfid_logs"
#define TEMP_LOGS_PATH "dht11_data/temperature_logs"
#define NOTIFICATIONS_PATH "notifications/latest"

// Objects
MFRC522 rfid(SS_PIN, RST_PIN);
DHT dht(DHT_PIN, DHT_TYPE);
FirebaseData fbdo;
FirebaseAuth auth;
FirebaseConfig config;
WiFiUDP ntpUDP;
NTPClient timeClient(ntpUDP, "pool.ntp.org");

// Variables
String uid = "";
unsigned long lastMotionTime = 0;
bool ledPirState = false;
bool lastMotionState = false;
bool lastTempHigh = false;
unsigned long buzzerStartTime = 0;
bool buzzerActive = false;

void setup() {
  Serial.begin(115200);
  
  // Initialize pins
  pinMode(LED_RFID, OUTPUT);
  pinMode(LED_PIR_LDR, OUTPUT);
  pinMode(PIR_PIN, INPUT);
  pinMode(BUZZER_PIN, OUTPUT);
  digitalWrite(LED_RFID, LOW);
  digitalWrite(LED_PIR_LDR, LOW);
  digitalWrite(BUZZER_PIN, LOW);

  // Initialize RFID and DHT
  SPI.begin();
  rfid.PCD_Init();
  dht.begin();

  // Connect to WiFi
  WiFi.begin(WIFI_SSID, WIFI_PASSWORD);
  Serial.print("Connecting to WiFi");
  while (WiFi.status() != WL_CONNECTED) {
    Serial.print(".");
    delay(300);
  }
  Serial.println("\n✅ WiFi Connected");
  Serial.print("IP Address: ");
  Serial.println(WiFi.localIP());

  // Initialize NTP time client
  timeClient.begin();
  timeClient.update();
  configTime(0, 0, "pool.ntp.org");
  Serial.println("⌚ Waiting for NTP time sync...");
  
  time_t now = time(nullptr);
  while (now < 100000) {
    delay(500);
    now = time(nullptr);
  }
  Serial.printf("✅ Time synchronized: %s", ctime(&now));

  // Initialize Firebase
  config.api_key = API_KEY;
  auth.user.email = USER_EMAIL;
  auth.user.password = USER_PASSWORD;
  config.token_status_callback = tokenStatusCallback;
  
  Firebase.begin(&config, &auth);
  Firebase.reconnectWiFi(true);
  Serial.println("🔥 Firebase Initialized");
}

void loop() {
  // Handle PIR/LDR system
  handlePIRLDR();
  
  // Handle RFID system
  handleRFID();

  // Handle DHT11 and buzzer
  handleDHT();

  delay(100);
}

void handlePIRLDR() {
  int ldrValue = analogRead(LDR_PIN);
  bool currentMotion = digitalRead(PIR_PIN);
  bool isDark = ldrValue < LDR_DARK_THRESHOLD;

  // LED Control (Green LED)
  if (currentMotion && isDark) {
    digitalWrite(LED_PIR_LDR, HIGH);
    ledPirState = true;
    lastMotionTime = millis();
  } 
  else if (ledPirState && (millis() - lastMotionTime > LED_TIMEOUT)) {
    digitalWrite(LED_PIR_LDR, LOW);
    ledPirState = false;
  }

  // Send data to Firebase
  static unsigned long lastUpdate = 0;
  if (millis() - lastUpdate > UPDATE_INTERVAL) {
    lastUpdate = millis();
    
    if (currentMotion != lastMotionState) {
      sendToFirebase(MOTION_PATH, currentMotion);
      lastMotionState = currentMotion;
    }
    
    sendToFirebase(LIGHT_PATH, ldrValue);
    
    Serial.print("🌤 LDR: ");
    Serial.print(ldrValue);
    Serial.print(" | 🚶 PIR: ");
    Serial.println(currentMotion ? "MOTION" : "NO MOTION");
  }
}

void handleRFID() {
  if (!rfid.PICC_IsNewCardPresent() || !rfid.PICC_ReadCardSerial()) return;

  // Read UID
  uid = "";
  for (byte i = 0; i < rfid.uid.size; i++) {
    uid += String(rfid.uid.uidByte[i] < 0x10 ? "0" : "");
    uid += String(rfid.uid.uidByte[i], HEX);
    if (i < rfid.uid.size - 1) uid += ":";
  }
  uid.toUpperCase();

  Serial.print("🆔 RFID UID: ");
  Serial.println(uid);

  if (uid == "CB:C8:D1:CF") { // Authorized UID
    Serial.println("✅ Access granted");
    digitalWrite(LED_RFID, HIGH); // Red LED ON
    delay(3000);
    digitalWrite(LED_RFID, LOW);  // Red LED OFF
    logRFIDAccess(true);
    updateLatestNotification("RFID Scan", "UID: " + uid + " - Access granted");
  } else {
    Serial.println("❌ Access denied");
    logRFIDAccess(false);
    updateLatestNotification("RFID Scan", "UID: " + uid + " - Access denied");
  }

  rfid.PICC_HaltA();
  rfid.PCD_StopCrypto1();
}

void handleDHT() {
  // Read DHT11 sensor
  float temperature = dht.readTemperature();
  float humidity = dht.readHumidity();

  // Check if readings are valid
  if (isnan(temperature) || isnan(humidity)) {
    Serial.println("❌ Failed to read from DHT11 sensor!");
    delay(2000);
    return;
  }

  // Print sensor values
  Serial.print("🌡️ Temperature: ");
  Serial.print(temperature);
  Serial.print("°C | 💧 Humidity: ");
  Serial.print(humidity);
  Serial.println("%");

  // Control buzzer (non-blocking)
  bool tempHigh = temperature > TEMP_THRESHOLD;
  if (tempHigh && !lastTempHigh) {
    Serial.println("🚨 Activating buzzer on pin " + String(BUZZER_PIN));
    digitalWrite(BUZZER_PIN, HIGH);
    buzzerStartTime = millis();
    buzzerActive = true;
    updateLatestNotification("High Temperature Alert", "Temperature exceeded 31°C: " + String(temperature) + "°C");
  } else if (!tempHigh && lastTempHigh) {
    updateLatestNotification("Temperature Update", "Temperature normal: " + String(temperature) + "°C");
  }

  if (buzzerActive && (millis() - buzzerStartTime >= BUZZER_DURATION)) {
    digitalWrite(BUZZER_PIN, LOW);
    buzzerActive = false;
    Serial.println("🔇 Buzzer turned off");
  }

  lastTempHigh = tempHigh;

  // Send data to Firebase and log temperature
  static unsigned long lastUpdate = 0;
  if (millis() - lastUpdate > UPDATE_INTERVAL) {
    lastUpdate = millis();
    sendToFirebase(TEMP_PATH, temperature);
    sendToFirebase(HUMIDITY_PATH, humidity);
    logTemperature(temperature, humidity, tempHigh ? "High" : "Normal");
  }
}

void sendToFirebase(const String &subpath, int value) {
  String documentPath = String(STATUS_PATH) + "/" + subpath.substring(0, subpath.lastIndexOf('/'));
  String fieldName = subpath.substring(subpath.lastIndexOf('/') + 1);
  
  FirebaseJson content;
  content.set("fields/" + fieldName + "/integerValue", String(value));
  
  if (Firebase.Firestore.patchDocument(&fbdo, FIREBASE_PROJECT_ID, "", documentPath.c_str(), content.raw(), fieldName.c_str())) {
    Serial.println("📤 " + subpath + " updated");
  } else {
    Serial.println("❌ " + subpath + " update error: " + fbdo.errorReason());
  }
}

void sendToFirebase(const String &subpath, bool value) {
  String documentPath = String(STATUS_PATH) + "/" + subpath.substring(0, subpath.lastIndexOf('/'));
  String fieldName = subpath.substring(subpath.lastIndexOf('/') + 1);
  
  FirebaseJson content;
  content.set("fields/" + fieldName + "/booleanValue", value);
  
  if (Firebase.Firestore.patchDocument(&fbdo, FIREBASE_PROJECT_ID, "", documentPath.c_str(), content.raw(), fieldName.c_str())) {
    Serial.println("📤 " + subpath + " updated");
  } else {
    Serial.println("❌ " + subpath + " update error: " + fbdo.errorReason());
  }
}

void sendToFirebase(const String &subpath, float value) {
  String documentPath = String(STATUS_PATH) + "/" + subpath.substring(0, subpath.lastIndexOf('/'));
  String fieldName = subpath.substring(subpath.lastIndexOf('/') + 1);

  FirebaseJson content;
  content.set("fields/" + fieldName + "/doubleValue", String(value, 2));

  if (Firebase.Firestore.patchDocument(&fbdo, FIREBASE_PROJECT_ID, "", documentPath.c_str(), content.raw(), fieldName.c_str())) {
    Serial.println("📤 " + subpath + " updated");
  } else {
    Serial.println("❌ " + subpath + " update error: " + fbdo.errorReason());
  }
}

void logRFIDAccess(bool granted) {
  String path = RFID_LOGS_PATH;
  FirebaseJson content;
  content.set("fields/uid/stringValue", uid);
  content.set("fields/status/stringValue", granted ? "granted" : "denied");
  content.set("fields/timestamp/timestampValue", getISO8601Timestamp());
  
  if (Firebase.Firestore.createDocument(&fbdo, FIREBASE_PROJECT_ID, "", path.c_str(), content.raw())) {
    Serial.println("📝 RFID log saved");
  } else {
    Serial.println("❌ RFID log error: " + fbdo.errorReason());
  }
}

void logTemperature(float temperature, float humidity, String status) {
  String timestamp = getISO8601Timestamp().substring(0, 19);
  timestamp.replace(":", "");
  String documentId = "dht_reading_" + timestamp;
  String documentPath = String(TEMP_LOGS_PATH) + "/" + documentId;

  FirebaseJson content;
  content.set("fields/temperature/doubleValue", String(temperature, 2));
  content.set("fields/humidity/doubleValue", String(humidity, 2));
  content.set("fields/status/stringValue", status);
  content.set("fields/timestamp/timestampValue", getISO8601Timestamp());

  if (Firebase.Firestore.createDocument(&fbdo, FIREBASE_PROJECT_ID, "", documentPath.c_str(), content.raw())) {
    Serial.println("📝 Temperature log saved: T=" + String(temperature) + "°C, H=" + String(humidity) + "%, Status=" + status);
  } else {
    Serial.println("❌ Temperature log error: " + fbdo.errorReason());
  }
}

void updateLatestNotification(String title, String message) {
  FirebaseJson content;
  content.set("fields/title/stringValue", title);
  content.set("fields/message/stringValue", message);
  content.set("fields/timestamp/timestampValue", getISO8601Timestamp());

  String updateMask = "title,message,timestamp";
 
  if (Firebase.Firestore.patchDocument(&fbdo, FIREBASE_PROJECT_ID, "", NOTIFICATIONS_PATH, content.raw(), updateMask.c_str())) {
    Serial.println("🔔 Latest notification updated: " + message);
    Serial.println("🕒 Timestamp: " + getISO8601Timestamp());
  } else {
    Serial.println("❌ Notification error: " + fbdo.errorReason());
  }
}

String getISO8601Timestamp() {
  time_t now = time(nullptr);
  struct tm *tm_struct = gmtime(&now);
  char buf[25];
  strftime(buf, sizeof(buf), "%Y-%m-%dT%H:%M:%SZ", tm_struct);
  return String(buf);
}
