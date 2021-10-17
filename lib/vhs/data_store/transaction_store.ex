defmodule Vhs.DataStore.TransactionStore do
  alias :ets, as: Ets

  @compile :nowarn_deprecated
  @compile {:parse_transform, :ms_transform}

  @moduledoc """
    This is a temporary data store to store transaction information
  """

  @spec create_table(atom()) :: Atom.t()
  def create_table(table_name \\ __MODULE__) do
    Ets.new(table_name, [:named_table, :public])
  end

  @spec insert(atom(), Tuple.t()) :: true
  def insert(table_name \\ __MODULE__, data) do
    Ets.insert(table_name, data)
  end

  @spec lookup(atom(), any()) :: [any()]
  def lookup(table_name \\ __MODULE__, key) do
    Ets.lookup(table_name, key)
  end

  @spec delete(atom(), any()) :: true
  def delete(table_name \\ __MODULE__, key) do
    Ets.delete(table_name, key)
  end

  def match_object_by_timestamp(table_name \\ __MODULE__) do
    ## This is in seconds 
    clearing_time = DateTime.to_unix(DateTime.utc_now()) - 2 * 60

    ms =
      :ets.fun2ms(fn {_, timestamp, :pending, :unacknowledged} = tx
                     when timestamp <= clearing_time ->
        tx
      end)

    :ets.select(table_name, ms)
  end
end
