# GCP Landing Zone - NSI In-band Integration

This repository contains Terraform modules and configurations for implementing Google Cloud's Network Security Integration (NSI) using **In-band** packet inspection with Palo Alto Networks firewalls.

## Overview

In-band integration allows you to inspect traffic inline using Software Next-Generation Firewalls (NGFWs) with Google Cloud's Network Security Integration. This implementation supports both **Producer** and **Consumer** service patterns.

### Architecture

```
┌─────────────────────────────────────────────────────────────────────┐
│                        PRODUCER SERVICES                            │
│  ┌────────────────────────────────────────────────────────────┐    │
│  │  Intercept Deployment Group (Regional)                     │    │
│  │  ├─ Zonal Intercept Deployment (us-central1-a)             │    │
│  │  │  └─ Internal Passthrough NLB (UDP:6081)                 │    │
│  │  │     └─ Managed Instance Group                           │    │
│  │  │        ├─ Palo Alto NGFW VM-1                           │    │
│  │  │        └─ Palo Alto NGFW VM-2                           │    │
│  │  └─ Zonal Intercept Deployment (us-central1-b)             │    │
│  └────────────────────────────────────────────────────────────┘    │
└─────────────────────────────────────────────────────────────────────┘
                              ↓ GENEVE (UDP:6081)
┌─────────────────────────────────────────────────────────────────────┐
│                        CONSUMER SERVICES                            │
│  ┌────────────────────────────────────────────────────────────┐    │
│  │  VPC Network (Firewall Policy: BEFORE_CLASSIC_FIREWALL)    │    │
│  │  ├─ Intercept Endpoint Group                               │    │
│  │  │  └─ Intercept Endpoint Group Association                │    │
│  │  ├─ Security Profile Group                                 │    │
│  │  │  └─ Custom Intercept Security Profile                   │    │
│  │  └─ Hierarchical/Global Firewall Policy                    │    │
│  │     └─ Rules (action: apply_security_profile_group)        │    │
│  └────────────────────────────────────────────────────────────┘    │
└─────────────────────────────────────────────────────────────────────┘
```

## Features

### Producer Services
- **Intercept Deployment Groups**: Regional management of packet inspection deployments
- **Zonal Intercept Deployments**: Per-zone packet inspection endpoints
- **Internal Passthrough Network Load Balancers**: UDP:6081 for GENEVE traffic
- **Managed Instance Groups**: Auto-scaling Palo Alto NGFW VMs
- **Bootstrap Module**: Automated VM configuration and initialization

### Consumer Services
- **Intercept Endpoint Groups**: Connect to producer inspection services
- **Security Profiles**: Custom intercept profiles for traffic policies
- **Security Profile Groups**: Organize multiple security profiles
- **Firewall Policies**: Hierarchical and global network policies
- **Firewall Rules**: Traffic interception with `apply_security_profile_group` action

## Directory Structure

```
gcp-lz-nsi-inband/
├── README.md
├── ARCHITECTURE.md
├── DEPLOYMENT_GUIDE.md
├── terraform/
│   ├── producer/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   ├── outputs.tf
│   │   ├── versions.tf
│   │   ├── backend.tf
│   │   └── locals.tf
│   ├── consumer/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   ├── outputs.tf
│   │   ├── versions.tf
│   │   ├── backend.tf
│   │   └── locals.tf
│   └── modules/
│       ├── intercept-deployment-group/
│       │   ├── main.tf
│       │   ├── variables.tf
│       │   └── outputs.tf
│       ├── intercept-deployment/
│       │   ├── main.tf
│       │   ├── variables.tf
│       │   └── outputs.tf
│       ├── internal-nlb/
│       │   ├── main.tf
│       │   ├── variables.tf
│       │   └── outputs.tf
│       ├── packet-inspection-vm/
│       │   ├── main.tf
│       │   ├── variables.tf
│       │   └── outputs.tf
│       ├── bootstrap/
│       │   ├── main.tf
│       │   ├── variables.tf
│       │   └── outputs.tf
│       ├── intercept-endpoint-group/
│       │   ├── main.tf
│       │   ├── variables.tf
│       │   └── outputs.tf
│       ├── security-profile/
│       │   ├── main.tf
│       │   ├── variables.tf
│       │   └── outputs.tf
│       ├── security-profile-group/
│       │   ├── main.tf
│       │   ├── variables.tf
│       │   └── outputs.tf
│       └── firewall-policy/
│           ├── main.tf
│           ├── variables.tf
│           └── outputs.tf
├── data/
│   ├── producer-config.yaml
│   ├── consumer-config.yaml
│   └── bootstrap-config.yaml
└── docs/
    ├── producer-setup.md
    ├── consumer-setup.md
    └── troubleshooting.md
```

## Prerequisites

### IAM Roles Required

#### Producer Project
- `roles/compute.networkAdmin` - Compute Network Admin
- `roles/networksecurity.interceptDeploymentAdmin` - Intercept Deployment Admin
- `roles/compute.instanceAdmin.v1` - Compute Instance Admin

#### Consumer Project
- `roles/networksecurity.securityProfileAdmin` - Security Profile Admin (Organization level)
- `roles/compute.networkAdmin` - Compute Network Admin
- `roles/networksecurity.interceptEndpointAdmin` - Intercept Endpoint Admin
- `roles/networksecurity.interceptDeploymentUser` - Intercept Deployment User (Producer project)

