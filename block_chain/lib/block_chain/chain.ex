defmodule BlockChain.Chain do


  alias BlockChain.Chain
  alias BlockChain.Block
  alias BlockChain.Crypto
  alias BlockChain.Transaction

  def init(state) do
    {:ok, state}
  end

  # def start_link(state \\ []) do
  #   GenServer.start(__MODULE__ ,state, name: __MODULE__)
  # end

  # def handle_call({:chain, block}, _from, state) do
  #   {:reply,[block | state], [block | state]}
  # end

  # def handle_call(:get, _from, state) do
  #   {:reply, state, state}
  # end

  # def setChain(block) do
  #   GenServer.call(__MODULE__, {:chain, block})
  # end

  def getChain(id) do
    # GenServer.call(__MODULE__, :get)
    block = :ets.lookup(String.to_atom("chain" <> id), :block)
    block[:block]
  end

    @doc "Create a new blockchain with a zero block"
  def new(id) do
    chain = Crypto.put_hash(Block.zero)
    # start_link([chain])
    # Transaction.start_link()
    :ets.new(String.to_atom("chain" <> id),[:set, :private, :named_table])
    :ets.insert(String.to_atom("chain" <> id), {:block, [chain]})
    [chain]
  end

  @doc "Insert given data as a new block in the blockchain"
  def insert(blockchain, data) when is_list(blockchain) do
    %Block{hash: prev, index: index} = hd blockchain

    block =
    data
    |> Block.new(prev, index)
    |> Crypto.put_hash
  
    # setChain(block)
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
