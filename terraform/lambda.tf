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


resource "aws_iam_role" "lambda" {
    name = "lambda-dynamodb-trigger"
    assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": "sts:AssumeRole",
            "Principal": {
                "Service": "lambda.amazonaws.com"
            },
            "Effect": "Allow",
            "Sid": ""
        }
    ]
}
EOF
}

resource "aws_iam_role_policy" "lambda-log-output" {
    role = "${aws_iam_role.lambda.id}"
    name = "lambda-log-output"
    policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": [
                "logs:CreateLogGroup",
                "logs:CreateLogStream",
                "logs:PutLogEvents"
            ],
            "Resource": "arn:aws:logs:*:*:*",
            "Effect": "Allow"
        }
    ]
}
EOF
}

resource "aws_iam_role_policy" "dynamodb-stream" {
    role = "${aws_iam_role.lambda.id}"
    name = "dynamodb-stream"
    policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": [
                "dynamodb:DescribeStream",
                "dynamodb:GetRecords",
                "dynamodb:GetShardIterator",
                "dynamodb:ListStreams"
            ],
            "Resource": "${aws_dynamodb_table.table.stream_arn}",
            "Effect": "Allow"
        }
    ]
}
EOF
}
