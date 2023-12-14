# Use the official Logstash image
FROM docker.elastic.co/logstash/logstash:7.17.0

# Copy the Logstash configuration file to the container
COPY ./logstash-config.conf /usr/share/logstash/pipeline/logstash-config.conf
COPY ./postgresql-42.7.1.jar /usr/share/logstash/drivers/postgresql-42.7.1.jar
