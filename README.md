# smart_iot_factory_alb
The provided repository (`cp-cohort11-group1.tar`) contains a complete Infrastructure as Code (IaC) setup for an IoT Factory Simulator using Terraform, along with a GitHub Actions CI/CD pipeline.

Here is the guide to building, deploying, and monitoring this project, both manually and using the provided GitFlow automation.

-----

### **Part 1: Prerequisites**

Before starting, ensure your environment is set up.

#### **1. Local Tools Required**

  * **Terraform:** (v1.9.5+)
  * **AWS CLI:** (v2.x) configured with `aws configure`.
  * **Docker:** (Running) to build the simulator image.
  * **Git:** For version control.

#### **2. AWS Pre-Configuration**

Run the backend setup script provided in the repo to create the S3 bucket for state and DynamoDB table for locking.

1.  Navigate to: `terraform/resources/scripts/`
2.  Run: `./setup_backend.sh`
      * *This creates `grp1-ce11-dev-iot-state-bucket` and the locking table.*

#### **3. Required Files**

Ensure you have the IoT certificates in `terraform/resources/certs/`:

  * `AmazonRootCA1.pem`
  * `device-certificate.pem.crt`
  * `private.pem.key`

-----

### **Part 2: Deployment WITHOUT GitFlow (Manual Steps)**

Use this method for local development or if you do not have the GitHub Actions OIDC role configured.

#### **Step 1: Provision Infrastructure (Terraform)**

1.  **Navigate to the Dev Environment:**
    ```bash
    cd terraform/envs/dev
    ```
2.  **Initialize Terraform:**
    ```bash
    terraform init
    ```
3.  **Apply Configuration:**
    ```bash
    terraform apply -var-file=terraform.tfvars
    ```
      * Type `yes` to confirm.
      * **Keep the outputs handy\!** You will need the `ecr_repository_url` and `docker_push_command`.

#### **Step 2: Build and Deploy the Application**

Terraform creates the registry (ECR) but does **not** build the code. You must do this manually.

1.  **Login to ECR:**
    *(Run the login command provided in the terraform output)*

    ```bash
    aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin <YOUR_ACCOUNT_ID>.dkr.ecr.us-east-1.amazonaws.com
    ```

2.  **Build the Docker Image:**
    **Important:** Run this from the root of the repository (`cp-cohort11-group1/`) so the Dockerfile context is correct.

    ```bash
    docker build -t iot-simulator -f terraform/resources/app/Dockerfile terraform/resources/
    ```

3.  **Tag and Push:**

    ```bash
    docker tag iot-simulator:latest <YOUR_ECR_REPO_URL>:latest
    docker push <YOUR_ECR_REPO_URL>:latest
    ```

4.  **Force ECS Deployment:**
    To make ECS pick up the new image immediately:

    ```bash
    aws ecs update-service --cluster grp1-ce11-dev-iot-cluster --service grp1-ce11-dev-iot-service --force-new-deployment --region us-east-1
    ```

-----

### **Part 3: Deployment WITH GitFlow (CI/CD)**

The repository includes a workflow file `.github/workflows/ci-cd.yml` configured for GitFlow.

#### **1. Setup GitHub Secrets**

In your GitHub Repository Settings -\> Secrets and variables -\> Actions, add:

  * `AWS_ROLE_ARN`: The ARN of an IAM Role that GitHub Actions can assume (must have OIDC trust relationship configured).

#### **2. The GitFlow Workflow**

| Branch | Action | Environment | Trigger |
| :--- | :--- | :--- | :--- |
| **Feature** | `git push origin feature/*` | None | Runs `terraform fmt` & `validate` only. |
| **Dev** | **Merge PR** to `dev` | **Dev** | Runs `terraform apply` to deploy to Dev environment. |
| **Main** | **Merge PR** to `main` | **Prod** | Runs `terraform apply` to deploy to Prod environment. |

#### **3. Steps to Deploy**

1.  **Commit Code:** Push your changes to a feature branch.
2.  **Create PR:** Open a Pull Request to the `dev` branch.
3.  **Merge:** Once merged, click the **Actions** tab in GitHub to watch the `Deploy to DEV` job run.
4.  **Verify:** Check the Dev environment URL.
5.  **Promote:** Create a PR from `dev` to `main` and merge to deploy to Production.

*Note: The current `ci-cd.yml` manages Terraform (Infrastructure). To fully automate the App, you would add a "Build & Push Docker" step to the yaml file.*

-----

### **Part 4: Monitoring the Application**

Once deployed (manually or via CI/CD), use the following tools:

#### **1. Grafana Dashboard**

  * **URL:** `http://<ALB_DNS_NAME>/grafana`
  * **Login:** `admin` / `admin` (or the password set in your variables).
  * **Dashboards:** Navigate to **Dashboards \> Browse**. You will see:
      * *IoT Simulator Anomalies*
      * *Executive Overview*
      * *System Health*

#### **2. Prometheus**

  * **URL:** `http://<ALB_DNS_NAME>/prometheus` (if enabled on ALB listener) or via port forwarding.
  * **Verification:** Run the provided script to check active metrics:
    ```bash
    ./terraform/resources/scripts/validate_prometheus.sh
    ```

#### **3. Health Checks**

Run the health check script to validate all components (requires running from a machine with access to the VPC, or an SSM session):

```bash
./terraform/resources/scripts/healthcheck.sh
```
