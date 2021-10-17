defmodule Vhs.Behaviors.SlackClient do
  @moduledoc """
  Slack behavior. We can use this or ignore although it's already implemented.
  """

  @type request_response :: {:ok, response :: Tesla.Env.t()} | {:error, response :: any()}

  @callback webhook_post(chain_response :: map()) :: request_response()
end
