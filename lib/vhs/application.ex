defmodule Vhs.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  alias Vhs.DataStore.TransactionStore
  alias Vhs.Domain.Transaction

  @impl true
  def start(_type, _args) do
    initialize_configuration()

    children = [
      {Plug.Cowboy, scheme: :http, plug: Vhs.Router, options: [port: 4000]}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Vhs.Supervisor]
    Supervisor.start_link(children, opts)
  end

  def init(_args) do
  end

  defp initialize_configuration do
    TransactionStore.create_table()
    {:ok, _tref} = :timer.apply_interval(3000, Transaction, :check_pendings, [])
  end
end
