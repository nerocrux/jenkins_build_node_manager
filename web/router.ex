defmodule JenkinsBuildNodeManager.Router do
  use JenkinsBuildNodeManager.Web, :router

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

  scope "/", JenkinsBuildNodeManager do
    pipe_through :browser # Use the default browser stack

    get "/", PageController, :index
    get "/backup", BackupController, :index
    post "/edit/node", EditNodeController, :index
    post "/edit/tags", EditTagsController, :index
    post "/edit/product", EditProductController, :index
    post "/edit/batch/node", EditBatchNodeController, :index
  end

  # Other scopes may use custom stacks.
  # scope "/api", JenkinsBuildNodeManager do
  #   pipe_through :api
  # end
end
