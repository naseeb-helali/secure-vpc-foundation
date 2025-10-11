resource "random_id" "suffix" {
  byte_length = 2
}

resource "aws_s3_bucket" "flowlogs" {
  bucket        = "${local.name_prefix}-flowlogs-${random_id.suffix.hex}"
  force_destroy = true
  tags          = merge(local.common_tags, { Name = "${local.name_prefix}-flowlogs" })
}

data "aws_iam_policy_document" "fl_assume" {
  statement {
    actions = ["sts:AssumeRole"]
    principals { type = "Service", identifiers = ["vpc-flow-logs.amazonaws.com"] }
  }
}

resource "aws_iam_role" "flowlogs_role" {
  name               = "${local.name_prefix}-flowlogs-role"
  assume_role_policy = data.aws_iam_policy_document.fl_assume.json
}

data "aws_iam_policy_document" "fl_policy" {
  statement {
    actions   = ["s3:PutObject","s3:PutObjectAcl","s3:GetBucketLocation"]
    resources = [aws_s3_bucket.flowlogs.arn, "${aws_s3_bucket.flowlogs.arn}/*"]
  }
}

resource "aws_iam_role_policy" "flowlogs_policy" {
  name   = "${local.name_prefix}-flowlogs-policy"
  role   = aws_iam_role.flowlogs_role.id
  policy = data.aws_iam_policy_document.fl_policy.json
}

resource "aws_flow_log" "vpc" {
  vpc_id               = aws_vpc.main.id
  traffic_type         = "ALL"
  log_destination_type = "s3"
  log_destination      = aws_s3_bucket.flowlogs.arn
  iam_role_arn         = aws_iam_role.flowlogs_role.arn
  tags                 = merge(local.common_tags, { Name = "${local.name_prefix}-vpc-flowlogs" })
}
