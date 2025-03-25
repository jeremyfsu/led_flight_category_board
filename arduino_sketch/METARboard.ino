#include <ESP8266WiFi.h>
#include <PubSubClient.h>
#include <Adafruit_NeoPixel.h>

#define LED_PIN D4
#define NUM_LEDS 50

const char* ssid = "MYSSID";
const char* password = "MYKEY";
const char* mqtt_server = "192.168.1.4";
const int mqtt_port = 1883;
const char* mqtt_topic = "led/control";

WiFiClient espClient;
PubSubClient client(espClient);
Adafruit_NeoPixel strip = Adafruit_NeoPixel(NUM_LEDS, LED_PIN, NEO_GRB + NEO_KHZ800);

void setup_wifi() {
  delay(10);
  Serial.println();
  Serial.print("Connecting to ");
  Serial.println(ssid);

  WiFi.begin(ssid, password);

  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.print(".");
  }

  Serial.println("");
  Serial.println("WiFi connected");
  Serial.println("IP address: ");
  Serial.println(WiFi.localIP());
}

void callback(char* topic, byte* payload, unsigned int length) {
  String message = "";
  for (int i = 0; i < length; i++) {
    message += (char)payload[i];
  }
  
  int led_number, r, g, b;
  sscanf(message.c_str(), "%d,%d,%d,%d", &led_number, &r, &g, &b);
  
  if (led_number >= 0 && led_number < NUM_LEDS) {
    strip.setPixelColor(led_number, strip.Color(r, g, b));
    strip.show();
  }
}

void reconnect() {
  while (!client.connected()) {
    Serial.print("Attempting MQTT connection...");
    if (client.connect("METARBoard")) {
      Serial.println("connected");
      client.subscribe(mqtt_topic);
    } else {
      Serial.print("failed, rc=");
      Serial.print(client.state());
      Serial.println(" try again in 5 seconds");
      delay(5000);
    }
  }
}

void setup() {
  Serial.begin(115200);
  setup_wifi();
  client.setServer(mqtt_server, mqtt_port);
  client.setCallback(callback);
  
  strip.begin();
  strip.show();
}

void loop() {
  if (!client.connected()) {
    reconnect();
  }
  client.loop();
}

