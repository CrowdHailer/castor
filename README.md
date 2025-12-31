# castor

Work with JSON Schema in Gleam. Supports building schemas as well as encoding decoding from json schema file.

[![Package Version](https://img.shields.io/hexpm/v/castor)](https://hex.pm/packages/castor)
[![Hex Docs](https://img.shields.io/badge/hex-docs-ffaff3)](https://hexdocs.pm/castor/)

```sh
gleam add castor@1
```
## Build schemas
Build schemas using the castor helper function.
Serialize via JSON

```gleam
import castor

pub fn simple_schema() {
  castor.boolean()
  |> castor.encode
  |> json.to_string
  // "{"type":"boolean","nullable":false,"deprecated":false}"
}

pub fn list_schema()  {
  castor.array(castor.Inline(castor.integer()))
  |> castor.encode
  |> json.to_string
  |> io.println
  // {"type":"array","uniqueItems":false,"items":{"type":"integer","nullable":false,"deprecated":false},"nullable":false,"deprecated":false}
}
```

Create record with either required or optional fields

```gleam
import castor

pub fn object_schema() {
  castor.object([
    castor.field("age", castor.integer()),
    castor.optional_field("nickname", castor.string()),
  ])
  |> castor.encode
  |> json.to_string
  == "{\"type\":\"object\",\"properties\":{\"nickname\":{\"type\":\"string\",\"nullable\":false,\"deprecated\":false},\"age\":{\"type\":\"integer\",\"nullable\":false,\"deprecated\":false}},\"minProperties\":0,\"required\":[\"age\"],\"nullable\":false,\"deprecated\":false}"
}
```

To add other schema information such as maximum and minimum use the schema objects directly.

```gleam
```gleam
import castor

pub fn number_schema() {
  castor.Integer(
    multiple_of: None,
    maximum: Some(100),
    exclusive_maximum: None,
    minimum: Some(25),
    exclusive_minimum: None,
    nullable: False,
    title: Some("bigish number"),
    description: Some("A two digit number bigger that"),
    deprecated: True,
  )
  |> castor.encode
  |> json.to_string
  == "{\"type\":\"integer\",\"maximum\":100,\"minimum\":25,\"nullable\":false,\"title\":\"bigish number\",\"description\":\"A two digit number bigger that\",\"deprecated\":true}"
}
```

### OAS generator

Manually writing encoders and decoders can be tedious.
Check out [oas_generator](https://github.com/crowdhailer/oas_generator) to derive encodes and decoders from schema.

## Decoding schemas

Use the `decoder` to decode a schema

```gleam
import gleam/json
import castor

pub fn decode(){
  "{\"type\":\"boolean\",\"nullable\":false,\"deprecated\":false}"
  |> json.parse(castor.decoder())
  == Ok(castor.Boolean(False, None, None, False))
}
```

Further documentation can be found at <https://hexdocs.pm/castor>.

## Development

```sh
gleam run   # Run the project
gleam test  # Run the tests
```

## Notes

This currently depends on `oas_generator_utils`.
The `Any` type defined there is for decoded and introspectable JSON.
I would like to not depend on this but probably requires some parameterised versions of the decoder.

## Credit

Created for [EYG](https://eyg.run/), a new integration focused programming language.