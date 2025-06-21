defmodule Charon do
  @moduledoc """
  Documentation for `Charon`.
  
  """
  use GenStage

  @doc """
    This fetches the starting "state" of the Pipeline
  """
    def start_link() do
      :world
    end
end
