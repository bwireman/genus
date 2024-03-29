defmodule Genus do
  alias Genus.Parse

  defmacro __using__(_) do
    quote do
      def field(_), do: nil
      def field(_, _), do: nil
      def field(_, _, _), do: nil
      def field(_, _, _, _), do: nil
      def field(_, _, _, _, _), do: nil

      require Genus
      import Genus, only: [tschema: 1, tschema: 2]
    end
  end

  defp indent(string, level) do
    indent_spacer = Application.get_env(:genus, :indent, "  ")

    case level do
      0 ->
        string

      _ ->
        (1..level
         |> Enum.map(fn _ -> indent_spacer end)
         |> Enum.reduce(&(&1 <> &2))) <>
          string
    end
  end

  defp format(strings, opts \\ []),
    do:
      Enum.map(strings, &indent(&1, Access.get(opts, :level, 0)))
      |> Enum.filter(fn str ->
        case str do
          elt when is_binary(elt) -> String.trim(elt) != ""
          elt when is_list(elt) -> Enum.join(elt) |> String.trim() != ""
          _ -> true
        end
      end)
      |> Enum.join(Access.get(opts, :separator, "\n"))

  defp build_import({name, file}), do: "import type { #{name} } from \"./#{file}\""

  defp build_union({name, values}),
    do: "export type #{name} = " <> format(values, separator: " | ") <> ";"

  defp imports(parsed, other_imports) do
    imports =
      Parse.collect(parsed, :imports, [])
      |> List.flatten()
      |> Enum.map(&build_import({&1, &1}))

    other_imports =
      other_imports
      |> Enum.map(&build_import/1)

    (imports ++ other_imports)
    |> Enum.dedup()
    |> format()
  end

  defp other_types(parsed),
    do:
      Parse.collect(parsed, :type_definitions, [])
      |> List.flatten()
      |> Enum.map(&build_union/1)
      |> format()

  defp interface(name, parsed) do
    fields =
      parsed
      |> Enum.map(&Parse.render_type/1)
      |> format(level: 1)

    "export interface #{name} {\n#{fields}\n}"
  end

  defp functions(name, parsed) do
    snake_case_name = Macro.underscore(name)
    apply = "export const apply_#{snake_case_name} = (v: any): #{name} => v"

    params =
      Enum.map(parsed, & &1.name)
      |> format(separator: ", ")

    param_types =
      Enum.map(parsed, &Parse.as_param_type(&1))
      |> format(level: 1)

    return = Enum.map(parsed, &Parse.as_return(&1)) |> format(level: 2, separator: ",\n")

    build =
      "export const build_#{snake_case_name} = ({ #{params} } : {\n#{param_types}\n}): #{name} => {\n  return {\n#{return}\n  }\n}"

    required =
      parsed
      |> Enum.filter(& &1.required)

    new_params =
      required
      |> Enum.map(&Parse.render_type/1)
      |> format(separator: ", ")

    new_values =
      required
      |> Enum.map(& &1.name)
      |> format(separator: ", ")

    new =
      "export const new_#{snake_case_name} = (#{new_params}): #{name} => build_#{snake_case_name}({ #{new_values} })"

    format([apply, build, new], separator: "\n\n")
  end

  defp build(name, parsed, other_imports, caller_module) do
    header =
      "// Do Not Modify! This file was generated by Genus from an Elixir struct @ #{caller_module}
// https://github.com/bwireman/genus"

    imports = imports(parsed, other_imports)
    types = other_types(parsed)
    interface = interface(name, parsed)
    functions = functions(name, parsed)

    format([header, imports, types, interface, functions], separator: "\n\n")
  end

  def write!(name, content) do
    directory = Application.get_env(:genus, :directory, "ts")
    File.mkdir_p!(directory)

    File.write!(
      Path.join(directory, name <> ".ts"),
      content
    )
  end

  defmacro tschema(opts \\ [], do: block) do
    default_name =
      __CALLER__.module
      |> Atom.to_string()
      |> String.split(".")
      |> List.last()

    name = Access.get(opts, :name, default_name)
    imports = Access.get(opts, :imports, [])

    fields =
      case block do
        {:__block__, _, fields} -> fields |> Enum.map(&elem(&1, 2))
        {:field, _, fields} -> [fields]
      end

    parsed =
      fields
      |> Enum.map(fn args ->
        if List.last(args) |> Keyword.keyword?() do
          args
        else
          args ++ [[]]
        end
      end)
      |> Enum.map(&Parse.parse/1)

    content = build(name, parsed, imports, __CALLER__.module)
    write!(name, content)

    required =
      parsed
      |> Enum.filter(& &1.required)
      |> Parse.collect(:atom, nil)

    keys_and_defaults =
      parsed
      |> Enum.map(&{&1.atom, &1.default})

    quote bind_quoted: [required: required, keys_and_defaults: keys_and_defaults] do
      @enforce_keys required
      defstruct keys_and_defaults
    end
  end
end
