defmodule BlockChainWeb.Router do
  use BlockChainWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", BlockChainWeb do
    pipe_through :browser

    get "/", PageController, :index

    get "/chain", PageController, :chain
  end

  # Other scopes may use custom stacks.
  # scope "/api", BlockChainWeb do
  #   pipe_through :api
  # end
end
