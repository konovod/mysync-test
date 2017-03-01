require "./common"
require "mysync/endpoint"
require "mysync/client"

class TestClientEndpoint < MySync::EndPoint(TestClientInput, TestServerOutput)
  property benchmark : Int32 = 0
  property benchmark_udp : MySync::UDPGameClient?
  getter benchmark_complete = Channel(Nil).new

  def on_received_sync
    if @benchmark > 0
      @benchmark -= 1
      if @benchmark == 0
        @benchmark_complete.send(nil)
      else
        @benchmark_udp.not_nil!.send_data
      end
    else
      p "received"
    end
  end

  def before_sending_sync
    p "sending"
  end

  solve_bug
end

cli = TestClientEndpoint.new
udp_cli = MySync::UDPGameClient.new(cli, Socket::IPAddress.new(ARGV[0], 12000))
public = Crypto::PublicKey.new(secret: Crypto::SecretKey.new("c4b12631c3f68e7a72fc760a31ffaae0a7a5f8d892cac43c0d8d06acd1b3fd8e"))
p udp_cli.login(public_key, "it_s_me".to_slice)

cur = Time.now
cli.benchmark = 10000
cli.benchmark_udp = udp_cli
udp_cli.send_data
cli.benchmark_chan.receive
pp (Time.now - cur).to_f/10.0 # *1000 / 10000
pp cli.stat_losses
pp cli.stat_pingtime*1000
