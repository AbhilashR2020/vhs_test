defmodule VhsDataStoreTest do
  @moduledoc false

  use ExUnit.Case
  
  alias Vhs.DataStore.TransactionStore 

  setup do
    :ets.delete_all_objects(Vhs.DataStore.TransactionStore)
  end

  test "stores transaction hash and validate", context do
    timestamp = DateTime.to_iso8601(DateTime.now!("Etc/UTC"))
    message = {"0xa742edfa41970a72dfed56995cff9a3e8a0e497af2716b4d1c5b65e149a38657", timestamp, :pending, :unacknowledged}
    TransactionStore.insert(message)
    actual = :ets.tab2list(Vhs.DataStore.TransactionStore)
    expected = [message]
    assert expected == actual
  end

end
