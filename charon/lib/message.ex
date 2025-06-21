defmodule Charon.Message do
  @moduledoc """
    This struct holds all the information related about
    intercommunication, from producers to consumers.
  """
  @type acknowledger :: {module, ack_ref :: term, data :: term}

  @type t :: %Message{
          data: term,
          metadata: %{optional(atom) => term},
          acknowledger: acknowledger,
          status:
            :ok
            | {:failed, reason :: term} 
            | {:throw | :error | :exit, term, Exception.stacktrace()}
  }

  @enforce_keys [:data, :acknowledger]
  defstruct data: nil,
            metadata: %{},
            acknowledger: nil,
            status: :ok

  @doc """
    Now that we got a basic structure to represent
    the messages to communicate and handle the data.
  """
  @spec update_data(message :: Message.t(), fun :: (term -> term)) :: Message.t()
  def update_data(%Message{} message, fun) when is_function(fun, 1) do
    %{message | data: fun.(message.data)}
  end

  @spec put_data(message :: Message.t(), term) :: Message.t()
  def put_data(%Message = message, data) do
    %{message | data: data}
  end

  @spec forward_data(message :: Message.t(), consumer :: atom) :: Message.t()
  def forward_data(%Message = message, destination) when is_atom(destination) do
    %{message | consumer: consumer}
  end

  @spec failed(message :: Message.t(), reason :: term) :: Message.t()
  def failed(%Message = message, reason) do
    %{message | status: {:failed, reason}}
  end

end
