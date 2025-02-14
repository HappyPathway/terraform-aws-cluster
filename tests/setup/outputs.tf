output "vpc_id" {
  value = aws_vpc.test.id
}

output "subnet_id" {
  value = aws_subnet.test.id
}

output "launch_template_id" {
  value = aws_launch_template.test.id
}

output "launch_template_name" {
  value = aws_launch_template.test.name
}

output "ami_id" {
  value = data.aws_ami.ubuntu.id
}

output "security_group_id" {
  value = aws_security_group.test.id
}

output "sns_topic_arn" {
  value = aws_sns_topic.test.arn
}

output "iam_role_arn" {
  value = aws_iam_role.test.arn
}

output "target_group_arn" {
  value = aws_lb_target_group.test.arn
}

output "pet_name" {
  value = random_pet.pet.id
}