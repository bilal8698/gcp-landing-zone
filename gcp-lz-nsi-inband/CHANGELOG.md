# Changelog

All notable changes to the GCP NSI In-band project will be documented in this file.

## [1.0.0] - 2026-01-20

### Added
- Initial release of NSI In-band integration for Google Cloud Platform
- Producer service Terraform modules:
  - Intercept Deployment Group module
  - Zonal Intercept Deployment module
  - Internal Passthrough Network Load Balancer module
  - Packet Inspection VM (Palo Alto NGFW) module
  - Bootstrap module for VM configuration
- Consumer service Terraform modules:
  - Intercept Endpoint Group module
  - Security Profile module
  - Security Profile Group module
  - Firewall Policy module
- Complete YAML configuration files:
  - producer-config.yaml
  - consumer-config.yaml
  - bootstrap-config.yaml
- Documentation:
  - Comprehensive README.md
  - Deployment Guide
  - Troubleshooting Guide
- Example Terraform variable files
- .gitignore for sensitive files

### Features
- Multi-zone deployment for high availability
- Autoscaling support for Palo Alto VMs
- GENEVE encapsulation for in-band inspection
- Bootstrap bucket integration for automated VM configuration
- Hierarchical and global firewall policy support
- Organization-level security profiles
- IAM integration for cross-project access
- Health check configuration
- Failover support for load balancers

### Documentation
- Architecture diagrams
- Step-by-step deployment guide
- Verification procedures
- Troubleshooting procedures
- Common issues and solutions
- Maintenance procedures

### Security
- Service account with least-privilege IAM roles
- Sensitive variable handling via environment variables
- GCS bucket IAM permissions for bootstrap access
- Firewall rules for health checks and GENEVE traffic

### References
- Based on PaloAltoNetworks/google-cloud-nsi-tutorial
- Based on PaloAltoNetworks/terraform-google-swfw-modules
- Google Cloud NSI In-band Documentation

## [Unreleased]

### Planned
- Support for additional NGFW vendors
- Multi-region deployment examples
- Cost optimization guide
- Performance benchmarking results
- Integration with Cloud Armor
- Terraform modules for VPC creation
- CI/CD pipeline examples
- Automated testing framework
