# NSI In-band Troubleshooting Guide

Common issues and solutions for NSI in-band packet inspection.

## Traffic Not Being Inspected

### Check Firewall Policy Enforcement Order
```bash
gcloud compute networks describe VPC_NAME \
  --project=PROJECT_ID \
  --format="value(networkFirewallPolicyEnforcementOrder)"
```
**Expected:** `BEFORE_CLASSIC_FIREWALL`

**Fix:**
```bash
gcloud compute networks update VPC_NAME \
  --network-firewall-policy-enforcement-order=BEFORE_CLASSIC_FIREWALL \
  --project=PROJECT_ID
```

### Verify Firewall Policy Rules
```bash
gcloud compute network-firewall-policies describe POLICY_NAME \
  --global \
  --project=PROJECT_ID
```

Check that rules have:
- Correct `action: apply_security_profile_group`
- Proper priority order
- Matching source/destination ranges
- Security profile group reference

### Check Endpoint Group Status
```bash
gcloud network-security intercept-endpoint-groups describe GROUP_NAME \
  --location=REGION \
  --project=PROJECT_ID
```

Status should be `ACTIVE`.

### Verify IAM Permissions
```bash
gcloud projects get-iam-policy PRODUCER_PROJECT_ID \
  --flatten="bindings[].members" \
  --filter="bindings.role:networksecurity.interceptDeploymentExternalUser"
```

Consumer service account should be listed.

## Load Balancer Issues

### Health Check Failures
```bash
# Check backend service health
gcloud compute backend-services get-health BACKEND_SERVICE_NAME \
  --region=REGION \
  --project=PROJECT_ID
```

**Common causes:**
1. Firewall rules blocking health checks
2. VMs not responding on health check port
3. Incorrect health check configuration

**Fix firewall rules:**
```bash
gcloud compute firewall-rules create allow-health-checks \
  --network=VPC_NAME \
  --allow=tcp:22 \
  --source-ranges=35.191.0.0/16,130.211.0.0/22 \
  --target-tags=packet-inspection \
  --project=PROJECT_ID
```

### GENEVE Traffic Not Reaching VMs
```bash
# Check firewall rules for UDP:6081
gcloud compute firewall-rules list \
  --filter="allowed.ports:6081" \
  --project=PROJECT_ID
```

**Fix:**
```bash
gcloud compute firewall-rules create allow-geneve \
  --network=VPC_NAME \
  --allow=udp:6081 \
  --source-ranges=CONSUMER_SUBNET_GATEWAY_IPS \
  --target-tags=packet-inspection \
  --project=PROJECT_ID
```

## Palo Alto VM Issues

### VMs Not Bootstrapping
```bash
# Check serial console logs
gcloud compute instances get-serial-port-output VM_NAME \
  --zone=ZONE \
  --project=PROJECT_ID
```

**Look for:**
- Bootstrap bucket access errors
- Panorama connection failures
- License activation issues

**Verify bootstrap bucket:**
```bash
gsutil ls -r gs://BOOTSTRAP_BUCKET_NAME/
```

**Expected structure:**
```
gs://BOOTSTRAP_BUCKET_NAME/
  config/
    init-cfg.txt
    bootstrap.xml
  content/
  license/
    authcodes
  software/
```

**Check bucket IAM:**
```bash
gsutil iam get gs://BOOTSTRAP_BUCKET_NAME/
```

Service account should have `roles/storage.objectViewer`.

### VMs Not Registering with Panorama
1. Verify Panorama server is reachable from VMs
2. Check VM auth key is correct
3. Verify template and device group names
4. Check Panorama licensing

**Test connectivity:**
```bash
# SSH to VM (if accessible)
ping PANORAMA_SERVER_IP
curl https://PANORAMA_SERVER_IP
```

### High CPU Usage
```bash
# Check VM metrics
gcloud monitoring time-series list \
  --filter='metric.type="compute.googleapis.com/instance/cpu/utilization" AND resource.labels.instance_id="VM_INSTANCE_ID"' \
  --project=PROJECT_ID
```

**Solutions:**
1. Increase VM machine type
2. Enable autoscaling
3. Review security policies for optimization
4. Add more instances

## Intercept Deployment Issues

### Deployment Not Active
```bash
gcloud network-security intercept-deployments describe DEPLOYMENT_NAME \
  --location=ZONE \
  --project=PROJECT_ID
```

**Check:**
- Forwarding rule is correct
- Load balancer is healthy
- Deployment group exists

**Recreate deployment:**
```bash
terraform taint module.intercept_deployment[\"DEPLOYMENT_NAME\"]
terraform apply
```

### Endpoint Group Associations Failed
```bash
gcloud network-security intercept-endpoint-group-associations list \
  --location=REGION \
  --project=PROJECT_ID
```

