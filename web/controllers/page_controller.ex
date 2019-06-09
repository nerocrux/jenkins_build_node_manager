defmodule JenkinsBuildNodeManager.PageController do
  use JenkinsBuildNodeManager.Web, :controller
  require Logger

  def index(conn, _params) do
    filepath    = Application.get_env(:jenkins_build_node_manager, JenkinsBuildNodeManager.Endpoint)[:conf_file]
    products    = Application.get_env(:jenkins_build_node_manager, JenkinsBuildNodeManager.Endpoint)[:products]
    jenkins_url = Application.get_env(:jenkins_build_node_manager, JenkinsBuildNodeManager.Endpoint)[:jenkins_conf_url]
    if !File.regular?(filepath), do: File.touch!(filepath)
    configs = File.read!(filepath)
    configs = if configs != "", do: Poison.decode!(configs)
    render conn, "index.html", configs: configs, url: jenkins_url, products: products, products_: Enum.join(products, ",") 
  end
end
