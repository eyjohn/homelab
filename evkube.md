
# Create cluster

gcloud container clusters create evkube --num-nodes 3 --disk-size 10 -m f1-micro --no-enable-cloud-logging --no-enable-cloud-monitoring

f1-micro cant support logging/monitoring, had to disable, disk-size keeps total of 30 GB free tier
