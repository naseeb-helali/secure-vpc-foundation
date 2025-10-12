###############################################################
# flowlogs.tf — VPC Flow Logs Configuration
# Scope: Phase 1 (Free Tier, single VPC)
# ------------------------------------------------------------
# This file defines:
# - S3 bucket for log storage
# - IAM role + policy for Flow Logs service
# - VPC Flow Log resource
###############################################################

##############################
# Random suffix for bucket name
##############################
# Ensures uniqueness across accounts/regions.

resource "random_id" "suffix" {
  byte_length = 2
}

##############################
# S3 Bucket for Flow Logs
##############################
# Stores all VPC Flow Logs.
# force_destroy = true allows clean teardown in test environments.

resource "aws_s3_bucket" "flowlogs" {
  bucket        = "${var.project}-flowlogs-${random_id.suffix.hex}"
  force_destroy = true

  tags = {
    Name        = "${var.project}-flowlogs"
    Environment = "dev"
    Purpose     = "vpc-flow-logs"
  }
}

##############################
# IAM Role for Flow Logs
##############################
# Grants the Flow Logs service permission to write objects to S3.

data "aws_iam_policy_document" "flowlogs_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["vpc-flow-logs.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "flowlogs_role" {
  name               = "${var.project}-flowlogs-role"
  assume_role_policy = data.aws_iam_policy_document.flowlogs_assume_role.json

  tags = {
    Name = "${var.project}-flowlogs-role"
  }
}

##############################
# IAM Policy for S3 Access
##############################
# Allows Flow Logs service to put logs into the S3 bucket.

data "aws_iam_policy_document" "flowlogs_policy" {
  statement {
    actions = [
      "s3:PutObject",
      "s3:PutObjectAcl",
      "s3:GetBucketLocation"
    ]
    resources = [
      aws_s3_bucket.flowlogs.arn,
      "${aws_s3_bucket.flowlogs.arn}/*"
    ]
  }
}

resource "aws_iam_role_policy" "flowlogs_role_policy" {
  name   = "${var.project}-flowlogs-policy"
  role   = aws_iam_role.flowlogs_role.id
  policy = data.aws_iam_policy_document.flowlogs_policy.json
}

##############################
# VPC Flow Log Resource
##############################
# Captures all accepted and rejected traffic for the main VPC.

resource "aws_flow_log" "vpc_flowlog" {
  vpc_id               = aws_vpc.main.id
  traffic_type         = "ALL"
  log_destination_type = "s3"
  log_destination      = aws_s3_bucket.flowlogs.arn
  iam_role_arn         = aws_iam_role.flowlogs_role.arn

  tags = {
    Name = "${var.project}-vpc-flowlogs"
    Level = "all-traffic"
  }

  depends_on = [aws_iam_role_policy.flowlogs_role_policy]
}  vpc_id               = aws_vpc.main.id
  traffic_type         = "ALL"
  log_destination_type = "s3"
  log_destination      = aws_s3_bucket.flowlogs.arn
  iam_role_arn         = aws_iam_role.flowlogs_role.arn
  tags                 = merge(local.common_tags, { Name = "${local.name_prefix}-vpc-flowlogs" })
}
