const ledStationMap = {
  KBNA: 1,
  KCKV: 4,
  KEOD: 5,
  KHOP: 6,
  KBWG: 9,
  KSME: 16,
  KLEX: 20,
  KLOU: 23,
  KJVY: 24,
  KSDF: 25,
  KOWB: 30,
  KEVV: 32,
  KHUF: 37,
  KBMG: 39,
  KIND: 42,
  KCVG: 47,
  KDAY: 50
};
const flightCategoryColorMap = {
  VFR: {r:0,g:200,b:0},
  MVFR: {r:0,g:0,b:200},
  IFR: {r:200,g:0,b:0},
  LIFR: {r:100,g:0,b:100}
};
const axios = require('axios');
const parseString = require('xml2js').parseString;
const port = 80;
const mqtt = require('mqtt');
const client  = mqtt.connect('mqtt://localhost');

client.on('connect', function () {
  console.log("Connected to MQTT broker");
  axios.get('https://www.aviationweather.gov/adds/dataserver_current/httpparam',
    { params: { 
      dataSource: 'metars',
      requestType: 'retrieve',
      format: 'xml',
      hoursBeforeNow: 3,
      mostRecentForEachStation: 'constraint',
      stationString: Object.keys(ledStationMap).toString()
    }
    }).then(function(result) {
      if(result.status==200) {
        console.log("fetch from NOAA good");
        parseString(result.data, function (err, json) {
          json.response.data[0].METAR.forEach(function(s) {
            var message = {
              led: ledStationMap[s.station_id[0]]
            };
            Object.assign(message, flightCategoryColorMap[s.flight_category[0]]);
            
            client.publish('weathermap/update', 
              JSON.stringify(message),
              {},
              function(err) {
                if(err) {console.log("err:"+err);}
                else {console.log("msg sent");}
              });
          });
          client.end();
        });
      }
      else {
        client.end();
        console.log("Error "+result.status+" fetching from NOAA");
      }
    });
});

client.on('close', function () {
  console.log("Disconnected from MQTT broker");
});
