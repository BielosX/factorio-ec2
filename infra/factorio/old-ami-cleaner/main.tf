data "archive_file" "lambda_zip" {
  output_path = "${path.module}/cleaner.zip"
  type = "zip"
  source_file = "${path.module}/cleaner.py"
}

data "aws_iam_policy_document" "cleaner_assume_role" {
  statement {
    effect = "Allow"
    principals {
      identifiers = ["lambda.amazonaws.com"]
      type = "Service"
    }
    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "cleaner_role" {
  assume_role_policy = data.aws_iam_policy_document.cleaner_assume_role.json
}

resource "aws_iam_role_policy_attachment" "attach_lambda_basic" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
  role = aws_iam_role.cleaner_role.id
}

data "aws_iam_policy_document" "cleaner_policy" {
  statement {
    effect = "Allow"
    actions = [
      "ec2:DescribeImages",
      "ec2:DeregisterImage",
      "ec2:DeleteSnapshot"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_role_policy" "cleaner_policy" {
  policy = data.aws_iam_policy_document.cleaner_policy.json
  role = aws_iam_role.cleaner_role.id
}

resource "aws_lambda_function" "ami_cleaner" {
  function_name = "old-ami-cleaner"
  handler = "cleaner.handler"
  role = aws_iam_role.cleaner_role.arn
  runtime = "python3.8"
  filename = data.archive_file.lambda_zip.output_path
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256
  timeout = 60
  environment {
    variables = {
      RETAIN = 1
      IMAGE_NAME_TAG = "factorio-server-image"
    }
  }
}

resource "aws_cloudwatch_event_rule" "run_cleaner_rule" {
  is_enabled = true
  schedule_expression = "rate(1 day)"
}

resource "aws_cloudwatch_event_target" "cleaner_lambda_target" {
  arn = aws_lambda_function.ami_cleaner.arn
  rule = aws_cloudwatch_event_rule.run_cleaner_rule.name
}

resource "aws_lambda_permission" "allow_cw_invoke" {
  action = "lambda:InvokeFunction"
  function_name = aws_lambda_function.ami_cleaner.function_name
  principal = "events.amazonaws.com"
}