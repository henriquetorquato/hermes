defmodule User do
  use Agent

  def init(username, server, room) do
    Process.flag(:trap_exit, true)
    send server, { :join, self(), room }
    loop(username, server, room)
  end

  def connect(username, server, room) do
    spawn(User, :init, [username, server, room])
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
