# morpheus-workspace

Base repository for Morpheus workspace infrastructure modules

## Getting Started

1. Clone this repository:

```bash
git clone git@github.com:HappyPathway/morpheus-workspace.git
cd morpheus-workspace
```

2. Set up Python environment and install dependencies:

```bash
python -m venv .venv
source .venv/bin/activate  # On Windows use: .venv\Scripts\activate
pip install -r scripts/requirements.txt
```

3. Run the initialization script:

```bash
python scripts/init.py
```

This will:

- Verify Git SSH access to GitHub
- Create the workspace directory structure
- Clone or update all project repositories
- Set up repository configurations

For debugging, you can run:

```bash
python scripts/init.py --debug
```

## Repository Structure

This project consists of multiple repositories:

- terraform-aws-cluster: morpheus-workspace::terraform-aws-cluster
- terraform-aws-efs: morpheus-workspace::terraform-aws-efs
- terraform-aws-mq-cluster: morpheus-workspace::terraform-aws-mq-cluster
- terraform-aws-opensearch-cluster: morpheus-workspace::terraform-aws-opensearch-cluster
- terraform-aws-rds: morpheus-workspace::terraform-aws-rds
- terraform-aws-ses: morpheus-workspace::terraform-aws-ses

## Development Environment

This repository includes:

- VS Code workspace configuration
- GitHub Copilot settings
- Project-specific documentation and guidelines
- Python-based initialization tools

## Contributing

Please see the [CONTRIBUTING.md](.github/CONTRIBUTING.md) file for guidelines.

# AWS Auto Scaling Cluster Module for Morpheus

This Terraform module manages an AWS Auto Scaling Group configured for Morpheus HA deployment.

## Features

- Multi-AZ deployment support
- Auto-scaling based on CPU utilization and request count
- CloudWatch monitoring and alerting
- EFS integration for shared storage
- Secrets management integration
- Lifecycle hooks for graceful scaling
- Health checks and monitoring

## Usage

```hcl
module "morpheus_cluster" {
  source = "terraform-aws-cluster"

  project_name = "morpheus"
  instance_type = "m5.xlarge"

  # Auto Scaling Configuration
  auto_scaling = {
    create = true
    min_size = 3
    max_size = 6
    desired_capacity = 3
    health_check_type = "ELB"
    health_check_grace_period = 300
  }

  # Launch Template Configuration
  launch_template = {
    create = true
    block_device_mappings = [
      {
        device_name = "/dev/xvda"
        ebs = {
          volume_size = 100
          volume_type = "gp3"
        }
      },
      {
        device_name = "/dev/xvdb"
        ebs = {
          volume_size = 200
          volume_type = "gp3"
        }
      }
    ]
  }

  # Morpheus Configuration
  morpheus_config = {
    appliance_url = "https://morpheus.example.com"
    rabbitmq_host = "rabbitmq.internal"
    db_host = "aurora.internal"
    opensearch_host = "opensearch.internal"
    efs_dns_name = "fs-xxx.efs.region.amazonaws.com"
  }

  # Secrets Configuration
  morpheus_secrets = {
    rabbitmq_secret_arn = "arn:aws:secretsmanager:region:account:secret:rabbitmq-xxx"
    database_secret_arn = "arn:aws:secretsmanager:region:account:secret:database-xxx"
    ssl_certificate_arn = "arn:aws:secretsmanager:region:account:secret:certificate-xxx"
  }

  tags = {
    Environment = "production"
  }
}
```

## Requirements

| Name      | Version |
| --------- | ------- |
| terraform | >= 1.0  |
| aws       | >= 4.0  |

## Inputs

### Required Inputs

| Name             | Description                         | Type   |
| ---------------- | ----------------------------------- | ------ |
| project_name     | Name of the project/cluster         | string |
| instance_type    | EC2 instance type                   | string |
| morpheus_config  | Morpheus application configuration  | object |
| morpheus_secrets | ARNs of AWS Secrets Manager secrets | object |

### Optional Inputs

| Name            | Description                      | Type        | Default          |
| --------------- | -------------------------------- | ----------- | ---------------- |
| tags            | Resource tags                    | map(string) | {}               |
| auto_scaling    | Auto scaling group configuration | object      | See variables.tf |
| launch_template | Launch template configuration    | object      | See variables.tf |

## Outputs

| Name               | Description                    |
| ------------------ | ------------------------------ |
| asg_name           | Name of the Auto Scaling Group |
| asg_arn            | ARN of the Auto Scaling Group  |
| launch_template_id | ID of the Launch Template      |

## Morpheus Configuration

### CloudWatch Metrics

The module configures the following CloudWatch metrics:

- CPU Utilization (target: 70%)
- Memory Usage (alert at 85%)
- Disk Usage (alert at 85%)
- Error Rate (alert at >1%)
- Response Time (alert at >2s)

### Auto Scaling Policies

- CPU Utilization Based (target: 70%)
- Request Count Based (target: 1000 req/target)

### Lifecycle Hooks

- Launch Hook: Instance initialization and health check
- Termination Hook: Connection draining and cleanup

### Required IAM Permissions

The EC2 instances require permissions for:

- EFS mount operations
- CloudWatch metrics and logs
- Secrets Manager access
- KMS decryption

## License

Apache 2.0
