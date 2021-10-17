defmodule Vhs.Socket.BlockNative do
  use WebSockex

  require Logger

  @stream_url "wss://api.blocknative.com/v0"

  @moduledoc """
     This is a websocket interface to handle blocknative operations
  """

  @spec start_link() :: GenServer.on_start()
  def start_link do
    WebSockex.start_link(@stream_url, __MODULE__, %{},
      name: __MODULE__,
      async: true,
      handle_initial_conn_failure: true
    )
  end

  def watch_tx(tx_id) do
    WebSockex.cast(self(), {:subscribe, tx_id})
  end

  def handle_connect(_conn, state) do
    Logger.info("Connection established to block_native")
    WebSockex.cast(self(), :initialize)
    {:ok, state}
  end

  def handle_disconnect(_, state) do
    Logger.warn("Connection lost")
    Process.sleep(5_000)
    {:ok, state}
  end

  def handle_frame({:text, body}, state) do
    case Jason.decode(body) do
      {:ok, %{"event" => %{"categoryCode" => "initialize"}}} ->
        {:ok, state}

      _output ->
        {:ok, state}
    end
  end

  def handle_frame(_msg, state) do
    {:ok, state}
  end

  def handle_cast(:initialize, state) do
    initialize = default_message()

    subscription =
      initialize
      |> Map.put_new("categoryCode", "initialize")
      |> Map.put_new("eventCode", "checkDappId")

    frame = {:text, Jason.encode!(subscription)}
    {:reply, frame, state}
  end

  def handle_cast({:subsribe, tx_id}, state) do
    initialize = default_message()
    watch = watch_tx_config(tx_id)
    subscribe = Map.merge(initialize, watch)

    frame = {:text, Jason.encode!(subscribe)}
    {:reply, frame, state}
  end

  def default_message do
    %{
      "timeStamp" => DateTime.to_iso8601(DateTime.now!("Etc/UTC")),
      "dappId" => "fb8af020-039e-436f-895f-ffc09c62a63a",
      "version" => "1",
      "blockchain" => %{
        "system" => "ethereum",
        "network" => "main"
      }
    }
  end

  def watch_tx_config(tx_id) do
    %{
      "categoryCode" => "activeTransaction",
      "eventCode" => "txSent",
      "transaction" => %{"hash" => tx_id}
    }
  end

  def unwatch_tx_config(tx_id) do
    %{
      "categoryCode" => "activeTransaction",
      "eventCode" => "unwatch",
      "transaction" => %{"hash" => tx_id}
    }
  end
end
