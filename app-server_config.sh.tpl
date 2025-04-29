#!/bin/bash
    # Update the package list
    sudo apt update -y
    
    # Install the default JDK and JRE
    sudo apt install openjdk-17-jre-headless -y
    
    # Install Maven
   sudo apt install maven -y
    
   wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | sudo gpg --dearmor -o /usr/share/keyrings/elasticsearch-keyring.gpg

   # Add Elasticsearch repository
   echo "deb [signed-by=/usr/share/keyrings/elasticsearch-keyring.gpg] https://artifacts.elastic.co/packages/7.x/apt stable main" | sudo tee /etc/apt/sources.list.d/elastic-7.x.list

    # Update the package list and install filebeat
   sudo apt update -y
   sudo  apt install filebeat -y
    
    # Clone the Boardgame repository
    git clone https://github.com/SafeEHA/Boardgame.git /home/ubuntu/Boardgame
    sudo chown -R ubuntu:ubuntu /home/ubuntu/Boardgame
    
    # Build the application
    cd /home/ubuntu/Boardgame
    mvn package
    
    # Run the application in the background
    cd target
    nohup java -jar database_service_project-0.0.7.jar > /home/ubuntu/Boardgame/target/app.log 2>&1 &
    
    # Backup the original filebeat configuration
    cp /etc/filebeat/filebeat.yml /etc/filebeat/filebeat.yml.bak
    
    # Comment out the Elasticsearch output section in the original file
    sudo sed -i 's/output.elasticsearch:/# output.elasticsearch:/g' /etc/filebeat/filebeat.yml
    sudo sed -i 's/  hosts: \["localhost:9200"\]/  # hosts: \["localhost:9200"\]/g' /etc/filebeat/filebeat.yml
    
    ELK_IP="${elk_server_ip}"    
    cat <<- EOF | sudo tee -a /etc/filebeat/filebeat.yml
filebeat.inputs:
- type: log
  enabled: true
  paths:
    - /home/ubuntu/Boardgame/target/app.log

output.logstash:
  hosts: ["$ELK_IP:5044"]
EOF
    
# Start and enable filebeat
sudo systemctl start filebeat
sudo systemctl enable filebeat
    
# Test filebeat output
sudo filebeat test output

echo "App server setup completed!"