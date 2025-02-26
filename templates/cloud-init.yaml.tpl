#cloud-config
write_files:
%{ for file in write_files ~}
- path: ${file.path}
  content: |
    ${indent(4, file.content)}
%{ endfor ~}

runcmd:
  - chmod +x /var/lib/cloud/scripts/per-instance/*.sh
  - /var/lib/cloud/scripts/per-instance/01-morpheus-setup.sh