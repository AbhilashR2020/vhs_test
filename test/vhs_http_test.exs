
defmodule VhsHttpTest do
  @moduledoc false

  use ExUnit.Case

  import Mock

  alias Vhs.Clients.Blocknative
  alias Vhs.DataStore.TransactionStore
  setup do
    :ets.delete_all_objects(Vhs.DataStore.TransactionStore)
    {:ok, conn_pid} = conn() 
    %{client_conn_id: conn_pid}
  end

  setup_with_mocks([
    {Blocknative, [], [watch_tx: fn(%{}) -> {:ok, %{}} end]} ]) do
    {:ok, %{}}
  end

  test "http post /blocknative/transaction/:transaction_id", %{client_conn_id: conn_id} do
    url = "/blocknative/transaction/0xa742edfa41970a72dfed56995cff9a3e8a0e497af2716b4d1c5b65e149a38657"
    {200, _headers, :data, respBody} = send_request(:post, conn_id, url, %{}, 5000)
    assert %{"status" => "ok"} = Jason.decode!(respBody) 
    [{tx_id,_,_,_} |_] = :ets.tab2list(Vhs.DataStore.TransactionStore)
    assert tx_id == "0xa742edfa41970a72dfed56995cff9a3e8a0e497af2716b4d1c5b65e149a38657"
  end

  test "http post /blocknative/transactions", %{client_conn_id: conn_id} do
    :ets.delete_all_objects(Vhs.DataStore.TransactionStore)
    url = "/blocknative/transactions"
    body = %{ "transaction_ids" => ["0xa742edfa41970a72dfed56995cff9a3e8a0e497af2716b4d1c5b65e149a38657",
	   			    "0x57218b8dbc62ff228b3c7a4929427fc315e07bd99acbc60c8f15892107aaa2c2"]}

    {200, _headers, :data, respBody} = send_request(:post, conn_id, url, body, 5000)
    assert %{"status" => "ok"} = Jason.decode!(respBody)
    tx_store = :ets.tab2list(Vhs.DataStore.TransactionStore) 
    actual_length = length(tx_store)
    expected_length = length(body["transaction_ids"])
    assert actual_length = expected_length
  end



  defp conn() do
    {host, port} = livsrvc()
    with {:ok, conn_pid} <- :gun.open(host, port),
      {:ok, _protocol} <- :gun.await_up(conn_pid) do
      {:ok, conn_pid}
    else
      {:error, reason} ->
         {:error, reason}
    end
  end

  def send_request(:post, connPid, url, body, timeout) do
    {:ok, jsonBody} = Jason.encode(body)
    length = :erlang.integer_to_binary(Kernel.byte_size(jsonBody))
    streamRef =
      :gun.post(
        connPid,
        url,
        [
          {<<"content-length">>, length},
          {<<"content-type">>, "application/json"}
        ],
        jsonBody
      )
    response = receive_response(connPid, streamRef, timeout)
    :gun.cancel(connPid, streamRef)
    response
  end

  def receive_response(connPid, streamRef, timeout) do
    case :gun.await(connPid, streamRef, timeout) do
      {:error, reason} ->
        {:error, reason}

      {:response, :fin, status, headers} ->
        {status, headers, :no_data, []}

      {:response, :nofin, status, headers} ->
          case :gun.await_body(connPid, streamRef, timeout) do
              {:ok, body} ->
                  {status, headers, :data, body}
              other_res -> other_res
          end
    end
  end

  def livsrvc() do
    Application.get_env(:vhs, :livsrvc) || {{127, 0, 0, 1}, 4000}
  end

end
