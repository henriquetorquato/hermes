defmodule Server.Supervisor do
  use Supervisor

  def init(args) do
    {:ok, args}
  end

  def start(address) do
    start_node(address)

    children = [
      {Task.Supervisor, name: Server.TaskSupervisor},
      {Server, [address]}
    ]

    Supervisor.start_link children, [strategy: :one_for_all, name: __MODULE__, debug: [:trace]]
    IO.puts "> Server supervisor started"
  end

  def stop do
    Supervisor.stop __MODULE__, :shutdown
  end

  def start_link(args) do
    Supervisor.start_link __MODULE__, args
  end

  def start_node(address) do
    node = String.to_atom "server@#{address}"
    Node.start node
    IO.puts "> Node started as '#{node}'"
    node
  end

  def spawn_client_task(recipient, name, args) do
    {User.TaskSupervisor, recipient}
    |> Task.Supervisor.async(User, name, args)
    |> Task.await
  end

end
