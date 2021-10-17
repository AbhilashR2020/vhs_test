defmodule Vhs.Domain.Transaction do
  alias Vhs.Clients.Blocknative
  alias Vhs.Clients.Slack
  alias Vhs.DataStore.TransactionStore

  require Logger

  @moduledoc """
   This is the module which handles the core logic of 
   performing operations
  """

  @spec watch_tx(map()) :: {:ok, any()} | {:error, any()}
  def watch_tx(%{"transaction_id" => tx_id}) do
    with false <- is_existing_transaction?(tx_id),
         {:ok, tx_body} <- build_watch_request(tx_id),
         {:ok, response} <- Blocknative.watch_tx(tx_body),
         :ok <- add_to_datastore(tx_id) do
      {:ok, response}
    else
      true ->
        {:error, :existing_transaction}

      {:error, reason} ->
        {:error, reason}
    end
  end

  @spec watch_txs(map()) ::
          {:ok, %{required(:success) => List.t(), required(:failure) => List.t()}}
  def watch_txs(%{"transaction_ids" => tx_ids}) do
    {success, failure} =
      tx_ids
      |> Enum.map(fn tx_id -> {tx_id, watch_tx(%{"transaction_id" => tx_id})} end)
      |> Enum.reduce(
        {[], []},
        fn
          {tx_id, {:ok, _}}, {success, failure} ->
            {success ++ [tx_id], failure}

          {tx_id, {:error, _}}, {success, failure} ->
            {success, failure ++ [tx_id]}
        end
      )

    {:ok, %{success: success, failure: failure}}
  end

  def watched_tx do
    Application.get_env(:vhs, :blocknative)
    |> Blocknative.watched_list()
  end

  def is_existing_transaction?(tx_id) do
    case TransactionStore.lookup(tx_id) do
      [] -> false
      _ -> true
    end
  end

  def set_confirm_status(id) do
    with [{id, _, _, _}] <- TransactionStore.lookup(id),
         true <- TransactionStore.insert({id, nil, :confirmed, :acknowledged}) do
      :ok
    end
  end

  def check_pendings() do
    TransactionStore.match_object_by_timestamp()
    |> Enum.each(fn {tx_id, timestamp, status, _} ->
      Slack.webhook_post(tx_id)
      TransactionStore.insert({tx_id, timestamp, status, :acknowledged})
    end)
  end

  defp build_watch_request(tx_hash) do
    block_native_config = Application.get_env(:vhs, :blocknative)

    {:ok,
     %{
       "apiKey" => block_native_config[:api_key],
       "hash" => tx_hash,
       "blockchain" => block_native_config[:blockchain],
       "network" => block_native_config[:network]
     }}
  end

  defp add_to_datastore(tx_id) do
    timestamp = DateTime.utc_now() |> DateTime.to_unix()
    TransactionStore.insert({tx_id, timestamp, :pending, :unacknowledged})
    :ok
  end
end
