# Automated-web-hosting-solution-using-terraform---project
This project leverages **Terraform** to provision a scalable, modular, and cloud-native web application on **Microsoft Azure**. It supports dynamic deployments across **Development**, **UAT**, and **Production** environments, embracing Infrastructure-as-Code (IaC) principles to ensure automation, repeatability, and consistency.


## 📂 Project Structure


```text

├── env/                 # Environment-specific variable files
│   ├── dev.tfvars
│   ├── prod.tfvars
│   └── uat.tfvars
├── scripts/             # Helper scripts/templates
│   └── install_web.sh.tmpl
├── web/                 # Website assets/templates
│   ├── index.html.tmpl
│   └── style.css
├── main.tf              # Main infrastructure configuration
├── variables.tf         # Input variables
├── outputs.tf           # Output values
├── .terraform.lock.hcl  # Provider version lock file
├── Project_report.pdf      
├── Working snapshots of the project.pdf         
├── Architecture design.pdf

```
## 🧰 Prerequisites

Before you get started, make sure you have the following installed and configured:

- ✅ [Terraform](https://developer.hashicorp.com/terraform/downloads) v1.x or later  
- ✅ [Azure CLI](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli) (`az login`)  
- ✅ An Azure subscription with Contributor-level access  

---

## 🌟 Key Features

- 🧩 **Modular design** for easy extension and reuse  
- 🖥️ **Multi-environment support** via separate `.tfvars` files (Dev, UAT, Prod)  
- ☁️ **Azure-native resources**: VMs, Load Balancers, NSGs, VNETs  
- ⚙️ **Automation-first**: scriptable deployment with minimal manual setup  
- 📎 **Documentation included**: report, architecture diagram, and screenshots  

---



## 🚀 Deployment Guide

### 1️⃣ Clone the repository

```bash
git clone https://github.com/jkgithub-07/Automated-web-hosting-solution-using-terraform---project.git
cd Automated-web-hosting-solution-using-terraform---project
```

### 2️⃣ Initialize Terraform

```bash
terraform init
```

### 3️⃣ Plan the infrastructure

Choose your environment configuration:

```bash
terraform plan -var-file="env/dev.tfvars"
```

### 4️⃣ Apply the configuration

```bash
terraform apply -var-file="env/dev.tfvars"
```

💡 Repeat the process using `uat.tfvars` or `prod.tfvars` to deploy other environments.

## ✒️Note

- This repo intentionally excludes sensitive files like terraform.tfstate and .tfvars secrets.
- Tested on Azure with multiple environments — screenshots included.



               
