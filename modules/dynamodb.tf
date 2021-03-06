resource "aws_dynamodb_table" "code-table" {
  name         = "twicode-${var.env_name}-code"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "page_id"

  attribute {
    name = "page_id"
    type = "S"
  }

  tags = {
    project   = "Twicode"
    Terraform = true
  }
}
