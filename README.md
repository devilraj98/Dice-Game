# Dice Game – End‑to‑End CI/CD on AWS EC2

## 1. Project Overview

This project demonstrates a **complete CI/CD pipeline** for a web application (Dice Game) using **Jenkins, Docker, DockerHub, Helm, and Kubernetes (Minikube)**, all running on a **single AWS EC2 instance**.

The goal of this setup is to:

* Gain strong hands‑on DevOps experience
* Understand real‑world CI/CD issues and fixes
* Have a reusable reference for future deployments
* Be interview‑ready for 3–5 years experience roles

---

## 2. Final Architecture

```
GitHub
   │
   ▼
Jenkins (EC2)
   │
   ├─ Build Docker Image
   ├─ Push Image to DockerHub
   └─ Deploy using Helm
           │
           ▼
     Kubernetes (Minikube)
           │
           ▼
        Dice Game App
```

**Key Design Decision**
Jenkins and Minikube are installed on the **same EC2 instance** to avoid networking, kubeconfig, and tunnel complexity during learning.

---

## 3. Tech Stack Used

* AWS EC2 (Ubuntu 22.04 / 24.04)
* Jenkins (Pipeline as Code)
* Docker & DockerHub
* Kubernetes (Minikube – Docker driver)
* Helm (Application deployment)
* GitHub (Source control)

---

## 4. Repository Structure

```
Dice-Game/
├── Dockerfile
├── Jenkinsfile
├── index.html
├── helm/
│   └── dice-game/
│       ├── Chart.yaml
│       ├── values.yaml
│       └── templates/
│           ├── deployment.yaml
│           └── service.yaml
```

---

## 5. Step‑by‑Step Deployment Guide

### 5.1 EC2 Prerequisites

* Instance type: **t3.medium** (recommended)
* Disk: 30 GB
* Open ports:

  * 22 (SSH)
  * 8080 (Jenkins)

---

### 5.2 Install Docker

```bash
sudo apt update
sudo apt install -y docker.io
sudo usermod -aG docker ubuntu
sudo usermod -aG docker jenkins
newgrp docker
```

Verify:

```bash
docker run hello-world
```

---

### 5.3 Install kubectl

```bash
sudo snap install kubectl --classic
```

---

### 5.4 Install Minikube

```bash
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
sudo install minikube-linux-amd64 /usr/local/bin/minikube
```

Start Minikube **without sudo**:

```bash
minikube start --driver=docker --memory=3000mb --cpus=2
```

Verify:

```bash
kubectl get nodes
```

---

### 5.5 Install Helm

```bash
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
```

---

### 5.6 Install Jenkins

```bash
sudo apt install -y openjdk-17-jdk
```

```bash
curl -fsSL https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key | \
sudo tee /usr/share/keyrings/jenkins-keyring.asc > /dev/null
```

```bash
echo "deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian-stable binary/" | \
sudo tee /etc/apt/sources.list.d/jenkins.list > /dev/null
```

```bash
sudo apt update
sudo apt install -y jenkins
sudo systemctl start jenkins
sudo systemctl enable jenkins
```

**Get Jenkins Initial Password:**
```bash
sudo cat /var/lib/jenkins/secrets/initialAdminPassword
```

**Access Jenkins:** `http://<EC2_PUBLIC_IP>:8080`

---

### 5.7 Jenkins Plugin Installation

**Required Plugins:**
1. Go to **Manage Jenkins** → **Plugins** → **Available Plugins**
2. Install these plugins:
   * Docker Pipeline
   * Kubernetes CLI
   * Pipeline
   * Git
   * Credentials Binding

**Restart Jenkins after installation**

---

### 5.8 Configure Jenkins Credentials

**DockerHub Credentials:**
1. Go to **Manage Jenkins** → **Credentials** → **System** → **Global credentials**
2. Click **Add Credentials**
3. Select **Username with password**
4. Enter:
   * Username: `<your-dockerhub-username>`
   * Password: `<your-dockerhub-token>`
   * ID: `dockerhub-credentials`

**Create DockerHub Token:**
1. Login to DockerHub → Account Settings → Security
2. Create **New Access Token** with **Read/Write** permissions
3. Use this token as password in Jenkins

---

### 5.9 Jenkins Kubernetes Access Fix (Important)

Minikube certificates are created under the **ubuntu** user.
To allow Jenkins access:

```bash
sudo cp -r /home/ubuntu/.minikube /var/lib/jenkins/
sudo cp -r /home/ubuntu/.kube /var/lib/jenkins/
sudo chown -R jenkins:jenkins /var/lib/jenkins/.minikube /var/lib/jenkins/.kube
sudo sed -i 's|/home/ubuntu|/var/lib/jenkins|g' /var/lib/jenkins/.kube/config
```

