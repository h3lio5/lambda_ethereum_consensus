defmodule Unit.PendingBlocks do
  @moduledoc false

  use ExUnit.Case
  use Patch

  alias LambdaEthereumConsensus.Beacon.PendingBlocks
  alias LambdaEthereumConsensus.ForkChoice
  alias LambdaEthereumConsensus.Store.BlockStore

  setup do
    Application.put_env(:lambda_ethereum_consensus, ChainSpec, config: MainnetConfig)

    # Lets trigger the process_blocks manually
    patch(PendingBlocks, :schedule_blocks_processing, fn -> :ok end)
    patch(PendingBlocks, :schedule_blocks_download, fn -> :ok end)

    start_supervised!({PendingBlocks, []})
    :ok
  end

  test "Adds a pending block to fork choice if the parent is there" do
    signed_block = Fixtures.Block.signed_beacon_block()
    block_root = Ssz.hash_tree_root!(signed_block.message)

    patch(ForkChoice, :has_block?, fn root -> root == signed_block.message.parent_root end)
    patch(ForkChoice, :on_block, fn _block, _root -> :ok end)

    # Don't store the block in the DB, to avoid having to set it up
    patch(BlockStore, :store_block, fn _block -> :ok end)

    PendingBlocks.add_block(signed_block)

    assert PendingBlocks.is_pending_block(block_root)
    send(PendingBlocks, :process_blocks)

    # If the block is not pending anymore, it means it was added to the fork choice
    assert not PendingBlocks.is_pending_block(block_root)
  end
end