**Common issues:**
1. VPC network doesn't exist
2. VPC is in different region
3. IAM permissions missing

## Performance Issues

### High Latency
```bash
# Measure latency from consumer VM
ping -c 100 DESTINATION_IP | tail -1
```

**Expected overhead:** <10ms

**Optimization steps:**
1. Use n2-standard-4 or higher for Palo Alto VMs
2. Enable autoscaling
3. Deploy in multiple zones
4. Review security policies
5. Enable connection reuse

### Packet Loss
```bash
# Check for dropped packets
gcloud logging read \
  'resource.type="gce_instance" AND textPayload:"dropped"' \
  --project=PRODUCER_PROJECT_ID \
  --limit=100
```

**Solutions:**
1. Increase VM count
2. Check VM resource utilization
3. Review NLB session affinity settings
4. Verify network connectivity

## Security Profile Issues

### Security Profile Not Applied
```bash
# Check security profile
gcloud network-security security-profiles describe PROFILE_NAME \
  --organization=ORG_ID \
  --location=global
```

**Verify:**
- Profile exists at organization level
- Severity overrides are correct
- Threat overrides (if any) are valid

### Security Profile Group Errors
```bash
gcloud network-security security-profile-groups describe GROUP_NAME \
  --organization=ORG_ID \
  --location=global
```

**Check:**
- References correct security profile
- Profile is in same organization
- IAM permissions for org-level resources

## Logging and Monitoring

### Enable Detailed Logging
```bash
# Enable VPC flow logs
gcloud compute networks subnets update SUBNET_NAME \
  --region=REGION \
  --enable-flow-logs \
  --project=PROJECT_ID

# View flow logs
gcloud logging read \
  'resource.type="gce_subnetwork" AND logName:"flow_logs"' \
  --project=PROJECT_ID \
  --limit=20
```

### Monitor Firewall Logs
```bash
# Check Palo Alto logs
gcloud logging read \
  'resource.type="gce_instance" AND resource.labels.instance_id~"palo-alto"' \
  --project=PRODUCER_PROJECT_ID \
  --limit=50 \
  --format=json
```

### Set Up Alerts
```bash
# Create alert policy for unhealthy instances
gcloud alpha monitoring policies create \
  --notification-channels=CHANNEL_ID \
  --display-name="Unhealthy Palo Alto Instances" \
  --condition-display-name="Instance Group Health" \
  --condition-threshold-value=1 \
  --condition-threshold-duration=300s
```

## Diagnostic Commands

### Complete System Check
```bash
#!/bin/bash
# save as check-nsi.sh

PROJECT_ID="your-project-id"
REGION="us-central1"

echo "=== Checking Intercept Deployment Group ==="
gcloud network-security intercept-deployment-groups describe \
  nsi-inband-deployment-group \
  --location=$REGION \
  --project=$PROJECT_ID

echo "=== Checking Load Balancers ==="
gcloud compute forwarding-rules list \
  --filter="name~'inspection-nlb'" \
  --project=$PROJECT_ID

echo "=== Checking Instance Groups ==="
gcloud compute instance-groups managed list \
  --filter="name~'palo-alto-mig'" \
  --project=$PROJECT_ID

echo "=== Checking VM Health ==="
for zone in us-central1-a us-central1-b; do
  echo "Zone: $zone"
  gcloud compute instance-groups managed list-instances \
    palo-alto-mig-$zone \
    --zone=$zone \
    --project=$PROJECT_ID
done

echo "=== Checking Firewall Rules ==="
gcloud compute firewall-rules list \
  --filter="targetTags:packet-inspection" \
  --project=$PROJECT_ID

echo "=== Complete ==="
```

## Getting Help

1. **Check Google Cloud Status**: https://status.cloud.google.com/
2. **Review Palo Alto Docs**: https://docs.paloaltonetworks.com/
3. **Open Support Case**: Use Google Cloud Console
4. **Community Forums**: Stack Overflow, Google Cloud Community

## Emergency Procedures

### Disable Traffic Inspection
```bash
# Disable firewall policy rules
gcloud compute network-firewall-policies rules update RULE_PRIORITY \
  --firewall-policy=POLICY_NAME \
  --disabled \
  --global \
  --project=PROJECT_ID
```

### Failover to Backup Zone
```bash
# Increase capacity in backup zone
gcloud compute instance-groups managed resize MIG_NAME \
  --size=6 \
  --zone=BACKUP_ZONE \
  --project=PROJECT_ID
```

### Complete Rollback
```bash
# Remove firewall policy associations
gcloud compute network-firewall-policies associations delete ASSOCIATION_NAME \
  --firewall-policy=POLICY_NAME \
  --global \
  --project=PROJECT_ID

# Traffic will bypass inspection until re-associated
```
