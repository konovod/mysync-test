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
