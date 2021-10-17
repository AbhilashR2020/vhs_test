defmodule Vhs.Clients.Blocknative do
  @moduledoc """
  Interface to communicate with Blocknative's API

  Ideally the client_config will return api keys, network, etc...
  """

  require Logger

  @behaviour Vhs.Behaviors.BlocknativeClient

  @client_config Application.compile_env!(:vhs, :blocknative)

  def watch_tx(body) do
    case Vhs.HTTP.post("/transaction", body, @client_config) do
      {:ok, response} ->
        {:ok, response}

      {:error, error} ->
        Logger.error(
          "Received error trying to watch #{inspect(body.hash)} with reason #{inspect(error)}"
        )

        {:error, error}
    end
  end

  def watched_list(config) do
    url = "/transaction/#{config.api_key}/#{config.blockchain}/#{config.network}"

    case Vhs.HTTP.get(url, config) do
      {:ok, response} ->
        {:ok, response}

      {:error, error} ->
        Logger.error("Received error trying to watched reason #{inspect(error)}")

        {:error, error}
    end
  end
end
