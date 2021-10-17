# VHS Test Template

Use this template to complete your assignment for the backend elixir engineer position at VHS

In this project you'll find two behaviors to implement a Slack and Blocknative client. They're given as starting points where you can just build the rest of the logic around that.

## Configuration

On the `config.exs` file you'll find the base configuration you need to implement both the Slack and Blocknative communication. You just need to request an API key from Blocknative and the webhook for Slack. The base URL is already set for both.

Both clients already are wired. You do need to build everything around that to monitor or to input transactions into the clients.

You can run a `ngrok http 4000` to make the webhook on Blocknative work. Note that locally the path will be `localhost:4000/blocknative/confirm`.

In the same config file the `:username` key needs to be set for the app to launch.

