import castor.{encode_minimal}
import gleam/json
import gleam/string

pub fn encode_minimal_object_has_additional_properties_false_test() {
  let encoded = json.to_string(fixture())
  assert string.contains(encoded, "additionalProperties\":false")
}

pub fn encode_minimal_array_has_no_minimum_test() {
  let encoded = json.to_string(fixture())
  assert !string.contains(encoded, "minimum")
}

pub fn encode_minimal_array_has_no_maximum_test() {
  let encoded = json.to_string(fixture())
  assert !string.contains(encoded, "maximum")
}

pub fn encode_minimal_string_has_no_minlength_test() {
  let encoded = json.to_string(fixture())
  assert !string.contains(encoded, "MinLength")
}

pub fn encode_minimal_string_has_no_maxlength_test() {
  let encoded = json.to_string(fixture())
  assert !string.contains(encoded, "MaxLength")
}

fn fixture() {
  let schema_def =
    castor.object([
      castor.optional_field(
        "alpha",
        castor.array(castor.Inline(castor.string())),
      ),
      castor.optional_field("beta", castor.boolean()),

      castor.optional_field("india", castor.integer()),
      castor.optional_field("november", castor.number()),
      castor.optional_field("sierra", castor.string()),
    ])
  encode_minimal(schema_def)
}
