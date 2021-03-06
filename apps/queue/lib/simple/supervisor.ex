defmodule Queue.Simple.Queue.Supervisor do
  use Supervisor

  def start_link do
    Supervisor.start_link(__MODULE__, :ok)
  end

  def init(:ok) do
    children = [
      worker(Queue.Simple.Queue, [[], [name: Queue.Simple.Queue]])
    ]

    supervise(children, strategy: :one_for_one)
  end
end
