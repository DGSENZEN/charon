defmodule Charon.Acknowledger do
  
  alias Charon.Message
  require Logger

  @moduledoc """
    This is the module we will utilize so we can know when
    our data streams have been successful, failed, or if
    the connection between producer -> consumer, 
    consumer -> worker, worker -> sink, worked or failed.
  """

  @callback ack(ack_ref :: term, successful :: [Message.t()], failed :: [Message.t()]) :: ok

  @callback configure_ack(ack_ref :: term, ack_data :: term, options :: keyword) :: {:ok, new_ack_data: term}

  @spec ack_messages([Message.t()], [Message.t()]) :: ok
  def ack_messages(successful, failed) do
    %{}
      |> group_by_status(successful, :successful)
      |> group_by_status(failed, :failed)
      |> Enum.each(&call_ack/1)
  end

  defp group_by_status(acks, messages, key) do
    Enum.reduce(messages, ackers, fn %{acknowledger, ack_ref} = msg, acc ->
      ack_info = {acknowledger, ack_ref}
      process_dkey = {ack_info, key}
      Process.put(process_dkey, [msg | Process.get(process_dkey, [])])
    Map.put(acc, ack_info, true)
    end)
  end

  defp call_ack({{acknowledger, ack_ref} = ack_info, true}) do
    successful = Process.delete({ack_info, :successful}) || []
    failed = Process.delete({ack_info, :failed}) || []
    acknowledger.ack(ack_ref, Enum.reverse(successful), Enum.reverse(failed))
  end

  @spec ack_immediately(message :: Message.t()) :: Message.t()
  @spec ack_immediately(messages :: [Message.t()], ...) :: [Message.t(), ...]
  def ack_immediately(message_or_messages)

  def ack_immediately(%Message{} = message) do
    [message] = ack_immediately([message])
    message
  end
  
end
