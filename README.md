# Genus

Macro for generating Typescript types and Elixir structs

## Installation

```elixir
def deps do
  [
    {:genus, git: "git@github.com:bwireman/genus.git"}
  ]
end
```

## Usage

```elixir
defmodule User do
  # load the `genus` macro
  use Genus
  genus(
    name: "User",
    fields: [
      # formats {[name, type], required | default_value}
      {[:id, :string], :required},
      [:email, :string],
      {[:active, :bool], false},
      {[:role, :union, "Role", true, [:enduser, :admin, :superuser]], :enduser}
    ]
  )
end
```

### Elixir output

```elixir
defmodule User do
  @enforce_keys [:id]
  defstruct [id: nil, email: nil, active: false, role: :enduser]
end
```

### Typescript output

```typescript
export type Role = "enduser" | "admin" | "superuser";

export interface User {
  id: string;
  email?: string;
  active: boolean;
  role: Role;
}

export const apply_user = (v: any): User => v;

export const new_user = (id: string): User => {
  return {
    id: id,
    email: undefined,
    active: false,
    role: "enduser",
  };
};
```

### Config

```elixir
import Config

config :genus,
  # path directory to save the write TypeScript code to
  # defaults to "./ts"
  directory: "types",
  # indent spacer for generated TypeScript
  # defaults to "  "
  indent: "\t"
```

## Types

| format             | Elixir type  | TS type   |
| ------------------ | ------------ | --------- |
| `[name, :string]`  | `String.t()` | `string`  |
| `[name, :integer]` | `integer()`  | `number`  |
| `[name, :float]`   | `float()`    | `number`  |
| `[name, :bool]`    | `bool()`     | `boolean` |
| `[name]`           | `any()`      | `any`     |
| `[name, :external, type_name]` | `any()`  | `type_name`   |
| `[name, :list, type_name]`     | `list()` | `type_name[]` |
| `[name, :union, type_name, is_string, values]` | `any()` | `type_name` |

#### Type Options
- type_name `String.t()`: represents the TS type to use
- is_string `bool()`: Should the union be represented as strings in TS
- values `list()`: Values that compose the union

## Field Options

### Format
```elixir
  # wrap in a tuple and specify options
  {[type_format], option}
```

#### `default` | `:required`

Fields default to being optional and with a `nil` default in Elixir and nullable with a default of `undefined` in TypeScript. If you specify a value that will be the default value in both Elixir and Typescript. You can also specify `:required` and mark the field as required in both the Elixir struct and the generator function