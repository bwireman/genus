defmodule Genus do
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
      |> Enum.join(Access.get(opts, :seperator, "\n"))

  defp js_literal({name, value}) do
    value =
      case value do
        :required -> Atom.to_string(name)
        _ -> "#{name} || " <> Genus.JSLiteral.literal(value)
      end

    "#{name}: " <> value <> ","
  end

  defp build_import({name, file}), do: "import type { #{name} } from \"./#{file}\""

  defp build_union({name, values}),
    do: "export type #{name} = " <> Enum.join(values, " | ") <> ";"

  defp build(name, parsed, other_imports, caller) do
    header =
      "// Do Not Modify! This file was generated by Genus from an Elixir struct @ #{caller.module}
// https://github.com/bwireman/genus"

    imports =
      Genus.Parse.collect(parsed, :imports, [])
      |> List.flatten()
      |> Enum.map(&build_import({&1, &1}))
      |> Enum.join("\n")

    types =
      Genus.Parse.collect(parsed, :type_definitions, [])
      |> List.flatten()
      |> Enum.map(&build_union/1)
      |> Enum.join("\n")

    interface =
      "export interface #{name} {\n" <>
        (parsed
         |> Enum.map(&Genus.Parse.render_type/1)
         |> Enum.join("\n")) <>
        "\n}"

    snake_case_name = Macro.underscore(name)
    apply = "export const apply_#{snake_case_name} = (v: any): #{name} => v"

    params = Enum.map(parsed, &Genus.Parse.as_param_name(&1)) |> Enum.join(", ")
    param_types = Enum.map(parsed, &Genus.Parse.as_param_type(&1)) |> Enum.join(",\n")
    return = Enum.map(parsed, &Genus.Parse.as_return(&1)) |> Enum.join(",\n")

    build =
      "export const build_#{snake_case_name} = ({ #{params} } : { #{param_types} } ): #{name} => { \n return { #{return} } }"

    required =
      parsed
      |> Enum.filter(& &1.required)

    new_params =
      required
      |> Enum.map(&Genus.Parse.render_type/1)
      |> Enum.join(", ")
      |> IO.inspect()

    new_vals =
      required
      |> Enum.map(&Genus.Parse.as_param_name/1)
      |> Enum.join(", ")
      |> IO.inspect()

    new =
      "export const new_#{snake_case_name} = (#{new_params}): #{name} => build_#{snake_case_name}({ #{new_vals} })"

    render = [header, imports, types, interface, apply, build, new]

    directory = Application.get_env(:genus, :directory, "ts")
    File.mkdir_p!(directory)

    File.write!(
      Path.join(directory, name <> ".ts"),
      format(render, seperator: "\n\n")
    )
  end

  # defmacro genus(opts) do
  #   name = opts[:name]
  #   imports = Access.get(opts, :imports, [])

  #   fields =
  #     opts[:fields]
  #     |> Enum.map(&get_defaults/1)

  #   required_fields = Enum.filter(fields, &required?/1)

  #   # build(name, fields, required_fields, imports, __CALLER__)

  #   keys_and_defaults =
  #     Enum.map(fields, &format_struct/1)
  #     |> Enum.map(fn f ->
  #       case f do
  #         {field, :required} -> {field, nil}
  #         _ -> f
  #       end
  #     end)

  #   required =
  #     Enum.map(required_fields, fn field ->
  #       case field do
  #         {[name | _], _} -> name
  #       end
  #     end)

  #   quote bind_quoted: [required: required, keys_and_defaults: keys_and_defaults] do
  #     @enforce_keys required
  #     defstruct keys_and_defaults
  #   end
  # end

  defmacro tschema(opts \\ [], do: fields) do
    name = Access.get(opts, :name)
    imports = Access.get(opts, :imports)

    parsed =
      fields
      |> elem(2)
      |> Enum.map(&elem(&1, 2))
      |> Enum.map(fn args ->
        if List.last(args) |> Keyword.keyword?() do
          args
        else
          args ++ [[]]
        end
      end)
      |> Enum.map(&Genus.Parse.parse/1)

    build(name, parsed, imports, __CALLER__)
    quote do
    end
  end
end
