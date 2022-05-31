defmodule Genus.Parse do
  @enforce_keys [:name, :type, :default, :required]
  defstruct [:name, :type, :default, :required, imports: [], type_definitions: []]

  def parse([name, opts]),
    do: %__MODULE__{
      name: "#{name}",
      type: "any",
      default: get_default(opts),
      required: get_required(opts)
    }

  def parse([name, :string, opts]),
    do: %__MODULE__{
      name: "#{name}",
      type: "String",
      default: get_default(opts),
      required: get_required(opts)
    }

  def parse([name, :bool, opts]),
    do: %__MODULE__{
      name: "#{name}",
      type: "boolean",
      default: get_default(opts),
      required: get_required(opts)
    }

  def parse([name, :float, opts]),
    do: %__MODULE__{
      name: "#{name}",
      type: "number",
      default: get_default(opts),
      required: get_required(opts)
    }

  def parse([name, :integer, opts]),
    do: %__MODULE__{
      name: "#{name}",
      type: "number",
      default: get_default(opts),
      required: get_required(opts)
    }

  def parse([name, :list, type, opts]) do
    s = parse([name, type, opts])

    Map.update!(s, :type, &"#{&1}[]")
  end

  def parse([name, :external, type, opts]),
    do: %__MODULE__{
      name: "#{name}",
      type: type,
      default: get_default(opts),
      required: get_required(opts),
      imports: [type]
    }

  def parse([name, :union, type, values, opts]),
    do: %__MODULE__{
      name: "#{name}",
      type: type,
      default: get_default(opts),
      required: get_required(opts),
      type_definitions: [{type, values}]
    }

  def parse([name, :union, type, is_string, values, opts]),
    do: %__MODULE__{
      name: "#{name}",
      type: type,
      default: get_default(opts),
      required: get_required(opts),
      type_definitions:
        {type,
         if is_string do
           values |> Enum.map(&"\"#{&1}\"")
         else
           values
         end}
    }

  def parse([name, type, opts]) when is_binary(type),
    do: %__MODULE__{
      name: "#{name}",
      type: type,
      default: get_default(opts),
      required: get_required(opts)
    }

  defp get_default(opts), do: Access.get(opts, :default, nil)
  defp get_required(opts), do: Access.get(opts, :required, false)

  def collect(parsed, key_name, default), do: Enum.map(parsed, &Map.get(&1, key_name, default))

  def render_type(f = %__MODULE__{}, nullable \\ nil) do
    nullable =
      if nullable == nil do
        not f.required
      else
        nullable
      end

    if nullable do
      "#{f.name}?: #{f.type}"
    else
      "#{f.name}: #{f.type}"
    end
  end

  def as_param_name(f = %__MODULE__{}) do
    f.name
  end

  def as_param_type(f = %__MODULE__{}) do
    render_type(f, not f.required)
  end

  def as_return(f = %__MODULE__{}) do
    if f.required do
      "#{f.name}: #{f.name}"
    else
      default = Genus.JSLiteral.literal(f.default)
      "#{f.name}: #{f.name} || #{default}"
    end
  end

end