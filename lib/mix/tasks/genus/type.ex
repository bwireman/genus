defmodule Mix.Tasks.Genus.Type do
  @moduledoc """
  TODO: fuck this shit up
  """

  use Mix.Task
  require EEx

  @shortdoc "Generate REST API endpoints along with generated tschema types"
  def run(args) do
    Mix.Task.run("phx.gen.json", args)
    [_ | tl] = args
    [module | tl] = tl
    [_ | tl] = tl

    %{flags: _, fields: fields} =
      Enum.reduce(tl, %{flags: [], fields: []}, fn arg, acc ->
        if String.starts_with?(arg, "--") do
          Map.put(acc, :flags, acc[:flags] ++ [arg])
        else
          Map.put(acc, :fields, acc[:fields] ++ [arg])
        end
      end)

    name = String.split(module, ".") |> List.last()
    lower_name = name |> String.downcase()

    fields =
      fields
      |> Enum.map(&String.split(&1, ":", parts: 2))

    enums =
      fields
      |> Enum.map(fn field ->
        case field do
          [_] ->
            nil

          [name, type] ->
            [_ | values] =
              type
              |> String.split(":")
              |> Enum.map(&"\"#{&1}\"")

            if String.starts_with?(type, "enum") do
              %{
                name: name |> String.upcase(),
                values: Enum.join(values, " | ")
              }
            else
              nil
            end
        end
      end)
      |> Enum.filter(&(not is_nil(&1)))

    fields =
      fields
      |> Enum.map(fn field ->
        {name, type} =
          case field do
            [name, type] ->
              cond do
                String.starts_with?(type, "enum") ->
                  {name, name |> String.upcase()}

                String.starts_with?(type, "references") ->
                  {name, "integer"}

                true ->
                  {name, type}
              end

            [name] ->
              {name, "string"}
          end

        required = false

        type = type |> String.replace(":redacted", "") |> String.replace(":unique", "")

        {repeated, type} =
          if String.starts_with?(type, "array") do
            {true, String.split(type, ":") |> List.last()}
          else
            {false, type}
          end

        type =
          case type do
            "integer" -> "number"
            "float" -> "number"
            "decimal" -> "number"
            "boolean" -> "boolean"
            "map" -> "any"
            "string" -> "string"
            "array" -> "[]#{type}"
            "text" -> "string"
            "date" -> "Date"
            "time" -> "Date"
            "time_usec" -> "Date"
            "naive_datetime" -> "Date"
            "naive_datetime_usec" -> "Date"
            "utc_datetime" -> "Date"
            "utc_datetime_usec" -> "Date"
            "uuid" -> "string"
            "binary" -> "string"
            "enum" -> name
            "datetime" -> "Date"
            _ -> type
          end

        type =
          if repeated do
            "#{type}[]"
          else
            type
          end

        %{name: name, type: type, required: false, marker: if(required, do: "", else: "?")}
      end)

    field_names = Enum.map(fields, fn f -> f.name end) |> Enum.join(", ")
    directory = Application.get_env(:genus, :directory, "ts")
    path = Path.join([directory, String.replace(module, ".", "/")]) |> String.downcase()
    File.mkdir_p!(path)

    File.write!(
      Path.join([path, name <> ".ts"]),
      EEx.eval_file("./lib/genus/templates/type.eex",
        name: name,
        lower_name: lower_name,
        enums: enums,
        fields: fields,
        field_names: field_names,
        required_field_names: []
      )
    )

    File.write!(
      Path.join([path, name <> "_rest.ts"]),
      EEx.eval_file("./lib/genus/templates/rest.eex",
        lower_name: lower_name,
        name: name,
        endpoint: "/api/v1/#{lower_name}"
      )
    )
  end
end
