#!/usr/bin/env ruby

###############################################################################
#                                                                             #
# Ugly ass hack of a Ruby implementation for a DigitalOcean dynamic inventory #
#                                                                             #
###############################################################################

require 'barge'

barge = Barge::Client.new( access_token: ENV['DO_TOKEN'] )

result = Hash.new do |hash, key|
  hash[key] = {
    "hosts" => Array.new,
    "vars" => Hash.new,
  }
end
result["_meta"] = Hash.new
result["_meta"]["hostvars"] = Hash.new{ |hash, key| hash[key] = {} }


response = barge.droplet.all
response.droplets.each do |droplet|
  _, group, name = droplet.name.split( /([^-]+)-(.+)/ )
  ip_address = droplet.networks.v4[0].ip_address

  result[group]["hosts"] << ip_address
  result["_meta"]["hostvars"][ip_address].tap do |meta|
    meta["created_at"] = droplet.created_at
    meta["disk"] = droplet.disk
    meta["memory"] = droplet.memory
    meta["features"] = droplet.features
    meta["id"] = droplet.id
    meta["kernel"] = droplet.kernel
  end
end

puts result.to_json