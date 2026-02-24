#!/bin/bash
# EC2 User Data Script for Ubuntu - Node.js App Version

set -e

# Update system
apt-get update -y
apt-get upgrade -y

# Install Docker
apt-get install -y apt-transport-https ca-certificates curl software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
apt-get update -y
apt-get install -y docker-ce docker-ce-cli containerd.io

# Start Docker
systemctl start docker
systemctl enable docker
usermod -a -G docker ubuntu

# Install AWS CLI
apt-get install -y unzip
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
./aws/install
rm -rf awscliv2.zip aws/

# Mount EBS volume
if [ -e /dev/sdf ]; then
    if ! blkid /dev/sdf; then
        mkfs -t xfs /dev/sdf
    fi
    mkdir -p /data
    mount /dev/sdf /data
    echo "/dev/sdf /data xfs defaults,nofail 0 2" >> /etc/fstab
else
    mkdir -p /data
fi

# Pull your Docker image
echo "Pulling Docker image: ${docker_image}"
docker pull ${docker_image}

# Stop and remove existing container
docker stop elegant-events || true
docker rm elegant-events || true


# Run container
echo "Starting container on port ${app_port}..."
docker run -d \
  --name elegant-events \
  -p 80:${app_port} \
  -v /data:/data \
  --restart always \
  ${docker_image}

# Give the app a moment to start
sleep 5

# Verify container is running
if curl -s http://localhost > /dev/null; then
    echo "✅ Application is running and responding on port 80"
else
    echo "❌ Application failed to respond"
    docker logs elegant-events
    exit 1
fi

# Backup application source to S3
echo "📤 Backing up application source to S3 bucket: ${s3_bucket}"
docker cp elegant-events:/app /tmp/app-backup 2>/dev/null || true

if [ -d /tmp/app-backup ]; then
    aws s3 sync /tmp/app-backup s3://${s3_bucket}/app-backup/ --only-show-errors
    rm -rf /tmp/app-backup
else
    echo "⚠️  Could not copy /app from container skipping backup"
fi

# Print completion message
echo "=========================================="
echo "✅ DEPLOYMENT COMPLETE!"
echo "=========================================="
PUBLIC_IP=$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4)
echo "🌐 Website URL: http://$PUBLIC_IP"
echo "📦 Docker Image: ${docker_image}"
echo "💾 EBS Mount: /data"
echo "☁️  S3 Bucket: ${s3_bucket}"
echo ""
echo "💻 SSH Command: ssh -i your-key.pem ubuntu@$PUBLIC_IP"
echo "📋 Check logs: docker logs elegant-events"
echo "=========================================="