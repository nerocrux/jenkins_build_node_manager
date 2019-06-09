defmodule JenkinsBuildNodeManager.BackupController do
  use JenkinsBuildNodeManager.Web, :controller
  import JenkinsBuildNodeManager.XmlNode
  import JenkinsBuildNodeManager.JenkinsUrl

  def index(conn, _params) do
    filepath = Application.get_env(:jenkins_build_node_manager, JenkinsBuildNodeManager.Endpoint)[:conf_file]
    local_configs = File.read!(filepath)
    
    HTTPoison.start
    response = HTTPoison.get! display_name_url()
    job_list = 
        Map.get(Poison.decode!(response.body), "jobs")  |>
        Enum.map(fn e -> Map.get(e, "displayName") end)
    
    configs = if local_configs != "", 
        do: update(local_configs, job_list), 
        else: initialize job_list
      
    write(configs)
    redirect conn, to: "/", configs: configs
  end
  
  def initialize(job_list) do
    job_list
      |> Enum.map(fn e ->
           Map.new([
             {:job,  e},
             {:node, get_node(e)},
             {:product, "none"}, #compatible with x-editable
             {:tags, nil}
           ])
    end)
  end
  
  def update(local_configs, job_list) do
    job_list
      |> Enum.map(fn e ->
           conf = find_conf(e, local_configs)
           product = if conf != nil, do: conf["product"]
           tags = if conf != nil, do: conf["tags"]
           Map.new([
             {:job,  e},
             {:node, get_node(e)},
             {:product, product},
             {:tags, tags}
           ])
    end)
  end
  
  def get_node(job) do
    response = HTTPoison.get! config_url(job)
    from_string(response.body)
      |> first("//assignedNode") 
      |> text
  end
  
  def write(configs) do
    filepath = Application.get_env(:jenkins_build_node_manager, JenkinsBuildNodeManager.Endpoint)[:conf_file]
    File.write!(filepath, to_string(Poison.Encoder.encode(configs, [])))
  end
  
  def find_conf(job, local_configs) do
    Enum.find(local_configs |> Poison.decode!(), fn e -> e["job"] == job end)
  end
end