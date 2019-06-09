defmodule JenkinsBuildNodeManager.JenkinsUrl do
  def config_url(job) do
    jenkins_http_method = Application.get_env(:jenkins_build_node_manager, JenkinsBuildNodeManager.Endpoint)[:jenkins_http_method]
    jenkins_uri = Application.get_env(:jenkins_build_node_manager, JenkinsBuildNodeManager.Endpoint)[:jenkins_uri]
    jenkins_username = Application.get_env(:jenkins_build_node_manager, JenkinsBuildNodeManager.Endpoint)[:jenkins_username]
    jenkins_access_token = Application.get_env(:jenkins_build_node_manager, JenkinsBuildNodeManager.Endpoint)[:jenkins_access_token]
    jenkins_http_method <> "://" <> jenkins_username <> ":" <> jenkins_access_token <>"@" <> jenkins_uri <> "/job/" <> job <> "/config.xml"
  end

  def display_name_url() do
    jenkins_http_method = Application.get_env(:jenkins_build_node_manager, JenkinsBuildNodeManager.Endpoint)[:jenkins_http_method]
    jenkins_uri = Application.get_env(:jenkins_build_node_manager, JenkinsBuildNodeManager.Endpoint)[:jenkins_uri]
    jenkins_http_method <> "://" <> jenkins_uri <> "/api/json?tree=jobs[displayName]&pretty=true"
  end
end