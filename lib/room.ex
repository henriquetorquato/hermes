defmodule Room do
  use Agent

  def init(users) do
    Process.flag(:trap_exit, true)
    loop(users)
  end

  def loop(users) do
    receive do
      { :join, user } ->
        loop([user | users])
      { :message, username, content } ->
        broadcast(username, content, users)
        loop(users)
    end
  end

  defp broadcast(username, content, users) do
    Enum.each users, fn user -> send user, { :message, username, content } end
  end

end
