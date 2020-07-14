defmodule User do
  use Agent

  def init(username, address, room) do
    server = {:server, address}
    Node.connect(address)

    send server, {:join, username, room}
    loop(username, server, room)
  end

  def connect(username, address, room) do
    spawn(User, :init, [username, address, room])
  end

  def loop(username, server, room) do
    receive do
      { :info, content } ->
        IO.puts content
        loop(username, server, room)
      { :message, originator, content } ->
        IO.puts  ~s{[#{username}] #{originator}> #{content}}
        loop(username, server, room)
      { :send, content } ->
        send server, { :message, room, username, content }
        loop(username, server, room)
      :disconnect ->
        exit(0)
    end
  end

end
