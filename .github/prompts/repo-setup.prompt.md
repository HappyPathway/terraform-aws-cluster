# AWS Cluster Module Guide

## Overview
The `terraform-aws-cluster` module creates a highly available EC2 cluster using Auto Scaling Groups, designed for Morpheus deployments.

## Features
- Auto Scaling management
- Launch Template configuration
- Cloud-init integration
- EFS mounting
- Load balancer support
- Health monitoring

## Core Variables

### Required
- `project_name`: Identifies resources and AMIs
- `instance_type`: EC2 instance type
- `vpc_cluster`: VPC deployment flag

### Auto Scaling
Controls cluster scaling with:
- Capacity settings
- Health checks
- Instance refresh
- Mixed instances

### Launch Template
Configures instances with:
- Storage mappings
- Network settings
- Instance options
- Metadata config

### Cloud-Init
Manages instance setup:
- File configurations
- Service setup
- EFS mounting
- Application config

## Key Capabilities

### Updates
- Rolling updates
- Health percentage control
- Warmup periods
- Auto rollback

### Instance Management
- Multiple instance types
- Spot integration
- Health monitoring
- AMI selection

## Integration
Works with:
- EFS storage
- Load balancers
- CloudWatch
- Systems Manager
- Secrets Manager

## Project Implementation

### Morpheus HA Deployment
The cluster module will create a 3-node Morpheus deployment with:
- Minimum 3 nodes for high availability
- Distribution across multiple Availability Zones
- Auto recovery for failed instances
- Rolling updates for maintenance

### Infrastructure Components
The cluster integrates with:
1. Shared Storage
   - EFS mounts via cloud-init
   - Application state storage
   - Deployment archives
   - Backup storage

2. Database Access
   - RDS connection configuration
   - Connection pooling setup
   - Failover handling

3. Message Queue
   - RabbitMQ cluster connectivity
   - Message persistence
   - Queue high availability

4. Logging Infrastructure
   - OpenSearch integration
   - Centralized logging
   - Performance metrics

### Load Balancing
- Application Load Balancer distribution
- Health check monitoring
- SSL/TLS termination
- Session persistence

### Instance Configuration
Each node includes:
- Morpheus application package
- Required system dependencies
- Service configurations
- Monitoring agents

### Auto Scaling Rules
The cluster scales based on:
- CPU utilization thresholds
- Memory usage patterns
- Application metrics
- Scheduled capacity changes

### Health Monitoring
Monitors:
- Application health endpoints
- System resources
- Service status
- Infrastructure metrics

### Maintenance Procedures
Handles:
- Rolling updates
- Instance replacement
- Configuration updates
- Security patches