### APIs to Enable
```bash
gcloud services enable compute.googleapis.com
gcloud services enable networksecurity.googleapis.com
```

## Configuration

### Producer Configuration (`data/producer-config.yaml`)
```yaml
producer:
  project_id: network-security-producer
  region: us-central1
  zones:
    - us-central1-a
    - us-central1-b
  
  intercept_deployment_group:
    name: nsi-inband-deployment-group
    description: "In-band packet inspection deployment group"
  
  vpc_network:
    name: producer-inspection-vpc
    subnets:
      - name: inspection-subnet-us-central1
        ip_cidr_range: 10.200.0.0/24
        region: us-central1
  
  load_balancers:
    - zone: us-central1-a
      name: inspection-nlb-a
      protocol: UDP
      port: 6081
    - zone: us-central1-b
      name: inspection-nlb-b
      protocol: UDP
      port: 6081
```

### Consumer Configuration (`data/consumer-config.yaml`)
```yaml
consumer:
  project_id: network-security-consumer
  organization_id: "123456789012"
  
  vpc_networks:
    - name: consumer-vpc-1
      firewall_policy_enforcement_order: BEFORE_CLASSIC_FIREWALL
    - name: consumer-vpc-2
      firewall_policy_enforcement_order: BEFORE_CLASSIC_FIREWALL
  
  intercept_endpoint_group:
    name: consumer-endpoint-group
    producer_deployment_group: nsi-inband-deployment-group
    producer_project: network-security-producer
  
  security_profile:
    name: custom-intercept-profile
    type: intercept
  
  firewall_policies:
    - name: nsi-inband-policy
      type: hierarchical
      rules:
        - priority: 1000
          action: apply_security_profile_group
          direction: INGRESS
          match:
            src_ip_ranges: ["10.0.0.0/8"]
            dest_ip_ranges: ["0.0.0.0/0"]
```

## Deployment

### Step 1: Deploy Producer Services

```bash
cd terraform/producer
terraform init
terraform plan -var-file="../../data/producer-config.yaml"
terraform apply
```

### Step 2: Deploy Consumer Services

```bash
cd terraform/consumer
terraform init
terraform plan -var-file="../../data/consumer-config.yaml"
terraform apply
```

### Step 3: Grant IAM Permissions

```bash
# Grant consumer access to producer intercept deployment group
gcloud projects add-iam-policy-binding PRODUCER_PROJECT_ID \
  --member="serviceAccount:CONSUMER_SA@CONSUMER_PROJECT.iam.gserviceaccount.com" \
  --role="roles/networksecurity.interceptDeploymentExternalUser"
```

## Key Concepts

### GENEVE Encapsulation
- In-band integration uses GENEVE (Generic Network Virtualization Encapsulation)
- Traffic is sent to UDP port **6081**
- Source IP is the subnet gateway IPv4 address
- Packets maintain original 5-tuple characteristics

### Firewall Policy Enforcement Order
- Consumer VPC networks must use `BEFORE_CLASSIC_FIREWALL` enforcement
- Ensures hierarchical/global firewall policies are evaluated before VPC firewall rules
- Critical for traffic interception to work correctly

### Health Checks
- Internal passthrough NLBs require supported health check protocols
- Firewall rules must permit health check traffic from Google's health check ranges:
  - `35.191.0.0/16`
  - `130.211.0.0/22`

## Traffic Flow

1. **Consumer VM sends packet** → VPC network
2. **Firewall policy rule matches** → `apply_security_profile_group` action
3. **Traffic encapsulated** → GENEVE (UDP:6081)
4. **Routed to producer** → Intercept deployment group
5. **Load balanced** → Internal passthrough NLB
6. **Inspected** → Palo Alto NGFW VM
7. **Decision** → Allow/Deny
8. **Return to consumer** → Original destination or drop

## Monitoring and Troubleshooting

### Check Intercept Deployment Status
```bash
gcloud network-security intercept-deployments describe DEPLOYMENT_NAME \
  --location=ZONE \
  --project=PRODUCER_PROJECT
```

### View Security Profile
```bash
gcloud network-security security-profiles describe PROFILE_NAME \
  --organization=ORG_ID \
  --location=global
```

### Verify Firewall Policy
```bash
gcloud compute firewall-policies describe POLICY_NAME
```

### Common Issues
- **Traffic not intercepted**: Check firewall policy enforcement order
- **Health check failures**: Verify firewall rules allow health check ranges
- **GENEVE errors**: Ensure UDP:6081 is open on inspection VMs
- **IAM errors**: Verify all required roles are granted

## References

- [Google Cloud NSI In-band Documentation](https://cloud.google.com/network-security/docs/in-band-integration)
- [PaloAltoNetworks NSI Tutorial](https://github.com/PaloAltoNetworks/google-cloud-nsi-tutorial)
- [Terraform Google SWFW Modules](https://github.com/PaloAltoNetworks/terraform-google-swfw-modules)
- [Internal Passthrough Network Load Balancer](https://cloud.google.com/load-balancing/docs/internal)

## Support

For issues and questions:
- Review [TROUBLESHOOTING.md](docs/troubleshooting.md)
- Check [DEPLOYMENT_GUIDE.md](DEPLOYMENT_GUIDE.md)
- See producer/consumer setup guides in `docs/`

## License

Copyright © 2026. All rights reserved.
