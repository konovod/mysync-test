require "cannon"

struct TestClientInput
  include Cannon::Auto
  property num : Int32
  property data : String

  def initialize
    @num = -1
    @data = ""
  end

  def initialize(@num, @data)
  end
end

struct TestServerOutput
  include Cannon::Auto
  property all_data

  def initialize
    @all_data = StaticArray(String, 16).new("")
  end

  def initialize(@all_data)
  end
end

macro solve_bug

  def process_receive(data)
    super
  end

  def process_sending
    super
  end

  def local_seq=(value)
    super
  end

  def remote_seq=(value)
    super
  end

  def local_seq
    super
  end

  def remote_seq
    super
  end

end
