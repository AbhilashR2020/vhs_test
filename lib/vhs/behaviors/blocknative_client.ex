defmodule Vhs.Behaviors.BlocknativeClient do
  @moduledoc """
  Blocknative behavior. We can use or ignore this module although it's already implemented.
  """

  @type request_response :: {:ok, response :: Tesla.Env.t()} | {:error, response :: any()}

  @callback watch_tx(request_body :: map()) :: request_response()
end
