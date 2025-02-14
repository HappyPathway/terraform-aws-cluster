mock_resource "aws_autoscaling_group" {
    defaults = {
      id = "mock-asg"
      arn = "arn:aws:autoscaling:us-east-1:123456789012:autoScalingGroup:11111111-2222-3333-4444-555555555555:autoScalingGroupName/mock-asg"
      name = "test-asg"
      max_size = 3
      min_size = 1
      desired_capacity = 2
      vpc_zone_identifier = ["subnet-12345678"]
      health_check_type = "ELB"
      health_check_grace_period = 300
      capacity_rebalance = true
      metrics_granularity = "1Minute"
      enabled_metrics = [
        "GroupMinSize",
        "GroupMaxSize", 
        "GroupDesiredCapacity",
        "GroupInServiceInstances"
      ]
      instance_refresh = [{
        strategy = "Rolling"
        preferences = [{
          min_healthy_percentage = 90
          checkpoint_percentages = [20, 40, 60, 80, 100]
          auto_rollback = true
        }]
      }]
      launch_template = [{
        id = "lt-0abcd1234efgh5678"
        version = "$Latest"
      }]
    }
  }

  mock_resource "aws_autoscaling_policy" {
    defaults = {
      id = "mock-policy"
      arn = "arn:aws:autoscaling:us-east-1:123456789012:scalingPolicy:11111111-2222-3333-4444-555555555555:autoScalingGroupName/mock-asg:policyName/mock-policy"
      name = "mock-policy"
      adjustment_type = "ChangeInCapacity"
      autoscaling_group_name = "test-asg"
      policy_type = "TargetTrackingScaling"
      metric_aggregation_type = "Average" 
      estimated_instance_warmup = 300
      target_tracking_configuration = [{
        target_value = 50.0
        predefined_metric_specification = [{
          predefined_metric_type = "ASGAverageCPUUtilization"
        }]
      }]
      predictive_scaling_configuration = [{
        mode = "ForecastAndScale"
        scheduling_buffer_time = 300
        max_capacity_breach_behavior = "HonorMaxCapacity"
        metric_specification = [{
          target_value = 70.0
          predefined_scaling_metric_specification = [{
            predefined_metric_type = "ASGAverageCPUUtilization"
            resource_label = "test"
          }]
          predefined_load_metric_specification = [{
            predefined_metric_type = "ASGTotalCPUUtilization"
            resource_label = "test"
          }]
        }]
      }]
    }
  }

  mock_resource "aws_launch_template" {
    defaults = {
      id = "lt-0abcd1234efgh5678"
      arn = "arn:aws:ec2:us-east-1:123456789012:launch-template/lt-0abcd1234efgh5678"
      latest_version = 1
      name = "mock-launch-template"
      version = "$Latest"
      update_default_version = true
      image_id = "ami-12345678"
      instance_type = "t3.micro"
      vpc_security_group_ids = ["sg-12345678"]
    }
  }

  mock_resource "aws_placement_group" {
    defaults = {
      id = "mock-pg"
      arn = "arn:aws:ec2:us-east-1:123456789012:placement-group/mock-pg"
      name = "mock-pg"
      strategy = "cluster"
      partition_count = 7
    }
  }

  mock_resource "aws_autoscaling_schedule" {
    defaults = {
      id = "mock-schedule"
      arn = "arn:aws:autoscaling:us-east-1:123456789012:scheduledUpdateGroupAction:11111111-2222-3333-4444-555555555555:autoScalingGroupName/test-asg:scheduledActionName/mock-schedule"
      scheduled_action_name = "mock-schedule"
      autoscaling_group_name = "test-asg"
      min_size = 1
      max_size = 3
      desired_capacity = 2
      recurrence = "0 9 * * *"
    }
  }

  mock_resource "aws_autoscaling_lifecycle_hook" {
    defaults = {
      id = "mock-lifecycle-hook"
      name = "mock-hook"
      autoscaling_group_name = "test-asg"
      default_result = "CONTINUE"
      heartbeat_timeout = 300
      lifecycle_transition = "autoscaling:EC2_INSTANCE_LAUNCHING"
      notification_target_arn = "arn:aws:sns:us-east-1:123456789012:test-topic"
      role_arn = "arn:aws:iam::123456789012:role/test-role"
    }
  }

  mock_resource "aws_autoscaling_traffic_source_attachment" {
    defaults = {
      id = "mock-traffic-source"
      autoscaling_group_name = "test-asg"
      traffic_source = [{
        identifier = "arn:aws:elasticloadbalancing:us-east-1:123456789012:targetgroup/mock-tg/1234567890123456"
        type = "elbv2"
      }]
    }
  }

  mock_resource "aws_autoscaling_attachment" {
    defaults = {
      id = "mock-attachment"
      autoscaling_group_name = "test-asg"
      lb_target_group_arn = "arn:aws:elasticloadbalancing:us-east-1:123456789012:targetgroup/mock-tg/1234567890123456"
    }
  }

  mock_data "aws_ami" {
    defaults = {
      name = "mock-ami"
      owners = ["amazon"]
      id = "ami-12345678"
      arn = "arn:aws:ec2:us-east-1:123456789012:image/ami-12345678"
      architecture = "x86_64"
      root_device_name = "/dev/xvda"
      root_device_type = "ebs"
      virtualization_type = "hvm"
      image_id = "ami-12345678"
      image_location = "amazon/amzn2-ami-hvm-2.0.20230119.1-x86_64-gp2"
      description = "Mock AMI for testing"
    }
  }

  mock_data "aws_launch_template" {
    defaults = {
      id = "lt-0abcd1234efgh5678"
      arn = "arn:aws:ec2:us-east-1:123456789012:launch-template/lt-0abcd1234efgh5678"
      latest_version = 1
      name = "mock-launch-template"
      image_id = "ami-12345678"
      instance_type = "t3.micro"
      vpc_security_group_ids = ["sg-12345678"]
    }
  }

  mock_data "aws_autoscaling_group" {
    defaults = {
      name = "test-asg"
      id = "mock-asg"
      arn = "arn:aws:autoscaling:us-east-1:123456789012:autoScalingGroup:11111111-2222-3333-4444-555555555555:autoScalingGroupName/mock-asg"
      max_size = 3
      min_size = 1
      desired_capacity = 2
      vpc_zone_identifier = ["subnet-12345678"]
    }
  }
