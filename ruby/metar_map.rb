#!/usr/bin/ruby
require 'net/http'
require 'json'
require 'time'
require 'mqtt'

MQTT_SERVER="192.168.1.4"

led_station_map = {
  'KBNA' => 0,
  'KCKV' => 3,
  'KEOD' => 4,
  'KHOP' => 5,
  'KBWG' => 8,
  'KSME' => 15,
  'KLEX' => 19,
  'KLOU' => 22,
  'KJVY' => 23,
  'KSDF' => 24,
  'KOWB' => 29,
  'KEVV' => 31,
  'KHUF' => 36,
  'KBMG' => 38,
  'KIND' => 41,
  'KCVG' => 46,
  'KDAY' => 49
}

category_rgb_map = {
  'VFR' => {'r'=>0,'g'=>200,'b'=>0},
  'IFR' => {'r'=>200,'g'=>0,'b'=>0},
  'MVFR' => {'r'=>0,'g'=>0,'b'=>200},
  'LIFR' => {'r'=>200,'g'=>0,'b'=>200}
}


def get_metar_data(station_id, hours = 1)
  base_url = 'https://aviationweather.gov/api/data'
  endpoint = '/metar'
  
  uri = URI("#{base_url}#{endpoint}")
  params = {
    ids: station_id,
    format: 'json',
    hours: hours
  }
  uri.query = URI.encode_www_form(params)
  
  response = Net::HTTP.get_response(uri)
  
  if response.is_a?(Net::HTTPSuccess)
    JSON.parse(response.body)
  else
    raise "API request failed with status code: #{response.code}"
  end
end

def flight_category(metar_data)
  metar_data["clouds"].each do |layer|
    puts layer.inspect
    if layer["cover"]=="BKN" or layer["cover"]=="OVC"
      if layer["base"].to_i < 500 or metar_data["visib"].to_f < 1
        return "LIFR"
      elsif layer["base"].to_i < 1000 or metar_data["visib"].to_f < 3
        return "IFR"
      elsif layer["base"].to_i < 3000 or metar_data["visib"].to_f < 5
        return "MVFR"
      end
    end
  end

  if metar_data["visib"].to_f < 1
    return "LIFR"
  elsif metar_data["visib"].to_f < 3
    return "IFR"
  elsif metar_data["visib"].to_f < 5
    return "MVFR"
  end
  return "VFR"
end

def publish_to_led_board(client,messages)
  begin
    client.connect
    messages.each do |message|
      client.publish('led/control', message)
    end
  rescue MQTT::Exception => e
    puts "Error: #{e.message}"
  ensure
    client.disconnect if client.connected?
  end
end

client = MQTT::Client.new(MQTT_SERVER)
messages = []
led_station_map.each_key do |station_id|
  metar_data = get_metar_data(station_id)
  if metar_data.empty?
    messages << "#{led_station_map[station_id]},0,0,0"
    puts "No METAR data available for #{station_id}"
  else
    latest_metar = metar_data.first
    puts latest_metar["rawOb"]
    cat = flight_category(latest_metar)
    puts cat
    r = category_rgb_map[cat]["r"]
    g = category_rgb_map[cat]["g"]
    b = category_rgb_map[cat]["b"]
    messages << "#{led_station_map[station_id]},#{g},#{r},#{b}"
  end
end
publish_to_led_board(client,messages)

