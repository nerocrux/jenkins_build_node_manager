defmodule JenkinsBuildNodeManager.EditNodeController do
  use JenkinsBuildNodeManager.Web, :controller
  import JenkinsBuildNodeManager.JenkinsUrl

  def index(conn, %{"job" => job, "node" => node}) do
    tmpfile = Application.get_env(:jenkins_build_node_manager, JenkinsBuildNodeManager.Endpoint)[:tmpfile]
    HTTPoison.start
    
    # update local configs
    filepath = Application.get_env(:jenkins_build_node_manager, JenkinsBuildNodeManager.Endpoint)[:conf_file]
    configs = 
        File.read!(filepath)        |> 
        Poison.decode!()            |> 
        Enum.map(fn e -> 
            if e["job"] == job,
            do: Map.new([
                {:job,  job},
                {:node, node},
                {:tags, e["tags"]},
                {:product, e["product"]},
            ]),
            else: e
        end)
    write(filepath, configs)
    
    # fetch config
    response = HTTPoison.get! config_url(job)
    
    # update remote config
    updated = Regex.replace(~r/\<assignedNode\>.*\<\/assignedNode\>/, response.body, "<assignedNode>" <> node <>"</assignedNode>")
    File.write!(tmpfile, updated)
    
    # HTTPoison causes encoding error: 
    # HTTPoison.post! url, {:multipart, [{:file, tmpfile, {"form-data", [name: "filedata", filename: Path.basename(tmpfile)]}, []}]}
    System.cmd "curl", ["-XPOST", config_url(job), "--data-binary", "@" <> tmpfile]
    
    redirect conn, to: "/", configs: configs
  end
  
  def write(filepath, configs) do
    File.write!(filepath, to_string(Poison.Encoder.encode(configs, [])))
  end
end
