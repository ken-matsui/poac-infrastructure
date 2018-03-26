resource "aws_dynamodb_table" "table" {
  name           = "packageinfo"
  read_capacity  = 5
  write_capacity = 5
  hash_key       = "name"
  range_key      = "date"
  attribute {
    name = "name"
    type = "S"
  }
  attribute {
    name = "date"
    type = "S"
  }
  stream_enabled   = true
  stream_view_type = "NEW_IMAGE"
  tags {
    Project        = "poacpm"
  }
}

resource "aws_lambda_event_source_mapping" "table-trigger" {
  depends_on        = ["aws_dynamodb_table.table", "aws_iam_role_policy.dynamodb-stream"]
  batch_size        = 100
  event_source_arn  = "${aws_dynamodb_table.table.stream_arn}"
  enabled           = true
  function_name     = "${aws_lambda_function.stream.arn}"
  starting_position = "TRIM_HORIZON"
}
