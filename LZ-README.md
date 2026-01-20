# Google Cloud Landing Zone - Complete Infrastructure

This repository contains a complete Google Cloud Landing Zone implementation with three integrated components:

## 🏗️ Architecture Overview

```
┌─────────────────────────────────────────────────────────────────┐
│                    Landing Zone Components                       │
├─────────────────────────────────────────────────────────────────┤
│                                                                   │
│  1️⃣  VPC Foundation (gcp-lz-vpc-foundation)                      │
│     └─ Base networking infrastructure                            │
│        └─ VPCs, Subnets, Cloud NAT, Cloud Router                 │
│                                                                   │
│  2️⃣  NCC Hub-Spoke (gcp-lz-ncc-hub-spoke)                        │
│     └─ Network Connectivity Center transit                       │
│        └─ Hub, VPC Spokes, Router Appliance Spokes              │
│                                                                   │
│  3️⃣  NSI In-band (gcp-lz-nsi-inband)                             │
│     └─ Network Security Integration                              │
│        └─ Palo Alto NGFW, GENEVE Inspection, Traffic Control    │
│                                                                   │
└─────────────────────────────────────────────────────────────────┘
```

## 📦 Components

### 1. VPC Foundation (`gcp-lz-vpc-foundation/`)
Creates the foundational networking layer including VPCs, subnets, Cloud NAT, and Cloud Routers.

**Key Features:**
- Infrastructure and Model VPCs
- Regional subnet allocation
- Cloud NAT for internet connectivity
- Service account provisioning

**Deployment Order:** 1st

### 2. NCC Hub-Spoke (`gcp-lz-ncc-hub-spoke/`)
Establishes Network Connectivity Center for centralized transit routing between VPCs.

**Key Features:**
- NCC Hub creation
- VPC Spoke attachments
- Router Appliance Spokes for transit
- Hub-spoke mesh connectivity

**Deployment Order:** 2nd (after VPC Foundation)

### 3. NSI In-band (`gcp-lz-nsi-inband/`)
Implements Network Security Integration with Palo Alto NGFWs for traffic inspection.

**Key Features:**
- Palo Alto VM-Series deployment
- GENEVE encapsulation (UDP:6081)
- Internal Passthrough NLBs
- Hierarchical firewall policies
- Security profile enforcement

**Deployment Order:** 3rd (after NCC Hub-Spoke)

## 🚀 Deployment Sequence

```bash
# Step 1: Deploy VPC Foundation
cd gcp-lz-vpc-foundation/terraform
terraform init
terraform plan
terraform apply

# Step 2: Deploy NCC Hub-Spoke
cd ../../gcp-lz-ncc-hub-spoke/terraform
terraform init
terraform plan
terraform apply

# Step 3: Deploy NSI In-band (Producer)
cd ../../gcp-lz-nsi-inband/terraform/producer
terraform init
terraform plan
terraform apply

# Step 4: Deploy NSI In-band (Consumer)
cd ../consumer
terraform init
terraform plan
terraform apply
```

## 📋 Prerequisites

- Google Cloud Organization
- Terraform >= 1.5.0
- Appropriate IAM permissions:
  - Compute Network Admin
  - Security Admin
  - Service Account Admin
- Palo Alto VM-Series license (BYOL)

## 🔧 Configuration

Each component has YAML configuration files in their `data/` directories:

- **VPC Foundation:** `data/infrastructure-vpcs-config.yaml`, `data/model-vpcs-config.yaml`
- **NCC Hub-Spoke:** `data/ncc-hub-config.yaml`, `data/vpc-spokes-config.yaml`, `data/transit-spoke-config.yaml`
- **NSI In-band:** `data/producer-config.yaml`, `data/consumer-config.yaml`, `data/bootstrap-config.yaml`

## 📚 Documentation

Refer to individual component READMEs for detailed documentation:

- [VPC Foundation README](gcp-lz-vpc-foundation/README.md)
- [NCC Hub-Spoke README](gcp-lz-ncc-hub-spoke/README.md)
- [NSI In-band README](gcp-lz-nsi-inband/README.md)
- [NSI Deployment Guide](gcp-lz-nsi-inband/DEPLOYMENT_GUIDE.md)

## 🛡️ Security

- Sensitive files (`.tfvars`, `*.key`, etc.) are excluded via `.gitignore`
- Service account keys should be managed via Secret Manager
- Firewall policies enforce least-privilege access
- Traffic inspection enabled for inter-VPC communication

## 📝 Version Information

- **Terraform:** >= 1.5.0
- **Google Provider:** ~> 5.0
- **Palo Alto VM-Series:** 11.1.0

## 🤝 Contributing

This is a Carrier-specific Landing Zone implementation based on LLD v1.1 specifications.

## 📄 License

Internal use only - Carrier Infrastructure Team
