require 'json'
require 'rest-client'
require 'aws-sdk-s3'

def lambda_handler(event:, context:)
  puts event.inspect.to_json

  bj = JSON.parse(event['body'])
  puts "bj: #{bj.inspect}"

  bucket = ENV['bucket']

  count = 0
  bj['locations'].each do |loc|
    t = Time.parse(loc['properties']['timestamp'])
    # Get a 2018-12-25-05 key prefix
    key_prefix = "#{t.year}/#{t.month}/#{t.day}/#{t.hour.to_s.rjust(2, '0')}/"
    # Create the filename
    key = "#{key_prefix}#{loc['type']}-#{loc['properties']['timestamp']}.json"
    # Poop it out.
    put_to_bucket(bucket, key, loc)
    count += 1
  end

  puts "Put #{count} object#{(count == 1)? '': 's'} to bucket #{bucket}"

  # Do a little hack to just save the last loc
  last_loc = bj['locations'].last
  bj['locations'] = []
  bj['locations'].push last_loc

  puts "Modified bj #{bj}"
  puts "Sending last location to teh Condor."
  response = RestClient.post "https://api.icecondor.com/rest/activity/add?token=#{ENV['ic_token']}", bj.to_json

  puts response.inspect
  # puts response.text

  { statusCode: 200, body: '{"result": "ok"}' }
end


def put_to_bucket(bucket, key, payload)
  # Create the client
  s3 = Aws::S3::Resource.new(region: 'us-west-2')
  # And the bucket object
  obj = s3.bucket(bucket).object(key)
  # 💩
  obj.put(body: payload.to_json)
end


# bj['locations'] example
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
