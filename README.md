📦 DevOps Stock Management System
📌 Description

Ce projet est une application web de gestion de stock développée avec Flask, conteneurisée avec Docker, et déployée automatiquement sur Kubernetes via un pipeline CI/CD Jenkins.

L’objectif est de démontrer une chaîne DevOps complète :
développement → build → test → déploiement automatisé.

🚀 Technologies utilisées

🐍 Python / Flask

🐳 Docker

☸️ Kubernetes (Minikube)

🔧 Jenkins (CI/CD)

📦 Docker Hub

🏗️ Terraform (infrastructure)

⚙️ Ansible (configuration)

📁 Structure du projet
.
├── app/                # Code de l'application Flask
├── k8s/                # Fichiers Kubernetes (deployment, service)
├── terraform/          # Scripts Terraform
├── ansible/            # Playbooks Ansible
├── Dockerfile          # Image Docker
├── Jenkinsfile         # Pipeline CI/CD
├── requirements.txt    # Dépendances Python
└── README.md
⚙️ Installation locale
1. Cloner le projet
git clone https://github.com/BOULATARM/stock-devops-project.git
cd stock-devops-project
2. Lancer l'application avec Docker
docker build -t flask-stock-app .
docker run -p 5000:5000 flask-stock-app

👉 Accès :

http://localhost:5000
🐳 Docker

L'application est conteneurisée avec Docker :

docker build -t mouadboulatar/flask-stock-app:latest .
docker push mouadboulatar/flask-stock-app:latest
⚙️ Pipeline CI/CD (Jenkins)

Le pipeline automatise :

Clone du repository GitHub

Vérification des outils

Installation des dépendances

Test de l'application

Build de l’image Docker

Push vers Docker Hub

Déploiement sur Kubernetes

☸️ Déploiement Kubernetes
Appliquer les ressources :
kubectl apply -f k8s/deployment.yaml
kubectl apply -f k8s/service.yaml
Vérifier :
kubectl get pods
kubectl get svc
Accéder à l'application :
minikube service flask-stock-service

ou :

http://localhost:30080
🔄 Fonctionnement CI/CD

Chaque modification du code :

➡️ Jenkins déclenche automatiquement :

build Docker

push image

mise à jour Kubernetes

📊 Architecture
GitHub → Jenkins → Docker → Docker Hub → Kubernetes
🎯 Objectifs du projet

Implémenter une chaîne CI/CD complète

Automatiser le déploiement

Utiliser des outils DevOps modernes

Déployer une application conteneurisée

👨‍💻 Auteur

Mouad Boulatar

📌 Remarques

Le projet est conçu pour un environnement local avec Minikube

Le monitoring (Prometheus/Grafana) peut être ajouté en extension