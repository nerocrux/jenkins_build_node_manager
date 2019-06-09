defmodule JenkinsBuildNodeManager.EditBatchNodeController do
  use JenkinsBuildNodeManager.Web, :controller
  import JenkinsBuildNodeManager.JenkinsUrl

  def index(conn, %{"product" => product, "tag" => tag, "node" => node}) do
    find_jobs(product, tag, load_config()) |> Enum.map(fn e -> if e != nil, do: execute(e, node, load_config()) end)
    redirect conn, to: "/", configs: load_config()
  end
  
  def execute(job, node, configs) do
    HTTPoison.start
    tmpfile = Application.get_env(:jenkins_build_node_manager, JenkinsBuildNodeManager.Endpoint)[:tmpfile]
    
    # update local configs
    configs = 
      configs
      |> Enum.map(fn e -> 
         if e["job"] == job,
         do: Map.new([
            {:job,  job},
            {:node, node},
            {:tags, e["tags"]},
            {:product, e["product"]},
         ]),
         else: e
       end)
    write(configs)
    
    # fetch config
    response = HTTPoison.get! config_url(job)
    
    # update remote config
    updated = Regex.replace(~r/\<assignedNode\>.*\<\/assignedNode\>/, response.body, "<assignedNode>" <> node <> "</assignedNode>")
    File.write!(tmpfile, updated)
    
    # HTTPoison causes encoding error: 
    # HTTPoison.post! url, {:multipart, [{:file, tmpfile, {"form-data", [name: "filedata", filename: Path.basename(tmpfile)]}, []}]}
    System.cmd "curl", ["-XPOST", config_url(job), "--data-binary", "@" <> tmpfile]
  end
  
  def find_jobs(product, tag, configs) do
    configs
    |> Enum.map(fn e -> 
         tags = if e["tags"] != nil and e["tags"] != "", do: String.split(e["tags"], ","), else: []
         if Enum.member?(tags, tag) and e["product"] == product,
         do: e["job"]
       end)
  end
  
  def load_config() do
    filepath = Application.get_env(:jenkins_build_node_manager, JenkinsBuildNodeManager.Endpoint)[:conf_file]
    File.read!(filepath) |> Poison.decode!()
  end
  
  def write(configs) do
    filepath = Application.get_env(:jenkins_build_node_manager, JenkinsBuildNodeManager.Endpoint)[:conf_file]
    File.write!(filepath, to_string(Poison.Encoder.encode(configs, [])))
  end
end
