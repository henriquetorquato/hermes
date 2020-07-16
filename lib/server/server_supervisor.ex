defmodule Server.Supervisor do
  use Supervisor

  def init(args) do
    {:ok, args}
  end

  def start(address) do
    start_node(address)

    children = [
      {Task.Supervisor, name: Server.TaskSupervisor},
      {Server, []}
    ]

    Supervisor.start_link children, [strategy: :one_for_all, debug: [:trace]]
    IO.puts "> Server supervisor started"
  end

  def start_node(address) do
    node = String.to_atom "server@#{address}"
    Node.start node
    IO.puts "> Node started as '#{node}'"
    node
  end

  def create_room(name) do
    Supervisor.start_child Server.Supervisor, {Room, [name]}
  end

  def spawn_remote_task(module, recipient, name, args) do
    {Server.TaskSupervisor, recipient}
    |> Task.Supervisor.async(module, name, args)
    |> Task.await
  end

end
