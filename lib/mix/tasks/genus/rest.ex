defmodule Mix.Tasks.Genus.Rest do
  @moduledoc """
  TODO: fuck this shit up
  """

  use Mix.Task
  require EEx

  @shortdoc "Generate REST API endpoints along with generated tschema types"
  def run([model, endpoint]) do
    host = Application.get_env(:genus, :host)

    if host do
      code =
        EEx.eval_file("./lib/genus/templates/rest.eex",
          lower_model: String.downcase(model),
          host: host,
          model: model,
          endpoint: endpoint
        )

      directory = Application.get_env(:genus, :directory, "ts") <> "/rest"
      File.mkdir_p!(directory)
      File.write!(directory <> "/#{model}_rest.ts", code)
    else
      IO.puts("Error, config value 'host' missing")
    end
  end

  def run(_) do
    IO.puts("Error: could not. generate\nUsage: mix genus.rest <ModelName> <API endpoint path>")
  end
end
