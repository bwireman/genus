defmodule Genus do
  defmacro __using__(_) do
    quote do
      require Genus
      import Genus, only: [genus: 1]
    end
  end

  defp nullable(nil), do: "?"
  defp nullable(_), do: ""

  defp as_ts({[name, :string], default}), do: "#{name}#{nullable(default)}: string"
  defp as_ts({[name, :integer], default}), do: "#{name}#{nullable(default)}: number"
  defp as_ts({[name, :float], default}), do: "#{name}#{nullable(default)}: number"
  defp as_ts({[name, :bool], default}), do: "#{name}#{nullable(default)}: boolean"
  # external types have to be nullable
  defp as_ts({[name, :external, type_name], nil}), do: "#{name}?: #{type_name}"

  defp as_ts({[name, :union, type_name, _is_string, _values], default}),
    do: "#{name}#{nullable(default)}: #{type_name}"

  defp as_ts({[name, :union, type_name, values], default}),
    do: as_ts({[name, :union, type_name, false, values], default})

  defp as_ts({[name, :list, type_name], default}), do: "#{as_ts({[name, type_name], default})}[]"
  defp as_ts({[name, v], default}), do: "#{name}#{nullable(default)}: #{v}"
  defp as_ts({[name], default}), do: "#{name}#{nullable(default)}: any"

  defp as_import({[_, :external, name], _default}),
    do: "import type { #{name} } from \"./#{name}\""

  defp as_import({[_, :list, name], _default}) when is_binary(name),
    do: "import type { #{name} } from \"./#{name}\""

  defp as_import(_), do: ""

  defp as_union({[name, :union, type_name, values], default}),
    do: as_union({[name, :union, type_name, false, values], default})

  defp as_union({[_, :union, type_name, is_string, values], _default}) do
    values =
      if is_string do
        Enum.map(values, &"\"#{&1}\"")
      else
        values
      end
      |> Enum.join(" | ")

    "export type #{type_name} = #{values}"
  end

  defp as_union(_), do: ""

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

  defp format(strings, level \\ 0),
    do:
      Enum.map(strings, &indent(&1, level))
      |> Enum.filter(&(&1 != ""))
      |> Enum.join("\n")

  defp get_defaults(field) do
    case field do
      {f, v} -> {f, v}
      f when is_list(f) -> {f, nil}
      f -> {f, nil}
    end
  end

  defp js_literal({name, value}) do
    value =
      case value do
        :required -> Atom.to_string(name)
        _ -> JSLiteral.literal(value)
      end

    "#{name}: " <> value <> ","
  end

  defp format_struct({[name | _rest], default}) when is_atom(name), do: {name, default}

  defp required?(field) do
    case field do
      {_, :required} -> true
      _ -> false
    end
  end

  defp build(name, fields, other_imports) do
    directory = Application.get_env(:genus, :directory, "ts")

    imports =
      Enum.map(fields, &as_import/1) |> Enum.concat(other_imports) |> Enum.dedup() |> format()

    unions = Enum.map(fields, &as_union/1) |> format()

    interface =
      "\nexport interface #{name} {\n" <> (Enum.map(fields, &as_ts/1) |> format(1)) <> "\n}\n"

    apply = "export const apply_#{Macro.underscore(name)} = (v: any): #{name} => v\n"

    required =
      Enum.filter(fields, &required?/1)
      |> Enum.map(&as_ts/1)
      |> Enum.join(", ")

    generator =
      "export const new_#{Macro.underscore(name)} = (#{required}): #{name} => {\n" <>
        ("return {\n" |> indent(1)) <>
        (Enum.map(fields, &format_struct/1) |> Enum.map(&js_literal/1) |> format(2)) <>
        "\n" <>
        indent("}\n", 1) <> "}"

    File.mkdir_p!(directory)

    File.write!(
      Path.join(directory, name <> ".ts"),
      Enum.join([imports, unions, interface, apply, generator], "\n")
    )
  end

  defmacro genus(opts) do
    name = opts[:name]
    imports = Access.get(opts, :imports, [])

    fields =
      opts[:fields]
      |> Enum.map(&get_defaults/1)

    build(name, fields, imports)

    keys_and_defaults =
      Enum.map(fields, &format_struct/1)
      |> Enum.map(fn f ->
        case f do
          {field, :required} -> {field, nil}
          _ -> f
        end
      end)

    required =
      Enum.filter(fields, &required?/1)
      |> Enum.map(fn field ->
        case field do
          {[name | _], _} -> name
        end
      end)

    quote bind_quoted: [required: required, keys_and_defaults: keys_and_defaults] do
      @enforce_keys required
      defstruct keys_and_defaults
    end
  end
end