# GCP NSI In-band Deployment Guide

This guide provides step-by-step instructions for deploying Network Security Integration (NSI) with in-band packet inspection using Palo Alto Networks firewalls.

## Table of Contents
1. [Prerequisites](#prerequisites)
2. [Architecture Overview](#architecture-overview)
3. [Deployment Steps](#deployment-steps)
4. [Verification](#verification)
5. [Troubleshooting](#troubleshooting)

## Prerequisites

### Required Access
- **GCP Organization Admin** - For creating security profiles at org level
- **Producer Project Owner** - For deploying inspection infrastructure
- **Consumer Project Owner** - For configuring traffic interception
- **Network Admin** - For VPC and firewall policy management

### Required APIs
Enable the following APIs in both producer and consumer projects:

```bash
# Producer project
gcloud services enable compute.googleapis.com \
  networksecurity.googleapis.com \
  storage-api.googleapis.com \
  --project=PRODUCER_PROJECT_ID

# Consumer project  
gcloud services enable compute.googleapis.com \
  networksecurity.googleapis.com \
  --project=CONSUMER_PROJECT_ID
```

### Required Tools
- Terraform >= 1.5.0
- gcloud CLI >= 450.0.0
- kubectl (optional, for troubleshooting)

### Network Prerequisites
- **Producer VPC** must exist with appropriate subnets
- **Consumer VPCs** must exist and be reachable
- Subnet gateway IPs must be documented for firewall rules

## Architecture Overview

```
┌──────────────────────────────────────────────────────────┐
│               PRODUCER SERVICE (Project A)               │
│                                                          │
│  ┌────────────────────────────────────────────────┐    │
│  │  Intercept Deployment Group (us-central1)      │    │
│  │                                                 │    │
│  │  ┌─────────────────┐  ┌─────────────────┐     │    │
│  │  │ Zone A          │  │ Zone B          │     │    │
│  │  │ ┌─────────────┐ │  │ ┌─────────────┐ │     │    │
│  │  │ │ NLB         │ │  │ │ NLB         │ │     │    │
│  │  │ │ UDP:6081    │ │  │ │ UDP:6081    │ │     │    │
│  │  │ └──────┬──────┘ │  │ └──────┬──────┘ │     │    │
│  │  │        │        │  │        │        │     │    │
│  │  │ ┌──────▼──────┐ │  │ ┌──────▼──────┐ │     │    │
│  │  │ │ Palo Alto   │ │  │ │ Palo Alto   │ │     │    │
│  │  │ │ MIG (2-6)   │ │  │ │ MIG (2-6)   │ │     │    │
│  │  │ └─────────────┘ │  │ └─────────────┘ │     │    │
│  │  └─────────────────┘  └─────────────────┘     │    │
│  └────────────────────────────────────────────────┘    │
└──────────────────────────────────────────────────────────┘
                          │
                   GENEVE (UDP:6081)
                          │
┌──────────────────────────▼───────────────────────────────┐
│               CONSUMER SERVICE (Project B)               │
│                                                          │
│  ┌────────────────────────────────────────────────┐    │
│  │  VPC Networks (Enforcement: BEFORE_CLASSIC)     │    │
│  │                                                 │    │
│  │  ┌──────────────────────────────────────┐      │    │
│  │  │ Intercept Endpoint Group             │      │    │
│  │  │ + Endpoint Group Associations        │      │    │
│  │  └──────────────────────────────────────┘      │    │
│  │                                                 │    │
│  │  ┌──────────────────────────────────────┐      │    │
│  │  │ Security Profile Group               │      │    │
│  │  │ └─ Threat Prevention Profile         │      │    │
│  │  └──────────────────────────────────────┘      │    │
│  │                                                 │    │
│  │  ┌──────────────────────────────────────┐      │    │
│  │  │ Firewall Policy                      │      │    │
│  │  │ └─ Rules (apply_security_profile)    │      │    │
│  │  └──────────────────────────────────────┘      │    │
│  └────────────────────────────────────────────────┘    │
└──────────────────────────────────────────────────────────┘
```

## Deployment Steps

### Step 1: Prepare Configuration Files

1. **Update Producer Configuration**
   ```bash
   cd data/
   cp producer-config.yaml producer-config-custom.yaml
   # Edit producer-config-custom.yaml with your values
   ```

2. **Update Consumer Configuration**
   ```bash
   cp consumer-config.yaml consumer-config-custom.yaml
   # Edit consumer-config-custom.yaml with your values
   ```

3. **Update Bootstrap Configuration**
   ```bash
   cp bootstrap-config.yaml bootstrap-config-custom.yaml
   # Edit with Panorama details and VM settings
   ```

### Step 2: Deploy Producer Infrastructure

```bash
cd terraform/producer/

# Initialize Terraform
terraform init

# Create tfvars file
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your configuration

# Set sensitive variables
export TF_VAR_vm_auth_key="your-panorama-auth-key"
export TF_VAR_authcodes='{"license1": "I1234567"}'

# Plan deployment
terraform plan -out=tfplan

# Apply deployment
terraform apply tfplan
```

**Expected Resources Created:**
- 1 Intercept Deployment Group
- 2 Zonal Intercept Deployments (per zone)
- 2 Internal Passthrough NLBs
- 2 Managed Instance Groups (Palo Alto VMs)
- 2 Bootstrap GCS Buckets
- 1 Service Account
- Multiple firewall rules

**Deployment Time:** ~15-20 minutes

### Step 3: Verify Producer Deployment

```bash
# Check intercept deployment group
gcloud network-security intercept-deployment-groups describe \
  nsi-inband-deployment-group \
  --location=us-central1 \
  --project=PRODUCER_PROJECT_ID

# Check intercept deployments
gcloud network-security intercept-deployments list \
  --location=us-central1-a \
  --project=PRODUCER_PROJECT_ID

# Check load balancer status
gcloud compute forwarding-rules list \
  --filter="name~'inspection-nlb'" \
  --project=PRODUCER_PROJECT_ID

# Check instance groups
gcloud compute instance-groups managed list \
  --filter="name~'palo-alto-mig'" \
  --project=PRODUCER_PROJECT_ID

# Verify VMs are healthy
gcloud compute instance-groups managed list-instances \
  palo-alto-mig-a \
  --zone=us-central1-a \
  --project=PRODUCER_PROJECT_ID
```

### Step 4: Configure IAM Permissions

Grant consumer service account access to producer's deployment group:

```bash
# Get producer deployment group resource name
DEPLOYMENT_GROUP="projects/PRODUCER_PROJECT_ID/locations/us-central1/interceptDeploymentGroups/nsi-inband-deployment-group"

# Grant consumer access
gcloud projects add-iam-policy-binding PRODUCER_PROJECT_ID \
  --member="serviceAccount:CONSUMER_SA@CONSUMER_PROJECT_ID.iam.gserviceaccount.com" \
  --role="roles/networksecurity.interceptDeploymentExternalUser"
```

### Step 5: Deploy Consumer Configuration

```bash
cd terraform/consumer/

# Initialize Terraform
terraform init

# Create tfvars file
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your configuration

# Update producer deployment group full name
# Format: projects/PRODUCER_PROJECT/locations/REGION/interceptDeploymentGroups/GROUP_NAME

# Plan deployment
terraform plan -out=tfplan

# Apply deployment
terraform apply tfplan
```

**Expected Resources Created:**
- 1 Intercept Endpoint Group
- N Endpoint Group Associations (one per VPC)
- 1 Security Profile (organization-level)
- 1 Security Profile Group
- 1 Firewall Policy
- N Firewall Policy Rules
- N Firewall Policy Associations (one per VPC)

**Deployment Time:** ~10-15 minutes

### Step 6: Verify Consumer Deployment

```bash
# Check endpoint group
gcloud network-security intercept-endpoint-groups describe \
  consumer-endpoint-group \
  --location=us-central1 \
  --project=CONSUMER_PROJECT_ID

# Check security profile
gcloud network-security security-profiles describe \
  custom-intercept-profile \
  --organization=ORG_ID \
  --location=global

# Check security profile group
gcloud network-security security-profile-groups describe \
  nsi-inband-profile-group \
  --organization=ORG_ID \
  --location=global

# Check firewall policy
gcloud compute network-firewall-policies describe \
  nsi-inband-global-policy \
  --global \
  --project=CONSUMER_PROJECT_ID

# Verify VPC firewall enforcement order
gcloud compute networks describe global-host-m1p-vpc \
  --project=CONSUMER_PROJECT_ID \
  --format="value(networkFirewallPolicyEnforcementOrder)"
```

### Step 7: Configure Palo Alto Firewalls

1. **Access Palo Alto Management Interface**
   ```bash
   # Get VM external IP (if configured)
   gcloud compute instances list \
     --filter="name~'palo-alto'" \
     --project=PRODUCER_PROJECT_ID
   ```

2. **Configure Palo Alto via Panorama** (Recommended)
   - VMs will auto-register using bootstrap configuration
   - Configure security policies in Panorama
   - Push configuration to firewalls

3. **Manual Configuration** (If not using Panorama)
   - Log into each firewall
   - Configure interfaces (ethernet1/1 for data plane)
   - Create security zones
   - Configure security policies
   - Enable GENEVE decapsulation

### Step 8: Test Traffic Inspection

```bash
# From a consumer VM, test outbound traffic
curl -v https://www.google.com

# Check Palo Alto logs for traffic
# Via Panorama or firewall CLI:
# show log traffic

# Verify traffic is being inspected
gcloud logging read \
  'resource.type="gce_instance" AND resource.labels.instance_id~"palo-alto"' \
  --project=PRODUCER_PROJECT_ID \
  --limit=50
```

## Verification Checklist

### Producer Verification
- [ ] Intercept deployment group is ACTIVE
- [ ] All zonal deployments are ACTIVE
- [ ] Load balancers have healthy backends
- [ ] Palo Alto VMs are running and healthy
- [ ] Bootstrap buckets contain configuration files
- [ ] Firewall rules allow GENEVE traffic (UDP:6081)
- [ ] Health check firewall rules are in place

### Consumer Verification
- [ ] Intercept endpoint group is ACTIVE
- [ ] Endpoint group associations are ACTIVE
- [ ] Security profile is configured correctly
- [ ] Security profile group references correct profile
- [ ] Firewall policy is associated with VPCs
- [ ] Firewall rules have correct priorities
- [ ] VPC enforcement order is BEFORE_CLASSIC_FIREWALL
- [ ] IAM permissions granted on producer project

### Traffic Flow Verification
- [ ] Test VMs can reach destinations
- [ ] Traffic appears in Palo Alto logs
- [ ] Security policies are being applied
- [ ] Blocked traffic is logged
- [ ] Latency is acceptable (<10ms overhead)

## Common Issues and Solutions

### Issue: VMs Not Healthy

**Symptoms:** Instance group shows unhealthy instances

**Solutions:**
```bash
# Check health check configuration
gcloud compute health-checks describe HEALTH_CHECK_NAME

# Verify firewall rules allow health checks
gcloud compute firewall-rules list --filter="targetTags:packet-inspection"

# Check VM serial console logs
gcloud compute instances get-serial-port-output VM_NAME --zone=ZONE
```

### Issue: Traffic Not Being Inspected

**Symptoms:** No traffic in Palo Alto logs

**Solutions:**
1. Verify firewall policy enforcement order
2. Check firewall rule priorities
3. Verify security profile group is correct
4. Check IAM permissions
5. Verify endpoint group associations

### Issue: High Latency

**Symptoms:** Increased network latency

**Solutions:**
1. Enable autoscaling for Palo Alto VMs
2. Increase VM machine type (n2-standard-8)
3. Add more zones for load distribution
4. Review security policies for optimization
5. Enable regional load balancing

### Issue: Authentication Failures

**Symptoms:** VMs not registering with Panorama

**Solutions:**
```bash
# Verify bootstrap bucket access
gsutil ls gs://BOOTSTRAP_BUCKET_NAME/config/

# Check VM metadata
gcloud compute instances describe VM_NAME --zone=ZONE \
  --format="value(metadata.items)"

# Regenerate VM auth key in Panorama
# Update Terraform variable and reapply
```

## Maintenance

### Updating Palo Alto Software
1. Upload new software to bootstrap bucket
2. Update instance template
3. Perform rolling update on MIG

### Scaling Operations
```bash
# Manual scaling
gcloud compute instance-groups managed resize MIG_NAME \
  --size=4 \
  --zone=ZONE

# Update autoscaler
terraform apply -var="autoscaling_max_replicas=10"
```

### Monitoring
- Use Cloud Monitoring for VM metrics
- Configure Palo Alto to send logs to Cloud Logging
- Set up alerting for unhealthy instances
- Monitor GENEVE traffic statistics

## Next Steps

1. Configure additional security policies in Palo Alto
2. Set up centralized logging and monitoring
3. Implement disaster recovery procedures
4. Document runbooks for common operations
5. Train operations team on troubleshooting

## Support

For issues and questions:
- Review [Troubleshooting Guide](docs/troubleshooting.md)
- Check [Google Cloud NSI Documentation](https://cloud.google.com/network-security/docs)
- Contact Palo Alto Networks support
- Open issue in repository

## References

- [Google Cloud NSI In-band Documentation](https://cloud.google.com/network-security/docs/in-band-integration)
- [Palo Alto VM-Series on GCP](https://docs.paloaltonetworks.com/vm-series/10-1/vm-series-deployment/set-up-the-vm-series-firewall-on-google-cloud-platform)
- [Terraform Google Provider](https://registry.terraform.io/providers/hashicorp/google/latest/docs)
