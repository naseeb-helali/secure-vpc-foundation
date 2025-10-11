# S3 Gateway Endpoint (route-table based, no SG, free)
resource "aws_vpc_endpoint" "s3_gw" {
  vpc_id            = aws_vpc.main.id
  service_name      = "com.amazonaws.${var.region}.s3"
  vpc_endpoint_type = "Gateway"
  route_table_ids   = [aws_route_table.private.id]
  tags              = merge(local.common_tags, { Name = "${local.name_prefix}-s3-gateway-endpoint" })
}
