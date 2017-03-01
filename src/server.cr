require "./common"
require "mysync/endpoint"
require "mysync/server"

class TestUserContext < MySync::EndPoint(TestServerOutput, TestClientInput)
  def on_disconnect
    p "user disconnected: #{@user}"
  end

  def on_received_sync
    @server.state.all_data[@remote_sync.num] = @remote_sync.data if @remote_sync.num >= 0
  end

  def before_sending_sync
    @local_sync = @server.state
  end

  solve_bug

  def initialize(@server : TestServer, @user : Int32)
    super()
  end
end

class TestServer
  include MySync::EndPointFactory
  property state = TestServerOutput.new
  getter test_endpoint : MySync::AbstractEndPoint?

  def new_endpoint(authdata : Bytes) : {endpoint: MySync::AbstractEndPoint, response: Bytes}?
    username = String.new(authdata)
    p "logged in: #{username}"
    userid = 2
    point = TestUserContext.new(self, userid)
    @test_endpoint = point
    {endpoint: point, response: "you_can_pass".to_slice}
  end
end

secret_key = Crypto::SecretKey.new("c4b12631c3f68e7a72fc760a31ffaae0a7a5f8d892cac43c0d8d06acd1b3fd8e")
srv = TestServer.new
udp_srv = MySync::UDPGameServer.new(srv, 12000, secret_key)
p "listening"
loop do
  sleep 5
  pp udp_srv.n_clients
end
