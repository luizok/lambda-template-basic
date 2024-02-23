data "archive_file" "source_code" {
  type        = "zip"
  source_dir  = "../app/"
  output_path = "../output/lambda.zip"
}

resource "aws_lambda_function" "lambda" {
  filename         = data.archive_file.source_code.output_path
  function_name    = var.lambda-name
  role             = aws_iam_role.iam_for_lambda.arn
  handler          = "lambda_function.lambda_handler"
  source_code_hash = filebase64sha256(data.archive_file.source_code.output_path)
  runtime          = "python3.11"
  timeout          = 60

  layers = [
    aws_lambda_layer_version.packages.arn
  ]
}

resource "null_resource" "build_layer" {
  provisioner "local-exec" {
    command = "cd .. && make build_layer"
  }

  triggers = {
    requirements_changed = filebase64sha256("../app/requirements.txt")
  }
}

resource "aws_lambda_layer_version" "packages" {
  filename         = "../output/layer.zip"
  layer_name       = "${var.lambda-name}-packages"
  description      = "Packages for ${var.lambda-name} >> ${file("../app/requirements.txt")}"
  compatible_runtimes = ["python3.12"]

  depends_on = [ null_resource.build_layer ]
}
