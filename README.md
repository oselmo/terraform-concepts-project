# Multi-Environment AWS Web Platform with Terraform Modules

## How to Use This Repo

This project is a production-grade extension of [Ryan Almeida's Terraform concepts project](https://github.com/ryan-almeida/terraform-concepts-project). Start there — clone his repo, follow his README, and get the basic ALB + ASG + EC2 setup working first.

Once you have the foundation running, come back here and use the steps below as your challenge. **Try to implement each step yourself before looking at the files in this repo.** The code here is the completed implementation — treat it as the answer key.

Ryan's project also has a great [Medium article](https://medium.com/@ryanralmeida/learn-12-terraform-concepts-with-a-hands-on-project-b47f04392289) walking through the core Terraform concepts covered in the base project.

---

## The Challenge

Refactor the existing ALB + ASG + EC2 foundation into a production-grade, multi-environment infrastructure using Terraform modules. The goal is to stand up isolated dev, staging, and prod environments from a single codebase with environment-specific configurations.

### 1. Extract a Reusable `web-cluster` Module
Move the current ALB + ASG + launch template + security groups into `modules/web-cluster/`. The module should accept variables for:
- Environment name
- Instance type
- Min/max capacity
- Port

Also include an IAM role and instance profile so EC2 instances have the permissions they need to be managed without requiring direct SSH access.

Configure the ASG with a rolling update strategy so that when the launch template changes, instances are replaced automatically rather than requiring manual intervention. Make sure the ASG's launch template version reference actually triggers this refresh when a new version is created.

This demonstrates the DRY (Don't Repeat Yourself) principle applied to infrastructure.

### 2. Add a `networking` Module
Instead of relying on the default VPC, create a proper VPC with public and private subnets across 2 Availability Zones:
- EC2 instances live in **private subnets**
- ALB lives in **public subnets**

This reflects real-world production networking patterns.

### 3. Add Remote State with S3 + DynamoDB Locking
Create a separate `bootstrap/` directory that provisions:
- An S3 bucket for Terraform state storage
- A DynamoDB table for state locking

Then configure the `backend "s3"` block in each environment. This enables safe collaboration and is a very common interview talking point.

### 4. Wire Up Three Environments
Create `environments/dev/`, `environments/staging/`, and `environments/prod/` — each calls the same modules with different variable values:
- Smaller, cheaper instances in dev
- More replicas and higher capacity in prod

### 5. Close the Loop on Autoscaling
Connect the existing `scale_up` and `scale_down` policies to CloudWatch CPU alarms. The policies exist in the base project but nothing triggers them — finishing this demonstrates attention to detail and a complete, working system.

### 6. Add a Ruby + React Application
Deploy a small application in the same repo that makes the multi-environment infrastructure visible and tangible.

**Ruby (Sinatra) backend** — reads EC2 instance metadata and exposes it via a simple API:
```
GET /api/info → { environment, instance_id, availability_zone, region }
```

**React frontend** — fetches from the API and renders an environment dashboard showing which environment you're hitting and what instance is serving the request.

The `launch_template.tf` user_data script is updated to:
1. Install Ruby + Bundler and start Sinatra on a local port
2. Install Node.js, install frontend dependencies, and use Vite to build the React app to static files
3. Configure Apache to serve the React build and proxy `/api/*` to Sinatra

---

## Target Folder Structure

```
terraform-concepts-project/
├── app/
│   ├── backend/            # Sinatra API
│   └── frontend/           # React app
├── bootstrap/              # S3 + DynamoDB for remote state
├── modules/
│   ├── networking/         # VPC, subnets, IGW, NAT gateway, route tables
│   └── web-cluster/        # ALB, ASG, launch template, security groups, CloudWatch, IAM
└── environments/
    ├── dev/
    ├── staging/
    └── prod/
```

---

## Why This Project Stands Out

| Feature | Why It Matters |
|---|---|
| **Modules** | Shows you can write reusable, shareable Terraform |
| **Remote state + locking** | Shows you understand team/production workflows |
| **Proper VPC networking** | Public/private subnet split is expected at any real company |
| **Closed-loop autoscaling** | Completes the scaling story — policies that actually fire |
| **Multi-environment** | Demonstrates you think about the full SDLC, not just "make it work once" |
| **Ruby + React app** | Makes the infrastructure tangible — hit dev vs prod ALB and see different environments live |

---

## Prerequisites

- [Terraform](https://www.terraform.io/downloads)
- [AWS CLI](https://aws.amazon.com/cli/) configured with credentials (`aws configure`)
- An AWS account with permissions to create VPCs, EC2, ALB, IAM roles, S3, and DynamoDB

---

## Credits

Original project by [Ryan Almeida](https://github.com/ryan-almeida).
Extended by [Olivia Selmonosky](https://github.com/oselmo).
