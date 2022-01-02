resource "aws_appsync_graphql_api" "appsync_api" {
  name                = "twicode-${var.env_name}-apis"
  authentication_type = "API_KEY"

  schema = <<EOF
input PageId {
  page_id: ID!
}

type Query {
  code(page_id: PageId): CodeSet
  lang(page_id: PageId): Lang
}

type CodeSet {
  code: String!
  lang: String!
}

type Lang {
  lang: String!
}

input Code {
  code: String!
  lang: String!
}

type Mutation {
  createPage(pageCreateInput: Code): Page!
  updatePage(pageUpdateInput: PageId): Page!
  deletePage(pageDeleteInput: PageId): Page!
}

type Page {
  page_id: ID!
  code: String!
  lang: String!
}
EOF

  log_config {
    cloudwatch_logs_role_arn = aws_iam_role.appsync_role.arn
    field_log_level          = "ERROR"
  }
}

resource "aws_appsync_datasource" "appsync_datasource" {
  api_id           = aws_appsync_graphql_api.appsync_api.id
  name             = "TwicodeCodeTable"
  service_role_arn = aws_iam_role.appsync_role.arn
  type             = "AMAZON_DYNAMODB"

  dynamodb_config {
    table_name = aws_dynamodb_table.code-table.name
  }
}

resource "aws_iam_role" "appsync_role" {
  name               = "twicode-${var.env_name}-appsync-role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "appsync.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "appsync_role_policy" {
  name = "twicode-${var.env_name}-appsync-role-policy"
  role = aws_iam_role.appsync_role.id

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "dynamodb:*"
      ],
      "Effect": "Allow",
      "Resource": [
        "${aws_dynamodb_table.code-table.arn}"
      ]
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "appsync_role_policy_attachment" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSAppSyncPushToCloudWatchLogs"
  role       = aws_iam_role.appsync_role.name
}
