defmodule Room do
  use Agent

  def init(_args) do
    []
  end

  def start_link(name) do
    Agent.start_link __MODULE__, :init, [name], name: String.to_atom name
  end

  def join(pid, node, username) do
    Node.connect node
    Agent.update pid, fn users -> [{username, node} | users] end

    broadcast pid, %Message{
      type: "info",
      content: "User '#{username}' joined!",
      originator: username
    }
  end

  def broadcast(pid, message) do
    users = not_user message.originator, get_users pid
    case message.type do
      "message" ->
        broadcast pid, message, users
      "info" ->
        broadcast pid, message, users
    end
  end

  def broadcast(_pid, message, users) do
    Enum.each users, fn {_username, node} ->
      send_message node, message
    end
  end

  defp get_users(pid) do
    Agent.get pid, fn users -> users end
  end

  defp not_user(username, users) do
    Enum.filter users, fn {name, _node} -> username != name end
  end

  defp send_message(node, message) do
    send {:receiver, node}, {:message, message}
  end

end
