# Multi-Environment AWS Web Platform with Reusable Modules

## The Concept

Refactor the existing ALB + ASG + EC2 foundation into a **production-grade, multi-environment infrastructure** using Terraform modules. The goal is to stand up isolated dev, staging, and prod environments from a single codebase with environment-specific configurations.

---

## What to Build

### 1. Extract a Reusable `web-cluster` Module
Move the current ALB + ASG + launch template + security groups into `modules/web-cluster/`. The module should accept variables for:
- Environment name
- Instance type
- Min/max capacity
- Port

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

Then configure the `backend "s3"` block in root modules. This enables safe collaboration and is a very common interview talking point.

### 4. Wire Up Three Environments
Create `environments/dev/`, `environments/staging/`, and `environments/prod/` — each calls the same modules with different variable values:
- Smaller, cheaper instances in dev
- More replicas and higher capacity in prod

### 5. Close the Loop on Autoscaling
Connect the existing `scale_up` and `scale_down` policies to **CloudWatch CPU alarms**. Currently the policies exist but nothing triggers them — finishing this demonstrates attention to detail and a complete, working system.

### 6. Add a Ruby + React Application
Deploy a small application in the same repo that makes the multi-environment infrastructure visible and tangible.

**Ruby (Sinatra) backend** — reads EC2 instance metadata and exposes it via a simple API:
```
GET /api/info → { environment, instance_id, availability_zone, region }
```

**React frontend** — fetches from the API and renders an environment dashboard showing which environment you're hitting and what instance is serving the request.

The `launch_template.tf` user_data script is updated to:
1. Install Ruby + Bundler and start Sinatra on a local port
2. Install Node.js, build the React app to static files
3. Configure Apache to serve the React build and proxy `/api/*` to Sinatra

---

## Target Folder Structure

```
terraform-concepts-project/
├── app/
│   ├── backend/            # Sinatra API (server.rb, Gemfile)
│   └── frontend/           # React app (src/App.jsx, package.json)
├── bootstrap/              # S3 + DynamoDB for remote state
├── modules/
│   ├── networking/         # VPC, subnets, IGW, route tables
│   └── web-cluster/        # ALB, ASG, security groups, CloudWatch
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

## Key Gaps This Addresses in the Current Project

1. **Default VPC** — production infrastructure should use a purpose-built VPC with proper subnet isolation
2. **Dangling scaling policies** — `scale_up` and `scale_down` exist but are never triggered
3. **No remote state** — required for any team-based or production Terraform workflow
4. **No environment separation** — a single flat configuration doesn't reflect how real infra is managed
