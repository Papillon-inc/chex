defmodule BlockChain.Crypto do

    alias BlockChain.Chain
    alias BlockChain.Block
    alias BlockChain.Crypto

    # Specify which fields to hash in a block
    @hash_fields [:data, :timestamp, :prev_hash, :nonce]


    @doc "Calculate hash of block"
    def search(%{} = block, n) do
        h = %{block | nonce: n }
            |> hash
        if (String.first(h) != "0") do
            search(block, n+1)
        else
            %{block | nonce: n, hash: h}
        end
    end

    def hash(%{} = block) do
        block
        |> Map.take(@hash_fields)
        |> Poison.encode!
        |> sha256
    end

    @doc "Calculate and put the hash in the block"
    def put_hash(%{} = block) do
        search(block, 0)
    end

    # Calculate SHA256 for a binary string
    defp sha256(binary) do
        :crypto.hash(:sha256, binary) |> Base.encode16
    end

end