# LED Flight Category Display Board
A chart board that hangs on the wall and displays flight category (VFR/IFR) using RGB LEDs

![LED board image](https://raw.githubusercontent.com/jeremyfsu/led_flight_category_board/master/photos/IMG_4538_small.jpg)

Here's my implentation of an idea several other people have already had. Most of the other ones out there use a Raspberry Pi.
I decided to use a $8 ESP8266 board instead. 

## How it works
A cronjob on my home Linux pc runs the the ruby script metar_map.rb every 5 minutes. This script fetches the weather data from the NOAA weather API.
It determines flight category from the ceiling height and visibility. Then it assigns RGB values to each flight category (IFR(red), VFR(green),
LIFR(purple), 
MVFR(blue). It also converts the station IDs to a number representing which LED on the light board/map corresponds to that airport.
The LED board uses a WS2812 strip of RGB LEDs, and the ESP8266 board can address each LED by number, 1 being the first LED on the strip,
2 being the second, etc. The ruby script publishes messages to a topic on a MQTT broker. Each message is a JSON object with the LED number, and 
the RGB values.

The ESP8266 board uses wifi and subscribes to the 
topic that the ruby script is publishing to. As each message arrives the ESP8266 board assigns each WS2812 LED it's RGB values.

The ESP8266 is more than capable of doing the job the ruby script does of
fetching the data from the NOAA API.
However, I thought it would be nice to only have to change the ruby if I want to change
what data is displayed on the board. Lets say I want to change the colors to represent wind, or visibility. I can change the 
ruby and not have to plug the LED Board up to a USB port on a computer to re-flash the ESP8266 with new code.

I'm a command line guy, so I used arduino-cli to compile the sketch and flash
the ESP8226 with the compiled code.
