defmodule BlockChain.Chain do

  use GenServer

  alias BlockChain.Chain
  alias BlockChain.Block
  alias BlockChain.Crypto

  def init(state) do
    {:ok, state}
  end

  def start_link(state \\ []) do
    GenServer.start_link(__MODULE__ ,[state] ,name: Chain)
  end

  def handle_call({:chain, block}, _from, state) do
    {:reply,[block | state], [block | state]}
  end

  def handle_call(:get, _from, state) do
    {:reply, state, state}
  end

  def setChain(block) do
    GenServer.call(Chain, {:chain, block})
  end

  def getChain() do
    GenServer.call(Chain, :get)
  end

    @doc "Create a new blockchain with a zero block"
  def new do
    chain = Crypto.put_hash(Block.zero)
    start_link(chain)
    [chain]
  end

  @doc "Insert given data as a new block in the blockchain"
  def insert(blockchain, data) when is_list(blockchain) do
    %Block{hash: prev} = hd blockchain

    block =
    data
    |> Block.new(prev)
    |> Crypto.put_hash
  
    setChain(block)
  end
  
  
  @doc "Validate the complete blockchain"
  def valid?(blockchain) when is_list(blockchain) do
    zero = Enum.reduce_while(blockchain, nil, fn prev, current ->
      cond do
      current == nil ->
        {:cont, prev}
  
      Block.valid?(current, prev) ->
        {:cont, prev}
  
      true ->
        {:halt, false}
    end
    end)
  
  if zero, do: Block.valid?(zero), else: false
  end
  end
