# Three-Tier CRUD Application \| Docker, Jenkins CI/CD & AWS EC2

A production-oriented, containerized CRUD application demonstrating an
end-to-end DevOps workflow: source control, automated image builds,
container registry publishing, and deployment to an AWS EC2 server.

The project separates the application into three services:

-   **Frontend:** React
-   **Backend:** Node.js with Express
-   **Database:** PostgreSQL
-   **Containerization:** Docker and Docker Compose
-   **CI/CD:** Jenkins Declarative Pipeline
-   **Source control & automation trigger:** GitHub and GitHub Webhooks
-   **Image registry:** Docker Hub
-   **Deployment target:** AWS EC2

> **Key outcome:** A push to the `main` branch can trigger Jenkins to
> build versioned Docker images, publish them to Docker Hub, and update
> the running application on the EC2 host.

------------------------------------------------------------------------

## Table of contents

-   [Architecture](#architecture)
-   [Application components](#application-components)
-   [Repository structure](#repository-structure)
-   [CI/CD workflow](#cicd-workflow)
-   [Docker images](#docker-images)
-   [Run locally](#run-locally)
-   [Jenkins and production
    deployment](#jenkins-and-production-deployment)
-   [Configuration and secrets](#configuration-and-secrets)
-   [Useful Docker commands](#useful-docker-commands)
-   [Security and operational
    considerations](#security-and-operational-considerations)
-   [Skills demonstrated](#skills-demonstrated)
-   [Author](#author)

------------------------------------------------------------------------

## Architecture

``` mermaid
flowchart LR
    Dev[Developer] -->|Push to main| GitHub[GitHub Repository]
    GitHub -->|Webhook| Jenkins[Jenkins on AWS EC2]
    Jenkins --> Checkout[Checkout Source]
    Checkout --> Build[Build Frontend & Backend Images]
    Build --> Tag[Tag Images]
    Tag --> Push[Push Images]
    Push --> Hub[Docker Hub]
    Hub -->|Pull latest images| Deploy[Docker Compose Deployment]
    Deploy --> FE[React Frontend]
    Deploy --> BE[Node.js / Express API]
    Deploy --> DB[(PostgreSQL)]
    FE -->|API requests| BE
    BE -->|Database connection| DB
```

The frontend, backend, and database run as separate Docker containers
and communicate over the Docker Compose network. Docker Compose manages
the multi-container application as one deployment.

------------------------------------------------------------------------

## Application components

  -----------------------------------------------------------------------
  Component               Technology              Responsibility
  ----------------------- ----------------------- -----------------------
  Frontend                React                   User interface for CRUD
                                                  operations

  Backend                 Node.js, Express        API and application
                                                  logic

  Database                PostgreSQL              Persistent relational
                                                  data storage

  Container runtime       Docker                  Builds and runs
                                                  application containers

  Service orchestration   Docker Compose          Defines services,
                                                  networking,
                                                  dependencies, and
                                                  volumes

  CI/CD                   Jenkins                 Automates build, image
                                                  publishing, and
                                                  deployment

  Registry                Docker Hub              Stores versioned
                                                  application images

  Cloud infrastructure    AWS EC2                 Hosts Jenkins and the
                                                  running application
  -----------------------------------------------------------------------

------------------------------------------------------------------------

## Repository structure

``` text
Prod-crud-app/
├── frontend/
│   └── Dockerfile
├── backend/
│   ├── Dockerfile
│   └── .env                 # Local runtime configuration; not committed
├── docker-compose.yml
├── database.sql
└── README.md
```

The Jenkins Declarative Pipeline is configured in the Jenkins job. The
application repository contains the source code and Docker Compose
deployment definition.

------------------------------------------------------------------------

## CI/CD workflow

The Jenkins pipeline automates the following stages:

### 1. Checkout

Jenkins checks out the latest source code from the `main` branch of the
GitHub repository using stored Git credentials.

### 2. Build Docker images

Jenkins builds separate images for the frontend and backend using their
respective Dockerfiles.

Each build receives a unique version tag based on the Jenkins build
number, for example:

``` text
1.0.8
```

### 3. Tag images

In addition to the unique version tag, Jenkins tags each image as
`latest`.

This provides both a build-specific image reference and a convenient
latest-build reference.

### 4. Push images to Docker Hub

Jenkins authenticates to Docker Hub using credentials stored in Jenkins
Credentials and pushes both versioned and `latest` tags.

### 5. Deploy to AWS EC2

On the EC2 host, the deployment stage:

1.  Retrieves the backend environment file from Jenkins Credentials.
2.  Makes it available to Docker Compose for deployment.
3.  Pulls the latest images from Docker Hub.
4.  Starts or updates the application services using Docker Compose.
5.  Removes the temporary environment file from the Jenkins workspace
    after the deployment shell exits.

### Pipeline flow

``` text
GitHub Push
    |
    v
GitHub Webhook
    |
    v
Jenkins Pipeline
    |
    +--> Checkout source code
    |
    +--> Build frontend image
    |
    +--> Build backend image
    |
    +--> Apply image tags
    |
    +--> Push images to Docker Hub
    |
    +--> Deploy with Docker Compose on EC2
    |
    v
Application Updated
```

------------------------------------------------------------------------

## Docker images

The pipeline publishes these images:

  Service    Docker Hub image
  ---------- --------------------------------------
  Frontend   `hassanmehmood820/crud-app-frontend`
  Backend    `hassanmehmood820/crud-app-backend`

Each image is published with a unique build tag and the `latest` tag.

Example:

``` bash
docker pull hassanmehmood820/crud-app-frontend:latest
docker pull hassanmehmood820/crud-app-backend:latest
```

------------------------------------------------------------------------

## Run locally

### Prerequisites

Install:

-   Git
-   Docker Engine
-   Docker Compose (Docker Compose v2)

### 1. Clone the repository

``` bash
git clone https://github.com/hassanali820/Prod-crud-app.git
cd Prod-crud-app
```

### 2. Configure backend environment variables

Create the backend environment file:

``` bash
touch backend/.env
```

Add the required database connection and application environment
variables expected by the backend and `docker-compose.yml`.

**Do not commit `backend/.env` to GitHub.** Keep it in `.gitignore` and
use your own local values.

### 3. Build and start the application

``` bash
docker compose up -d --build
```

### 4. Check running containers

``` bash
docker compose ps
```

### 5. Access the application

With the port mappings in the supplied Compose configuration:

-   **Frontend:** `http://localhost`
-   **Backend API:** `http://localhost:5000`

The frontend port depends on the port mapping in `docker-compose.yml`.
If you change that mapping, use the corresponding local URL.

------------------------------------------------------------------------

## Jenkins and production deployment

### Infrastructure

The project is deployed on an AWS EC2 instance that hosts:

-   Jenkins
-   Docker Engine
-   Docker Compose
-   The production application containers

The project setup uses a `t2.large` EC2 instance as the host for Jenkins
and the application workload.

### Jenkins job configuration

The Jenkins job is configured as a Pipeline job using a Declarative
Pipeline script.

The pipeline uses Jenkins credentials rather than hardcoding
authentication details:

  -----------------------------------------------------------------------
  Credential ID                       Purpose
  ----------------------------------- -----------------------------------
  `github_cred`                       GitHub repository checkout

  `docker_hub_cred`                   Docker Hub authentication

  `backend_env`                       Backend environment file supplied
                                      securely at deployment time
  -----------------------------------------------------------------------

Create these credentials in **Manage Jenkins → Credentials** before
running the pipeline. The IDs above must match the IDs referenced by the
pipeline script.

### GitHub webhook

A GitHub webhook is configured to notify Jenkins when code is pushed.
The Jenkins job has the GitHub push trigger enabled.

The intended deployment flow is:

1.  Developer pushes changes to `main`.
2.  GitHub sends a webhook event to Jenkins.
3.  Jenkins starts the pipeline.
4.  New frontend and backend images are built and pushed.
5.  Docker Compose updates the application on EC2.

Ensure the Jenkins webhook endpoint is reachable from GitHub and that
the EC2 security group allows only the network access required by your
deployment.

------------------------------------------------------------------------

## Configuration and secrets

The backend environment file is required by Docker Compose at runtime.

-   Keep `backend/.env` out of source control.
-   Add `backend/.env` to `.gitignore`.
-   Store the deployment environment file in Jenkins Credentials as a
    **Secret file** with the ID `backend_env`.
-   Store Docker Hub credentials in Jenkins Credentials.
-   Never put passwords, tokens, or production secrets directly in the
    repository or pipeline script.

If a secret was previously committed to Git history, removing it from
the latest commit does not remove it from earlier commits. Rotate any
exposed credentials and consider cleaning the repository history where
appropriate.

------------------------------------------------------------------------

## Useful Docker commands

View running containers:

``` bash
docker ps
```

View all containers:

``` bash
docker ps -a
```

View application logs:

``` bash
docker compose logs -f
```

View logs for one service:

``` bash
docker compose logs -f backend
docker compose logs -f frontend
docker compose logs -f db
```

Check service status:

``` bash
docker compose ps
```

Pull images:

``` bash
docker compose pull
```

Start or update services:

``` bash
docker compose up -d
```

Stop and remove containers and the Compose network:

``` bash
docker compose down
```

> **Database safety:** The PostgreSQL data is stored in a Docker named
> volume. Avoid `docker compose down -v` unless you intentionally want
> to delete the database volume and its data. Do not remove production
> database volumes as part of routine deployments.

------------------------------------------------------------------------

## Security and operational considerations

This project demonstrates several practical deployment practices:

-   Separate frontend, backend, and database services.
-   Use Docker Compose for repeatable multi-container deployments.
-   Store registry credentials and backend environment configuration in
    Jenkins Credentials.
-   Publish versioned images so a specific build can be identified.
-   Keep the database in a persistent Docker volume rather than relying
    on the lifecycle of a container.
-   Use GitHub webhooks to initiate CI/CD automatically.

For a hardened production environment, additional improvements can
include restricting public access to Jenkins, enabling HTTPS, using a
secrets manager, adding automated tests and health checks, backing up
PostgreSQL, and implementing deployment rollback procedures.

------------------------------------------------------------------------

## Skills demonstrated

-   Linux and AWS EC2 administration
-   Git and GitHub source control
-   GitHub Webhook integration
-   Docker image creation and tagging
-   Docker Compose multi-container deployment
-   Jenkins Declarative Pipeline
-   CI/CD automation
-   Docker Hub image registry management
-   Jenkins Credentials and secret handling
-   PostgreSQL persistence with Docker volumes
-   Production application deployment and troubleshooting

------------------------------------------------------------------------

## Author

**Hassan Mehmood**\
DevOps & Cloud Enthusiast

GitHub: [hassanali820](https://github.com/hassanali820)

------------------------------------------------------------------------

*This project was built as a hands-on DevOps implementation to practice
and demonstrate an automated container build, registry publishing, and
EC2 deployment workflow.*
