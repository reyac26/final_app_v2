# final_app_v2

## Pipeline Architecture (7 Automated Jobs)

Every time code is pushed to the main branch, the GitHub Actions workflow automatically starts and runs through these jobs in order.

### 1. build-and-curl (Local Test)
This job builds the Docker container and runs the application locally. It then uses a curl command on port 8000 to make sure the application is running correctly before anything is deployed to AWS.

### 2. sbom-scan-and-test (Security Scan)
This job checks the project for security issues. TruffleHog scans the repository for exposed secrets, while Syft creates a Software Bill of Materials (SBOM). Grype then scans the SBOM for known vulnerabilities and stops the pipeline if any critical issues are found.

### 3. terraform-stage-1 (Amazon ECR Setup)
Terraform initializes the remote backend and creates or imports the Amazon ECR repository. Using the import command allows Terraform to safely manage the repository without creating duplicates.

### 4. build-tag-push (Build and Push Image)
The workflow logs into Amazon ECR, builds the Docker image, tags it, and pushes the latest version to the container registry so it is ready for deployment.

### 5. terraform-stage-2 (AWS Fargate Deployment)
Terraform deploys the application to an AWS ECS Fargate cluster. It also creates the required networking and security group rules so the application is accessible through port 8000.

### 6. pre-eval (Deployment Verification)
This job waits until the ECS task is fully running, retrieves the public IP address, and sends a curl request to verify that the application is responding with an HTTP 200 OK status before continuing.

### 7. terraform-stage-3 (Terraform Cleanup)
The final stage connects to the encrypted Amazon S3 remote state backend so Terraform can manage infrastructure changes and destroy resources cleanly when needed.

---
### AWS Services Used:

* Amazon Elastic Container Registry (ECR)
* Amazon Elastic Container Service (ECS) with AWS Fargate
* Amazon Simple Storage Service (S3)
* AWS Identity and Access Management (IAM)
* Amazon Virtual Private Cloud (VPC)

---
## Authentication between GitHub and AWS

### The workflow uses:

- AWS_ACCESS_KEY_ID
- AWS_SECRET_ACCESS_KEY
- AWS_REGION

These values are stored as encrypted GitHub repository secrets and are passed into the workflow at runtime.

---
### Terraform 

Terraform manages:

* Amazon ECR repository
* ECS resources
* Networking resources
* Security groups
*Remote state configuration

---
### Security

* TruffleHog - detects exposed secrets
* Syft - generates SBOM
* Grype - scans dependencies and images for vulnerabilities

---
### Engineering References

*   **AWS OIDC Integration**: [Official GitHub Actions AWS Guide](https://github.com)  
*   **GitHub Hardening**: [GitHub Actions Security Best Practices](https://github.com)  
*   **ECR Registry Login**: [Amazon ECR Login for GitHub Actions](https://github.com)  
*   **Terraform ECR Resource**: [Terraform `aws_ecr_repository` Documentation](https://terraform.io)  
*   **Terraform ECS Service**: [Terraform `aws_ecs_service` Schema Guide](https://terraform.io)  
*   **AWS CLI ECS Waiting**: [AWS CLI `aws ecs wait tasks-running` Reference](https://amazonaws.com)  
*   **Syft Package Cataloger**: [Anchore Syft Core Tool Repository](https://github.com)  
*   **Grype Vulnerability Scanner**: [Anchore Grype Command Manual](https://github.com)  
*   **TruffleHog Secrets Detection**: [TruffleHog GitHub Action Blueprint](https://github.com)
