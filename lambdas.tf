#####################
# Get Best Sellers Lambda

data "aws_iam_policy_document" "assume_role_lambda_policy" {
  statement {
    sid = "lambdaAssumeRolePolicy"

    actions = ["sts:AssumeRole"]

    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "get_best_sellers_role" {
  name = "BestSellersNYTRole"

  assume_role_policy = data.aws_iam_policy_document.assume_role_lambda_policy.json
}

locals {
  best_sellers_name = "get_best_sellers_nyt"
}

data "archive_file" "get_best_sellers_archive_file" {
  type = "zip"

  source_file = "${path.module}/lambdas/${local.best_sellers_name}.py"
  output_path = "${path.module}/${local.best_sellers_name}.zip"
}

resource "aws_lambda_function" "get_best_sellers_nyt" {
  filename = "${local.best_sellers_name}.zip"
  function_name = local.best_sellers_name
  handler = "${local.best_sellers_name}.lambda_handler"
  role = aws_iam_role.get_best_sellers_role.arn

  environment {
    variables = {
      KEY = var.nyt_api_key
    }
  }

  runtime = "python3.9"
  source_code_hash = data.archive_file.get_best_sellers_archive_file.output_base64sha256
}

resource "aws_cloudwatch_log_group" "get_best_sellers_log_group" {
  name = "/aws/lambda/${aws_lambda_function.get_best_sellers_nyt}"

  retention_in_days = var.log_retention_in_days
}

data "aws_iam_policy_document" "get_best_sellers_policy_document" {
  statement {
    sid = "GetBestSellersPolicy"

    effect = "Allow"

    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]

    resources = [
      aws_cloudwatch_log_group.get_best_sellers_log_group,
      "${aws_cloudwatch_log_group.get_best_sellers_log_group}*"
    ]
  }
}

resource "aws_iam_role_policy" "get_best_sellers_role_policy" {
  policy = data.aws_iam_policy_document.get_best_sellers_policy_document.json
  role   = aws_iam_role.get_best_sellers_role.id
}