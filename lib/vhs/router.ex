defmodule Vhs.Router do
  @moduledoc """
  Main router of the application to handle incoming requests
  """

  use Plug.Router

  require Logger

  alias Vhs.Clients.Slack
  alias Vhs.Domain.Transaction

  plug(Plug.Logger)
  plug(:match)
  plug(Plug.Parsers, parsers: [:json], pass: ["application/json"], json_decoder: Jason)
  plug(:dispatch)

  post "/blocknative/confirm" do
    Logger.info("#{conn.body_params["hash"]} got mined")
    params = conn.body_params
    IO.inspect(params)

    with true <- Transaction.is_existing_transaction?(params["hash"]),
         {:ok, _} <- Slack.webhook_post(params),
         :ok <- Transaction.set_confirm_status(params["hash"]) do
      conn
      |> put_resp_content_type("application/json")
      |> resp(200, Jason.encode!(%{status: "ok"}))
      |> send_resp()
    else
      _ ->
        # This is logged on Slack's client
        conn
        |> put_resp_content_type("application/json")
        |> resp(422, Jason.encode!(%{error: "there was an error posting to slack"}))
        |> send_resp()
    end
  end

  post "/blocknative/transaction/:transaction_id" do
    Logger.info("#{conn.path_params["transaction_id"]} to be checked")

    case Transaction.watch_tx(conn.path_params) do
      {:ok, _} ->
        conn
        |> put_resp_content_type("application/json")
        |> resp(200, Jason.encode!(%{status: "ok"}))
        |> send_resp()

      {:error, _error} ->
        conn
        |> put_resp_content_type("application/json")
        |> resp(
          400,
          Jason.encode!(%{error: "there is an error processing the request, Try Again"})
        )
        |> send_resp()
    end
  end

  post "/blocknative/transactions" do
    Logger.info("#{conn.body_params["transaction_ids"]} to be checked")

    case Transaction.watch_txs(conn.body_params) do
      {:ok, _} ->
        conn
        |> put_resp_content_type("application/json")
        |> resp(200, Jason.encode!(%{status: "ok"}))
        |> send_resp()
    end
  end

  match _ do
    conn
    |> put_resp_content_type("application/json")
    |> resp(404, Jason.encode!(%{error: "not found"}))
    |> send_resp()
  end
end
