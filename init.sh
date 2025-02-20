#!/bin/bash
set -e

# Create project directory
mkdir -p morpheus-workspace
cd morpheus-workspace

echo "Initializing project morpheus-workspace..."

# Clone repositories
for repo in ["terraform-aws-cluster","terraform-aws-efs","terraform-aws-mq-cluster","terraform-aws-opensearch-cluster","terraform-aws-rds","terraform-aws-ses"]; do
  echo "Cloning $repo..."
  git clone "git@github.com:HappyPathway/$repo.git"
done

# Generate VS Code workspace file
echo "Setting up VS Code workspace..."
cp "./terraform-aws-cluster/workspace.json" "./morpheus-workspace.code-workspace"

# Configure git settings for each repository
echo "Configuring git settings..."
for dir in */; do
  cd "$dir"
  git config pull.rebase true
  git config branch.autosetuprebase always
  cd ..
done

# Execute custom initialization if provided


echo "Project initialization complete!"