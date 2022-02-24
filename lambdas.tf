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
  name = "/aws/lambda/${aws_lambda_function.get_best_sellers_nyt.function_name}"

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
      aws_cloudwatch_log_group.get_best_sellers_log_group.arn,
      "${aws_cloudwatch_log_group.get_best_sellers_log_group.arn}*"
    ]
  }
}

resource "aws_iam_role_policy" "get_best_sellers_role_policy" {
  policy = data.aws_iam_policy_document.get_best_sellers_policy_document.json
  role   = aws_iam_role.get_best_sellers_role.id
}

resource "aws_lambda_permission" "apigw_get_best_sellers" {
  statement_id  = "AllowExecutionFromAPIGatewayGetBestSellers"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.get_best_sellers_nyt.function_name
  principal     = "apigateway.amazonaws.com"

  source_arn = "arn:aws:execute-api:${var.region}:${var.account_id}:${aws_api_gateway_rest_api.nyt.id}/*/${aws_api_gateway_method.get_best_sellers_method.http_method}${aws_api_gateway_resource.get_best_sellers_category_resource.path}"
}

#####################
# Get Categories Lambda

resource "aws_iam_role" "get_categories_role" {
  name = "CategoriesNYTRole"

  assume_role_policy = data.aws_iam_policy_document.assume_role_lambda_policy.json
}

locals {
  categories_name = "get_categories_nyt"
}

data "archive_file" "get_categories_archive_file" {
  type = "zip"

  source_file = "${path.module}/lambdas/${local.categories_name}.py"
  output_path = "${path.module}/${local.categories_name}.zip"
}

resource "aws_lambda_function" "get_categories_nyt" {
  filename = "${local.categories_name}.zip"
  function_name = local.categories_name
  handler = "${local.categories_name}.lambda_handler"
  role = aws_iam_role.get_categories_role.arn

  environment {
    variables = {
      KEY = var.nyt_api_key
    }
  }

  runtime = "python3.9"
  source_code_hash = data.archive_file.get_categories_archive_file.output_base64sha256
}

resource "aws_cloudwatch_log_group" "get_categories_log_group" {
  name = "/aws/lambda/${aws_lambda_function.get_categories_nyt.function_name}"

  retention_in_days = var.log_retention_in_days
}

data "aws_iam_policy_document" "get_categories_policy_document" {
  statement {
    sid = "GetCategoriesPolicy"

    effect = "Allow"

    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]

    resources = [
      aws_cloudwatch_log_group.get_categories_log_group.arn,
      "${aws_cloudwatch_log_group.get_categories_log_group.arn}*"
    ]
  }
}

resource "aws_iam_role_policy" "get_categories_role_policy" {
  policy = data.aws_iam_policy_document.get_categories_policy_document.json
  role   = aws_iam_role.get_categories_role.id
}

resource "aws_lambda_permission" "apigw_get_ccategories" {
  statement_id  = "AllowExecutionFromAPIGatewayGetCategories"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.get_categories_nyt.function_name
  principal     = "apigateway.amazonaws.com"

  source_arn = "arn:aws:execute-api:${var.region}:${var.account_id}:${aws_api_gateway_rest_api.nyt.id}/*/${aws_api_gateway_method.get_categories_method.http_method}${aws_api_gateway_resource.get_categories_resource.path}"
}