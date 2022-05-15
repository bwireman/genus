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
  defp as_ts({[name, :external, kind], nil}), do: "#{name}?: #{kind}"

  defp as_ts({[name, :union, type_name, _is_string, _values], default}),
    do: "#{name}#{nullable(default)}: #{type_name}"

  defp as_ts({[name, :union, type_name, values], default}),
    do: as_ts({[name, :union, type_name, false, values], default})

  defp as_ts({[name, :list, kind], default}), do: "#{as_ts({[name, kind], default})}[]"
  defp as_ts({[name, v], default}), do: "#{name}#{nullable(default)}: #{v}"
  defp as_ts({[name], default}), do: "#{name}#{nullable(default)}: any"

  defp as_import({[_, :external, name], _default}),
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

  defp format(strings, indent \\ 0) do
    if indent > 0 do
      level =
        case indent do
          1 -> "    "
          2 -> "        "
        end

      Enum.map(strings, &(level <> &1))
    else
      strings
    end
    |> Enum.filter(&(&1 != ""))
    |> Enum.join("\n")
  end

  defp get_defaults(field) do
    case field do
      {f, v} -> {f, v}
      f when is_list(f) -> {f, nil}
      f -> {f, nil}
    end
  end

  defp js_literal({name, value}), do: "#{name}: " <> JSLiteral.literal(value) <> ","

  defp format_struct({[name | _rest], default}) when is_atom(name), do: {name, default}

  defp build(name, fields) do
    directory = Application.get_env(:genus, :directory, "ts")

    imports = Enum.map(fields, &as_import/1) |> format()
    unions = Enum.map(fields, &as_union/1) |> format()

    interface = "\nexport interface #{name} {"
    contents = (Enum.map(fields, &as_ts/1) |> format(1)) <> "\n}\n"

    apply = "export const apply_#{Macro.underscore(name)} = (v: any): #{name} => v\n"

    generator =
      "export const new_#{Macro.underscore(name)} = (): #{name} => {\n    return {\n" <>
        (Enum.map(fields, &format_struct/1) |> Enum.map(&js_literal/1) |> format(2)) <>
        "\n    }\n}"

    File.mkdir_p!(directory)

    File.write!(
      Path.join(directory, name <> ".ts"),
      Enum.join([imports, unions, interface, contents, apply, generator], "\n")
    )
  end

  defmacro genus(opts) do
    name = opts[:name]

    fields =
      opts[:fields]
      |> Enum.map(&get_defaults/1)

    build(name, fields)

    keys_and_defaults = Enum.map(fields, &format_struct/1)

    quote bind_quoted: [keys_and_defaults: keys_and_defaults] do
      defstruct keys_and_defaults
    end
  end
end
