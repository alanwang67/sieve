defmodule SieveNode do

  defstruct key: nil,
    value: nil,
    visited: 0

  def new(key, value) do
    %__MODULE__{key: key, value: value}
  end
  
end
