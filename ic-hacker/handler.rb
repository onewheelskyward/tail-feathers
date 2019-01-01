require 'json'
require 'faye/websocket'

require 'eventmachine'

# API='wss://api.icecondor.com/v2'
# EM.run {
#   ws = Faye::WebSocket::Client.new(API)
#
#   ws.on :open do |event|
#     p [:open, API]
#   end
#
#   ws.on :message do |event|
#     data = JSON.parse(event.data)
#     p data
#     if data['method'] == "hello"
#       query = {"id":"abc123", "method":"stream.follow", "params":{
#           "username":"donpdonp", "key":"62ced315-6832-4f7a",
#           "count":86400 , "start":"2018-12-24", "stop":"2018-12-25"}}
#       ws.send(query.to_json)
#     end
#   end
#
#   ws.on :close do |event|
#     p [:close, event.code, event.reason]
#     ws = nil
#   end
# }

EM.run {
  ws = Faye::WebSocket::Client.new('wss://api.icecondor.com/v2')

  # ws.on :open do |event|
  #   p [:open, API]
  # end
  ws.on :open do |event|
    p [:open]
  end

  ws.on :message do |event|
    # puts "Got message"
    # puts event.data
    data = JSON.parse(event.data)
    # puts "Data: #{data}"

    # Set up the query on the first call
    if data['method'] == "hello"
      puts "Sending query"
      x = ws.send({id: "abc123",
                  method: "stream.follow",
                  params: {"username": "onewheelskyward",
                           "key": "758d2d2b-532b-456b",
                           "count": 86400,
                           "start": "2018-12-24",
                           "stop": "2018-12-25"}}.to_json)
    else
      result = data['result']
      stored = {type: "location",
                geometry: {
                    type: 'Point',
                    coordinates: [result['longitude'], result['latitude']]
                },
                properties: {
                    date: result['date'],
                    device_id: result['device_id'],
                    latitude: result['latitude'],
                    longitude: result['longitude'],
                    accuracy: result['accuracy'],
                    provider: result['provider']
                }
      }
      puts stored.inspect
    end

  end

  ws.on :close do |event|
    puts event.inspect
    p [:close, event.code, event.reason]
    ws = nil
  end

  ws.on :error do |event|
    puts event.inspect
  end
}

# {"id"=>"86049104",
#  "result"=>{
#      "id"=>"f8718451-fb6f-4d9d-bc13-1e952d3b3071",
#      "type"=>"location",
#      "date"=>"2018-12-24T03:10:06Z",
#      "received_at"=>"2018-12-24T03:11:19.585Z",
#      "user_id"=>"3d70ee38-73a7-400a-a75f-baed60276d77",
#      "device_id"=>"device-2017oct30-overland",
#      "latitude"=>45.46709385015362,
#      "longitude"=>-122.63365200796616,
#      "accuracy"=>65,
#      "provider"=>"network"}
# }

# {
#     "type": "Feature",
#     "geometry": {
#         "type": "Point",
#         "coordinates": [
#             -75.51125798179997,
#             40.61615910836146
#         ]
#     },
#     "properties": {
#         "speed": 0,
#         "battery_state": "unplugged",
#         "motion": [
#             "stationary"
#         ],
#         "timestamp": "2018-12-25T05:00:18Z",
#         "battery_level": 0.46000000834465027,
#         "vertical_accuracy": 3,
#         "pauses": true,
#         "horizontal_accuracy": 32,
#         "wifi": "☃",
#         "deferred": 100,
#         "significant_change": 1,
#         "locations_in_payload": 1,
#         "activity": "fitness",
#         "device_id": "iphoneX",
#         "altitude": 121,
#         "desired_accuracy": -1
#     }
# },
