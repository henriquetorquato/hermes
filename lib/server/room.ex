defmodule Room do
  use Agent

  def init(name) do
    Process.flag(:trap_exit, true)
    loop([])
  end

  def loop(users) do
    receive do
      { :join, user, username } ->
        Node.connect user
        users = [{username, user} | users]
        broadcast(username, format_join(username), users)
        loop(users)
      { :message, username, content } ->
        IO.puts content
        broadcast(username, content, users)
        loop(users)
    end
  end

  defp broadcast(username, content, users) do
    Enum.each users, fn {_username, user} -> Node.spawn_link user,
      fn -> User.receive_message username, content end
    end
  end

  defp format_join(username) do
    "> User '#{username}' joined!"
  end

end
