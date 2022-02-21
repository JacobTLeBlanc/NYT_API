resource "aws_api_gateway_rest_api" "nyt" {
  name        = "nyt"
  description = "Rest API for NYT"
}

#####################
# /get_best_sellers

resource "aws_api_gateway_resource" "get_best_sellers_resource" {
  parent_id   = aws_api_gateway_rest_api.nyt.root_resource_id
  path_part   = local.best_sellers_name
  rest_api_id = aws_api_gateway_rest_api.nyt.id
}

resource "aws_api_gateway_resource" "get_best_sellers_date_resource" {
  parent_id   = aws_api_gateway_resource.get_best_sellers_resource.id
  path_part   = "{date}"
  rest_api_id = aws_api_gateway_rest_api.nyt.id
}

resource "aws_api_gateway_resource" "get_best_sellers_category_resource" {
  parent_id   = aws_api_gateway_resource.get_best_sellers_date_resource.id
  path_part   = "{category}"
  rest_api_id = aws_api_gateway_rest_api.nyt.id
}

resource "aws_api_gateway_method" "get_best_sellers_method" {
  authorization = "NONE"
  http_method   = "GET"
  resource_id   = aws_api_gateway_resource.get_best_sellers_category_resource.id
  rest_api_id   = aws_api_gateway_rest_api.nyt.id
}

resource "aws_api_gateway_integration" "get_best_sellers_integration" {
  http_method = aws_api_gateway_method.get_best_sellers_method.http_method
  resource_id = aws_api_gateway_resource.get_best_sellers_category_resource.id
  rest_api_id = aws_api_gateway_rest_api.nyt.id

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.get_best_sellers_nyt.invoke_arn
}

#####################
# Deployment

resource "aws_api_gateway_deployment" "nyt_deployment" {
  rest_api_id = aws_api_gateway_rest_api.nyt.id

  triggers = {
    redeployment = sha1(jsonencode(aws_api_gateway_rest_api.nyt.body))
  }

  lifecycle {
    create_before_destroy = true
  }

  depends_on = [aws_api_gateway_integration.get_best_sellers_integration]
}

resource "aws_api_gateway_stage" "v1" {
  deployment_id = aws_api_gateway_deployment.nyt_deployment.id
  rest_api_id   = aws_api_gateway_rest_api.nyt.id
  stage_name    = "v1"
}