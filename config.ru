require 'rack'
require 'webmock'
require './lib/televideo/server'

VCR.configure do |config|
  config.cassette_library_dir = 'doc/cassettes'
  config.hook_into :webmock
end

cassette = ENV['TELEVIDEO_CASSETTE']
uri = ENV['TELEVIDEO_URI']

run Televideo::Server.new(
  cassette: cassette,
  uri: uri,
  https: true,
  vcr_options: { record: :all }
)
