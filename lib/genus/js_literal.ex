defprotocol Genus.JSLiteral do
  @spec literal(t) :: String.t()
  def literal(value)
end

defimpl Genus.JSLiteral, for: BitString do
  def literal(value), do: "\"#{value}\""
end

defimpl Genus.JSLiteral, for: String do
  @spec literal(String.t()) :: <<_::16, _::_*8>>
  def literal(value), do: "\"#{value}\""
end

defimpl Genus.JSLiteral, for: Integer do
  def literal(value), do: Integer.to_string(value)
end

defimpl Genus.JSLiteral, for: Float do
  def literal(value), do: Float.to_string(value)
end

defimpl Genus.JSLiteral, for: Map do
  def literal(value) do
    contents =
      List.zip([
        Map.keys(value) |> Enum.map(&Genus.JSLiteral.literal/1),
        Map.values(value) |> Enum.map(&Genus.JSLiteral.literal/1)
      ])
      |> Enum.map(&(elem(&1, 0) <> ":" <> elem(&1, 1)))
      |> Enum.join(",\n")

    "{\n" <> contents <> "\n}"
  end
end

defimpl Genus.JSLiteral, for: Atom do
  def literal(value) do
    case value do
      nil -> "undefined"
      true -> "true"
      false -> "false"
      _ -> "\"#{value}\""
    end
  end
end

defimpl Genus.JSLiteral, for: List do
  def literal(value) do
    "[" <> (Enum.map(value, &Genus.JSLiteral.literal/1) |> Enum.join(", ")) <> "]"
  end
end

defimpl Genus.JSLiteral, for: Any do
  def literal(value) do
    Inspect.inspect(value, [])
  end
end
