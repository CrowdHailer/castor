import castor
import gleam/dynamic
import gleam/dynamic/decode
import gleam/json
import gleam/option.{None, Some}
import gleeunit
import non_empty_list
import oas/generator/utils

pub fn main() -> Nil {
  gleeunit.main()
}

pub fn enum_test() {
  let raw =
    dynamic.properties([
      #(
        dynamic.string("enum"),
        dynamic.list([
          dynamic.string("red"),
          dynamic.string("amber"),
          dynamic.string("green"),
        ]),
      ),
    ])
  assert Ok(
      castor.Enum(
        non_empty_list.new(utils.String("red"), [
          utils.String("amber"),
          utils.String("green"),
        ]),
      ),
    )
    == decode.run(raw, castor.decoder())
}

pub fn const_test() {
  let raw =
    dynamic.properties([
      #(dynamic.string("const"), dynamic.string("Highlander")),
    ])
  assert Ok(castor.Enum(non_empty_list.single(utils.String("Highlander"))))
    == decode.run(raw, castor.decoder())
}

pub fn simple_schema_test() {
  assert castor.boolean()
    |> castor.encode
    |> json.to_string
    == "{\"type\":\"boolean\",\"nullable\":false,\"deprecated\":false}"
}

pub fn list_schema_test() {
  assert castor.array(castor.Inline(castor.integer()))
    |> castor.encode
    |> json.to_string
    == "{\"type\":\"array\",\"uniqueItems\":false,\"items\":{\"type\":\"integer\",\"nullable\":false,\"deprecated\":false},\"nullable\":false,\"deprecated\":false}"
}

pub fn object_schema_test() {
  assert castor.object([
      castor.field("age", castor.integer()),
      castor.optional_field("nickname", castor.string()),
    ])
    |> castor.encode
    |> json.to_string
    == "{\"type\":\"object\",\"properties\":{\"nickname\":{\"type\":\"string\",\"nullable\":false,\"deprecated\":false},\"age\":{\"type\":\"integer\",\"nullable\":false,\"deprecated\":false}},\"minProperties\":0,\"required\":[\"age\"],\"nullable\":false,\"deprecated\":false}"
}

pub fn with_extra_properties_test() {
  assert castor.Integer(
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

pub fn decode_test() {
  assert "{\"type\":\"boolean\",\"nullable\":false,\"deprecated\":false}"
    |> json.parse(castor.decoder())
    == Ok(castor.Boolean(False, None, None, False))
}

pub fn object_and_all_of_test() {
  let assert Ok(schema) =
    "{
  \"type\": \"object\",
  \"allOf\": [
    {
      \"type\": \"object\",
      \"required\": [\"foo\"],
      \"properties\": {
        \"foo\": {
          \"type\": \"string\"
        }
      }
    },
    {
      \"$ref\": \"#/components/schemas/Additional\"
    }
  ]
}"
    |> json.parse(castor.decoder())
  assert castor.AllOf(
      non_empty_list.NonEmptyList(
        castor.Inline(castor.object([castor.field("foo", castor.string())])),
        [castor.ref("#/components/schemas/Additional")],
      ),
    )
    == schema
}
