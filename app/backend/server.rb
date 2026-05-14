require 'sinatra'
require 'json'
require 'net/http'

# Listen on all interfaces so EC2 can serve it
set :bind, '0.0.0.0'
set :port, 4567

$ec2_ip = "169.254.169.254"

def get_token()
    uri = URI("http://#{$ec2_ip}/latest/api/token")
    req = Net::HTTP::Put.new(uri)
    req["X-aws-ec2-metadata-token-ttl-seconds"] = "21600"
    Net::HTTP.start(uri.hostname) { |http| http.request(req) }.body
end

def get_metadata(path)
    token = get_token()
    uri = URI("http://#{$ec2_ip}/latest/meta-data/#{path}")
    req = Net::HTTP::Get.new(uri)
    req["X-aws-ec2-metadata-token"] = token
    Net::HTTP.start(uri.hostname) { |http| http.request(req) }.body
end

get '/api/status' do
    content_type :json
    { 
        status: "online", 
        instance: `hostname`.strip 
    }.to_json
end

get '/api/info' do
    content_type :json
    {
        environment: ENV['APP_ENV'],
        instance_id: get_metadata('instance-id'),
        availability_zone: get_metadata('placement/availability-zone'),
        region: get_metadata('placement/region')
    }.to_json
end