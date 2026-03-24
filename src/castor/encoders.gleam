import castor
import gleam/json
import gleam/list
import gleam/option.{None, Some}

/// Encode schema with minimal optional properties.
/// Compatible with AWS Bedrock Structured Output
/// See https://aws.amazon.com/blogs/machine-learning/structured-outputs-on-amazon-bedrock-schema-compliant-ai-responses/
pub fn encode_minimal(schema) {
  case schema {
    castor.Boolean(title:, description:, deprecated:, ..) ->
      json_object([
        #("type", Some(json.string("boolean"))),
        #("title", option.map(title, json.string)),
        #("description", option.map(description, json.string)),
        #("deprecated", Some(json.bool(deprecated))),
      ])
    castor.Integer(..) as int -> {
      json_object([
        #("type", Some(json.string("integer"))),
        #("nullable", Some(json.bool(int.nullable))),
        #("title", option.map(int.title, json.string)),
        #("description", option.map(int.description, json.string)),
        #("deprecated", Some(json.bool(int.deprecated))),
      ])
    }
    castor.Number(..) as number -> {
      json_object([
        #("type", Some(json.string("number"))),
        #("title", option.map(number.title, json.string)),
        #("description", option.map(number.description, json.string)),
        #("deprecated", Some(json.bool(number.deprecated))),
      ])
    }
    castor.String(..) as string -> {
      json_object([
        #("type", Some(json.string("string"))),
        #("Pattern", option.map(string.pattern, json.string)),
        #("Format", option.map(string.format, json.string)),
        #("title", option.map(string.title, json.string)),
        #("description", option.map(string.description, json.string)),
      ])
    }
    castor.Null(..) as null -> {
      json_object([
        #("type", Some(json.string("null"))),
        #("title", option.map(null.title, json.string)),
        #("description", option.map(null.description, json.string)),
        #("deprecated", Some(json.bool(null.deprecated))),
      ])
    }
    castor.Array(..) as array -> {
      json_object([
        #("type", Some(json.string("array"))),
        #("items", Some(ref_encode(array.items))),
        #("title", option.map(array.title, json.string)),
        #("description", option.map(array.description, json.string)),
      ])
    }
    castor.Object(..) as object -> {
      json_object([
        #("type", Some(json.string("object"))),
        #(
          "properties",
          Some(json.dict(object.properties, fn(x) { x }, ref_encode)),
        ),
        #("additionalProperties", Some(json.bool(False))),
        #("required", Some(json.array(object.required, json.string))),
        #("title", option.map(object.title, json.string)),
        #("description", option.map(object.description, json.string)),
      ])
    }
    _ -> json.null()
  }
}

fn json_object(properties) {
  properties
  |> list.filter_map(fn(property) {
    let #(key, value) = property
    case value {
      Some(value) -> Ok(#(key, value))
      None -> Error(Nil)
    }
  })
  |> json.object
}

fn ref_encode(ref) {
  case ref {
    castor.Inline(schema) -> encode_minimal(schema)
    castor.Ref(reference, ..) ->
      json.object([#("$ref", json.string(reference))])
  }
}
