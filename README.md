ELK Stack Deployment with Terraform.

Project Overview:
This project demonstrates the deployment and configuration of an ELK Stack (Elasticsearch, Logstash, and Kibana) using Terraform for Infrastructure as Code (IaC).
It showcases how application logs can be ingested, indexed, visualised, and monitored effectively to support observability and troubleshooting in real-world environments.


Tools & Technologies:
Terraform – Infrastructure as Code (IaC)
Elasticsearch – Centralised log storage & search engine
Logstash – Data processing pipeline
Kibana – Visualisation and monitoring dashboard
AWS – Infrastructure provisioning (servers, networking, storage)


Steps Implemented:
Provision Infrastructure with Terraform
Deployed an ELK server and App server.
Automated setup for consistency and repeatability.
Dataset Import & Querying
Imported dataset into Elasticsearch.
Queried the dataset using Kibana Dev Tools.
Troubleshooting & Index Management
Investigated and fixed unhealthy indices.
Created backups of existing indices for recovery.
Application Logs Integration
Accessed the App server and ingested application logs.
Created Kibana index patterns to map log data.
Data Visualisation & Monitoring
Built visualisations to monitor application behaviour.
Assembled multiple visualisations into comprehensive Kibana dashboards.


Key Outcomes:
Demonstrated end-to-end observability of applications.
Showcased the power of Terraform automation in managing ELK infrastructure.
Implemented log monitoring, troubleshooting, and visualisation workflows used in real-world DevOps/SRE practices.


It might interest you to note that the ELK Stack is widely used in industry for:

Centralised logging and troubleshooting
Monitoring microservices and containerised applications
Security information and event management (SIEM)
Performance optimisation and root cause analysis


How to Use This Repo
Clone the repository https://github.com/Emstev/ELK-lab.git
Update Terraform variables with your environment details.
Run terraform init, terraform plan, and terraform apply.
Access Kibana via the ELK server public DNS.
Import your datasets, configure index patterns, and start monitoring.
