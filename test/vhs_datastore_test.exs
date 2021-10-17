defmodule VhsDataStoreTest do
  @moduledoc false

  use ExUnit.Case
  
  alias Vhs.DataStore.TransactionStore 
  setup do
    TransactionStore.create_table
  end

  test "stores transaction hash and validate", context do
    timestamp = DateTime.to_iso8601(DateTime.now!("Etc/UTC"))
    message = {"0xa742edfa41970a72dfed56995cff9a3e8a0e497af2716b4d1c5b65e149a38657", timestamp, :pending, :unacknowledged}
    TransactionStore.insert(message)
    assert :ets.tab2list(TransactionStore) =:= [message]  
  end

end
