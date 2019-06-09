# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# Configures the endpoint
config :jenkins_build_node_manager, JenkinsBuildNodeManager.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "<YOUR_SECRET_KEY>",
  render_errors: [view: JenkinsBuildNodeManager.ErrorView, accepts: ~w(html json)],
  pubsub: [name: JenkinsBuildNodeManager.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]
  
config :jenkins_build_node_manager, JenkinsBuildNodeManager.Endpoint,
  tmpfile: "/tmp/jenkins_conf.xml",
  conf_file: "/usr/local/var/jenkins_build_nodes.json",
  jenkins_http_method: "https",
  jenkins_uri: "<JENKINS_URI>",
  jenkins_username: "<JENKINS_USERNAME>",
  jenkins_conf_url: "<JENKINS_CONF_URL>",
  jenkins_access_token: "<JENKINS_ACCESS_TOKEN>",
  products: ["<PRODUCT_NAME>"]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
