defmodule Room.Manager do
  use DynamicSupervisor

  def init(_args) do
    DynamicSupervisor.init strategy: :one_for_one, max_children: 500
  end

  def start_link do
    DynamicSupervisor.start_link __MODULE__, :ok, name: __MODULE__
  end

  def create(name) do
    spec = %{id: String.to_atom(name), start: {Room, :start_link, [name]}}
    DynamicSupervisor.start_child __MODULE__, spec
  end

  def destroy(room) do
    DynamicSupervisor.terminate_child __MODULE__, room
  end

  def get(name) do
    Process.whereis String.to_atom name
  end

  def get_or_create(name) do
    case get name do
      nil ->
        {:ok, room} = create name
        room
      _ ->
        get name
    end
  end

end
