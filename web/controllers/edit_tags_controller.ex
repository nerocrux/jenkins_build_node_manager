defmodule JenkinsBuildNodeManager.EditTagsController do
  use JenkinsBuildNodeManager.Web, :controller

  def index(conn, %{"job" => job, "tags" => tags}) do
    HTTPoison.start
    
    # update local configs
    filepath = Application.get_env(:jenkins_build_node_manager, JenkinsBuildNodeManager.Endpoint)[:conf_file]
    configs = 
        File.read!(filepath)    |>
        Poison.decode!()        |>
        Enum.map(fn e -> 
            if e["job"] == job,
            do: Map.new([
                {:job,  job},
                {:node, e["node"]},
                {:tags, tags},
                {:product, e["product"]}
            ]), 
            else: e
        end)
    write(filepath, configs)
    
    redirect conn, to: "/", configs: configs
  end
  
  def write(filepath, configs) do
    File.write!(filepath, to_string(Poison.Encoder.encode(configs, [])))
  end
end
