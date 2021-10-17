import Config

# Set the `:username` config value here with your Name or Github handler.
config :vhs,
  blocknative: %{
    api_key: "fb8af020-039e-436f-895f-ffc09c62a63a",
    blockchain: "ethereum",
    network: "main",
    base_url: "https://api.blocknative.com"
  },
  slack: %{
    base_url: "https://hooks.slack.com/services",
    webhook_key: "/T02JEBG767K/B02JRDES07J/s6mDzmvIRmIgtENQ866Q9LvC"
  }
