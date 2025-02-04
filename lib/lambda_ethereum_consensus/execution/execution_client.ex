defmodule LambdaEthereumConsensus.Execution.ExecutionClient do
  @moduledoc """
  Execution Layer Engine API methods
  """
  alias LambdaEthereumConsensus.Execution.EngineApi
  require Logger

  @doc """
  Verifies the validity of the data contained in the new payload and notifies the Execution client of a new payload
  """
  @spec verify_and_notify_new_payload(Types.ExecutionPayload.t()) :: {:ok, any} | {:error, any}
  def verify_and_notify_new_payload(_execution_payload) do
    # TODO: call engine api
    {:ok, true}
  end

  @doc """
  This function performs three actions *atomically*:
  * Re-organizes the execution payload chain and corresponding state to make `head_block_hash` the head.
  * Updates safe block hash with the value provided by `safe_block_hash` parameter.
  * Applies finality to the execution state: it irreversibly persists the chain of all execution payloads
  and corresponding state, up to and including `finalized_block_hash`.

  Additionally, if `payload_attributes` is provided, this function sets in motion a payload build process on top of
  `head_block_hash` and returns an identifier of initiated process.

  """
  @spec notify_forkchoice_updated(Types.hash32(), Types.hash32(), Types.hash32()) ::
          {:ok, any} | {:error, any}
  def notify_forkchoice_updated(head_block_hash, safe_block_hash, finalized_block_hash) do
    fork_choice_state = %{
      finalizedBlockHash: finalized_block_hash,
      headBlockHash: head_block_hash,
      safeBlockHash: safe_block_hash
    }

    EngineApi.forkchoice_updated(fork_choice_state, nil)
  end
end
