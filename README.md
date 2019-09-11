# LED Flight Category Display Board
A chart board that hangs on the wall and displays flight category (VFR/IFR) using RGB LEDs

![LED board image](https://raw.githubusercontent.com/jeremyfsu/led_flight_category_board/master/photos/IMG_4538_small.jpg)

Here's my implentation of an idea several other people have already had. Most of the other ones out there use a Raspberry Pi.
I decided to use a $8 NodeMCU board instead. 

## How it works
A cron job runs the nodejs every 15 minutes. This nodejs bit fetches the weather data from the NOAA weather API.
It converts the XML weather data to JSON, and then assigns RGB values to each flight category (IFR(red), VFR(green), LIFR(PURPLE), 
MVFR(blue). It also converts the station IDs to a number representing which LED on the light board/map corresponds to that airport.
The LED board uses a WS2812 strip of RGB LEDs, and the NodeMCU board can address each LED by number, 1 being the first LED on the strip,
2 being the second, etc. The nodejs publishes messages to a topic on a MQTT broker. Each message is a JSON object with the LED number, and 
the RGB values.

The NodeMCU board has a Lua script running on it that connects it to WiFi, and connects it to the MQTT broker and subscribes it to the 
topic the NodeJS is publishing to. As each message arrives, the NodeMCU board passes this to the WS2812 buffer.

All of this could have easily been done in Lua or in C on the NodeMCU board.  That would certainly be a more compact and self contained
solution. However, I thought it would be nice to only have to change the the nodejs if I want to change
what data is displayed on the board. Lets say I want to change the colors to represent wind, or visibility. I can change the 
nodejs and not have to plug the LED Board up to a USB port on a computer to re-flash the NodeMCU chip with a new Lua script.

I used [NodeMCU build](https://nodemcu-build.com) to compile the NodeMCU firmware and included the following modules: file, gpio, mqtt, net, node, sjson, tmr, uart, wifi, ws2812. I made use of [ESPTool](https://github.com/espressif/esptool) to upload the firmware to the NodeMCU chip and [NodeMCU-uploader](https://github.com/kmpm/nodemcu-uploader) to upload the LUA file to the chip.
