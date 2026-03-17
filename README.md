# 📦 DevOps Stock Management System

## 📌 Description

Ce projet est une application web de gestion de stock développée avec **Flask**, conteneurisée avec **Docker**, et déployée automatiquement sur **Kubernetes** via un pipeline **CI/CD Jenkins**.

L'objectif est de démontrer une chaîne DevOps complète :

> développement → build → test → déploiement automatisé

---

## 🚀 Technologies utilisées

- 🐍 Python / Flask  
- 🐳 Docker  
- ☸️ Kubernetes (Minikube)  
- 🔧 Jenkins (CI/CD)  
- 📦 Docker Hub  
- 🏗️ Terraform (infrastructure)  
- ⚙️ Ansible (configuration)  

---

## 📁 Structure du projet

```
.
├── app/                # Code de l'application Flask
├── k8s/                # Fichiers Kubernetes (deployment, service)
├── terraform/          # Scripts Terraform
├── ansible/            # Playbooks Ansible
├── Dockerfile          # Image Docker
├── Jenkinsfile         # Pipeline CI/CD
├── requirements.txt    # Dépendances Python
└── README.md
```

---

## ⚙️ Installation locale

### 1. Cloner le projet

```bash
git clone https://github.com/BOULATARM/stock-devops-project.git
cd stock-devops-project
```

### 2. Construire et lancer avec Docker

```bash
docker build -t flask-stock-app .
docker run -p 5000:5000 flask-stock-app
```

👉 Accès à l'application :  
http://localhost:5000

---

## 🐳 Docker

Build et push de l’image :

```bash
docker build -t mouadboulatar/flask-stock-app:latest .
docker push mouadboulatar/flask-stock-app:latest
```

---

## ⚙️ Pipeline CI/CD (Jenkins)

Le pipeline automatise les étapes suivantes :

- Clone du repository GitHub  
- Vérification des outils  
- Installation des dépendances  
- Tests de l'application  
- Build de l’image Docker  
- Push vers Docker Hub  
- Déploiement sur Kubernetes  

---

## ☸️ Déploiement Kubernetes

### Appliquer les ressources

```bash
kubectl apply -f k8s/deployment.yaml
kubectl apply -f k8s/service.yaml
```

### Vérifier le déploiement

```bash
kubectl get pods
kubectl get svc
```

### Accéder à l'application

```bash
minikube service flask-stock-service
```

Ou via :

http://localhost:30080

---

## 🔄 Fonctionnement CI/CD

À chaque modification du code :

➡️ Jenkins déclenche automatiquement :

- Build Docker  
- Push de l’image  
- Mise à jour du déploiement Kubernetes  

---

## 📊 Architecture

GitHub → Jenkins → Docker → Docker Hub → Kubernetes

---

## 🎯 Objectifs du projet

- Implémenter une chaîne CI/CD complète  
- Automatiser le déploiement  
- Utiliser des outils DevOps modernes  
- Déployer une application conteneurisée  

---

## 👨‍💻 Auteur

**Mouad Boulatar**
