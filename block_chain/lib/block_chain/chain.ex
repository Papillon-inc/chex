defmodule BlockChain.Chain do


  alias BlockChain.Chain
  alias BlockChain.Block
  alias BlockChain.Crypto
  alias BlockChain.Transaction
  alias BlockChain.User

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
    |> Map.from_struct
    # start_link([chain])
    # Transaction.start_link()
    User.start_link()
    User.setUser(id)
    IO.inspect User.getUser()
    :ets.new(String.to_atom("chain" <> id),[:set, :protected, :named_table])
    :ets.insert(String.to_atom("chain" <> id), [block: [chain], tran: [] ])
    [chain]
  end

  @doc "Insert given data as a new block in the blockchain"
  def insert(blockchain, data, id) when is_list(blockchain) do
    %{hash: prev, index: index} = hd blockchain

    block =
    data
    |> Block.new(prev, index)
    |> Crypto.put_hash
    |> Map.from_struct

    Transaction.reset(id)
  
    :ets.insert(String.to_atom("chain" <> id), {:block, [block | blockchain]})
    getChain(id)
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
