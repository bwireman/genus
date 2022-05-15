defprotocol JSLiteral do
  @spec literal(t) :: String.t()
  def literal(value)
end

defimpl JSLiteral, for: BitString do
  def literal(value), do: "\"#{value}\""
end

defimpl JSLiteral, for: String do
  def literal(value), do: "\"#{value}\""
end

defimpl JSLiteral, for: Integer do
  def literal(value), do: Integer.to_string(value)
end

defimpl JSLiteral, for: Float do
  def literal(value), do: Float.to_string(value)
end

defimpl JSLiteral, for: Map do
  def literal(value) do
    contents =
      List.zip([
        Map.keys(value) |> Enum.map(&JSLiteral.literal/1),
        Map.values(value) |> Enum.map(&JSLiteral.literal/1)
      ])
      |> Enum.map(&(elem(&1, 0) <> ":" <> elem(&1, 1)))
      |> Enum.join(",\n")

    "{\n" <> contents <> "\n}"
  end
end

defimpl JSLiteral, for: Atom do
  def literal(value) do
    case value do
      nil -> "undefined"
      true -> "true"
      false -> "false"
      _ -> "\"#{value}\""
    end
  end
end

defimpl JSLiteral, for: List do
  def literal(value) do
    "[" <> (Enum.map(value, &JSLiteral.literal/1) |> Enum.join(", ")) <> "]"
  end
end

defimpl JSLiteral, for: Any do
  def literal(value) do
    Inspect.inspect(value, [])
  end
end
