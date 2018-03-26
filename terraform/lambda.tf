data "archive_file" "lambda-function" {
    type        = "zip"
    output_path = "./_zip/sample-function.zip"
    source {
        filename = "lambda_function.py"
        content  = <<EOF
import json
def lambda_handler(event, context):
    result = json.dumps(event)
    print(result)
    return result
EOF
    }
}

resource "aws_lambda_function" "stream" {
    function_name    = "get-stream"
    handler          = "lambda_function.lambda_handler"
    filename         = "${data.archive_file.lambda-function.output_path}"
    source_code_hash = "${data.archive_file.lambda-function.output_base64sha256}"
    memory_size      = 128
    timeout          = 300
    runtime          = "python3.6"
    role             = "${aws_iam_role.lambda.arn}"
    description      = "Dynamo Trigger Test"
}
