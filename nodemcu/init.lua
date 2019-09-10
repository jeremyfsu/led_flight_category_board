ws2812.init()
buffer = ws2812.newBuffer(50,3)
buffer:fill(255,0,0)
ws2812.write(buffer)

print("connecting to wifi")
station_cfg={}
station_cfg.ssid="XXXXXXXXX"
station_cfg.pwd="XXXXXXXXXX"
station_cfg.save=true
wifi.setmode(wifi.STATION)
wifi.sta.config(station_cfg)

m = mqtt.Client("weathermap", 120)

m:on("connect", function(client) 
  print ("connected to mqtt broker")
  buffer:fill(0,0,0)
  ws2812.write(buffer)
  client:subscribe("weathermap/update", 0, function(client) print("subscribed to topic") end)
end)

m:on("message", function(client, topic, data)
  if data ~= nil then
    station = sjson.decode(data)
    buffer:set(station.led,station.r,station.g,station.b)
  end
  ws2812.write(buffer)
end)

wifi.eventmon.register(wifi.eventmon.STA_GOT_IP, function(T)
  print(wifi.sta.getip())
  buffer:fill(0,255,0)
  ws2812.write(buffer)
  m:connect("192.168.1.4", 1883, 0) 
end)
