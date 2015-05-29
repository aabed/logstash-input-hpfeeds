# encoding: utf-8
require "logstash/inputs/base"
require "logstash/namespace"
# This input allows you to receive events over hpfeeds.

class LogStash::Inputs::Hpfeeds < LogStash::Inputs::Base

  config_name "hpfeeds"

  default :codec, "plain"

  # The identity for your hpfeeds broker.
  config :ident, :validate => :string, :required => :true

  # The hpfeeds secret for the user/identity.
  config :secret, :validate => :password, :required => :true

  # channels to subscribe to on hpfeeds
  config :channels, :validate => :array

  # The brokker hostname/IP
  config :host, :validate => :string
  # The port the broker is listening to
  config :port, :validate => :number

 


  public
  def register
    require 'hpfeeds' # xmpp4r gem
    @client = HPFeeds::Client.new({
    host:   @host,
    port:   @port,  # default is 10000
    ident:  @ident,
    secret: @secret.value  })
  end # def register

  public
#  def run(queue)do |name, chan, payload|
	def run(queue)
  	@client.subscribe(*@channels)  do |name, chan, payload|
    	@codec.decode(payload) do |event|
      	decorate(event)
        event["message"] = payload
        event["host"] = @host
        event["chan"] = chan
        event["name"] = name
  	end
	end
	@client.run()
  end # def run

end # class LogStash::Inputs::Xmpp