Verify:

```bash
sudo su - jenkins
kubectl get nodes
```

---

## 6. Jenkins Pipeline Configuration

### 6.1 Create Pipeline Job

1. **New Item** → **Pipeline** → Name: `dice-game-pipeline`
2. **Pipeline Definition:** Pipeline script from SCM
3. **SCM:** Git
4. **Repository URL:** `https://github.com/<your-username>/Dice-Game.git`
5. **Branch:** `*/main`
6. **Script Path:** `Jenkinsfile`

### 6.2 Pipeline Stages

1. Checkout code from GitHub
2. Build Docker image
3. Push image to DockerHub
4. Deploy to Kubernetes using Helm

**Jenkinsfile Requirements:**
* Uses `dockerhub-credentials` for authentication
* Implements `withCredentials` binding
* Helm `upgrade --install` for deployment

---

## 7. Application Access (Important Concept)

Because Minikube uses the **Docker driver**:

* NodePort is **not exposed on EC2 public IP**
* This is expected behavior

### Correct Way to Access App

```bash
kubectl port-forward svc/dice-game 8090:80
```

From laptop:

```bash
ssh -i Project-kp.pem -L 8090:localhost:8090 ubuntu@<EC2_PUBLIC_IP>
```

Browser:

```
http://localhost:8090
```

---

## 8. Errors Faced & Resolutions (Most Important Section)

### Error 1: NodeCreationFailure in EKS

**Reason:** Free‑tier instance incompatibility and IAM misconfiguration
**Fix:** Switched to Minikube for learning

---

### Error 2: kubectl Authentication Required (HTML output)

**Reason:** kubectl was pointing to Jenkins (8080)
**Fix:** Reset kubeconfig and context using Minikube

---

### Error 3: Permission denied for Minikube certs

**Reason:** Minikube created under ubuntu, Jenkins user lacked access
**Fix:** Copied `.minikube` and `.kube` to Jenkins home and fixed ownership

---

### Error 4: Docker push unauthorized

**Reason:** DockerHub token had insufficient scopes
**Fix:** Created Read/Write access token and updated Jenkins credentials

---

### Error 5: Jenkins plugin missing

**Reason:** Required plugins not installed (Docker Pipeline, Kubernetes CLI)
**Fix:** Installed plugins via Manage Jenkins → Plugins

---

### Error 6: Credentials binding failure

**Reason:** DockerHub credentials not properly configured in Jenkins
**Fix:** Added credentials with correct ID matching Jenkinsfile

---

### Error 7: App not accessible via EC2_IP:NodePort

**Reason:** Minikube Docker driver networking limitation
**Fix:** Used `kubectl port-forward` + SSH tunneling

---

## 9. Key Learnings (Interview‑Ready)

* Difference between Minikube and EKS networking
* Kubernetes Service vs NodePort behavior
* Importance of kubeconfig and Linux permissions
* Secure DockerHub authentication using tokens
* Helm‑based deployments over raw manifests
* Real CI/CD troubleshooting

---

## 10. 4‑Year Experience Interview Questions & Answers

### Q1. Why did NodePort not work with EC2 public IP?

**Answer:** With Minikube Docker driver, NodePorts bind to the Minikube container network, not the host network. Port‑forward or ingress is required.

---

### Q2. How does Jenkins authenticate with Kubernetes?

**Answer:** Jenkins uses kubeconfig and certificate‑based authentication. The Jenkins user must have access to Kubernetes cert files.

---

### Q3. Why use Helm instead of kubectl apply?

**Answer:** Helm provides versioning, rollback, templating, and environment‑specific configuration, making deployments manageable.

---

### Q4. What caused `unauthorized: insufficient scopes` in DockerHub?

**Answer:** The DockerHub token lacked write permissions. Using a Read/Write token fixed the issue.

---

### Q5. How would you deploy this to production?

**Answer:** Replace Minikube with EKS, use Ingress with ALB, store secrets in AWS Secrets Manager, and add multi‑env Helm values.

---

### Q6. How do you roll back a failed deployment?

```bash
helm rollback dice-game <revision>
```

---

### Q7. Difference between NodePort and Ingress?

**Answer:** NodePort exposes services at node level; Ingress provides L7 routing, TLS, and domain‑based access.

---

### Q8. How do you secure CI/CD pipelines?

**Answer:** Use credential bindings, access tokens, least‑privilege IAM, and never hardcode secrets.

---

## 11. Conclusion

This project represents a **real‑world DevOps CI/CD implementation** with genuine troubleshooting experience. It is reusable, extendable, and production‑aligned.

---

✅ **Status:** Successfully Deployed and Verified
