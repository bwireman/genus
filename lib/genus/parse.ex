defmodule Genus.Parse do
  @enforce_keys [:name, :atom, :type]
  defstruct [
    :name,
    :atom,
    :type,
    default: nil,
    required: false,
    imports: [],
    type_definitions: []
  ]

  def parse([name, opts]),
    do: build(name, "any", opts)

  def parse([name, :string, opts]),
    do: build(name, "string", opts)

  def parse([name, :bool, opts]),
    do: build(name, "boolean", opts)

  def parse([name, :float, opts]),
    do: build(name, "number", opts)

  def parse([name, :integer, opts]),
    do: build(name, "number", opts)

  def parse([name, :list, type, opts]),
    do: Map.update!(parse([name, type, opts]), :type, &"#{&1}[]")

  def parse([name, :external, type, opts]),
    do: build(name, type, Keyword.put(opts, :imports, [type]))

  def parse([name, :union, type, values, opts]),
    do: parse([name, :union, type, false, values, opts])

  def parse([name, :union, type, is_string, values, opts]) do
    default = Access.get(opts, :default, nil)
    check_union_values(default, values)

    opts =
      Keyword.put(
        opts,
        :type_definitions,
        {type,
         if is_string do
           values |> Enum.map(&"\"#{&1}\"")
         else
           values
         end}
      )

    build(name, type, opts)
  end

  def parse([name, type, opts]) when is_binary(type),
    do: build(name, type, opts)

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

  def as_param_type(f = %__MODULE__{}), do: render_type(f, not f.required)

  def as_return(f = %__MODULE__{}) do
    if f.required do
      "#{f.name}: #{f.name}"
    else
      default = Genus.JSLiteral.literal(f.default)
      "#{f.name}: #{f.name} || #{default}"
    end
  end

  defp build(name, type, opts) do
    f = %__MODULE__{
      name: "#{name}",
      atom: name,
      type: type
    }

    Enum.reduce(
      opts,
      f,
      fn key_v, f ->
        {k, v} = key_v

        if Map.has_key?(f, k) do
          Map.put(f, k, v)
        else
          f
        end
      end
    )
  end

  defp check_union_values(default, values) do
    if not (default == nil or Enum.member?(values, default)) do
      raise "Genus: default values for :union types must be nil or in the possible values"
    end
  end
end
