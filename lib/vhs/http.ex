defmodule Vhs.HTTP do
  @moduledoc """
  HTTP client interface
  """

  @spec post(String.t(), map(), map(), Keyword.t()) :: {:ok, Tesla.Env.t()} | {:error, any()}
  def post(path, body, config, opts \\ []) do
    # Usually in `opts` you'll receive the client configuration, which can be ignored or can
    # be used to construct the body of the request, append authorization to headers, etc...
    #  but for this it might not be necessary.
    config
    |> client(:post)
    |> Tesla.post(path, body, opts)
  end

  @spec get(String.t(), Map.t()) :: {:ok, Tesla.Env.t()} | {:error, any()}
  def get(path, config) do
    # Usually in `opts` you'll receive the client configuration, which can be ignored or can
    # be used to construct the body of the request, append authorization to headers, etc...
    # but for this it might not be necessary.
    config
    |> client(:get)
    |> Tesla.get(path)
  end

  defp client(client_config, :post) do
    middlewares = [
      {Tesla.Middleware.JSON, engine: Jason},
      {Tesla.Middleware.BaseUrl, client_config.base_url}
    ]

    Tesla.client(middlewares, Tesla.Adapter.Gun)
  end

  defp client(client_config, :get) do
    middlewares = [
      {Tesla.Middleware.BaseUrl, client_config[:base_url]}
    ]

    Tesla.client(middlewares, Tesla.Adapter.Gun)
  end
end
