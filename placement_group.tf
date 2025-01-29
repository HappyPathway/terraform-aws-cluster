# aws_placement_group
resource "aws_placement_group" "pg" {
  count           = var.placement_group == null ? 0 : 1
  name            = var.placement_group.name
  strategy        = var.placement_group.strategy
  tags            = var.placement_group.tags
  partition_count = var.placement_group.partition_count
  spread_level    = var.placement_group.spread_level
}
