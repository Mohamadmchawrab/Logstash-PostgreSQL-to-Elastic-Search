# Logstash PostgreSQL to Elasticsearch Sync

This guide provides step-by-step instructions on setting up Logstash to synchronize data from PostgreSQL to Elasticsearch. The synchronization is scheduled to run at regular intervals using a timer.

## Prerequisites

- **PostgreSQL Database**: Ensure you have a PostgreSQL database with the desired data.

- **Elasticsearch Server**: Have an Elasticsearch server ready to receive the data.

## 1. Install Logstash

Install Logstash on your machine. You can download it from the official [Logstash Downloads](https://www.elastic.co/downloads/logstash) page.

## 2. Download PostgreSQL JDBC Driver

Download the PostgreSQL JDBC driver (JAR file) from the official [PostgreSQL JDBC Driver](https://jdbc.postgresql.org/) website. Place the JAR file in a directory accessible to Logstash.

## 3. Configure Logstash and run it


1. Navigate to the directory where Logstash is installed.

2. Create a Logstash configuration file (e.g., `logstash.conf`) with the following content:

```conf

input {
  jdbc {
    jdbc_connection_string => "jdbc:postgresql://<YOUR_POSTGRES_HOST>:<YOUR_POSTGRES_PORT>/<YOUR_DATABASE>"
    jdbc_user => "<YOUR_POSTGRES_USER>"
    jdbc_password => "<YOUR_POSTGRES_PASSWORD>"
    jdbc_driver_library => "<PATH_TO_POSTGRESQL_JAR>"
    jdbc_driver_class => "org.postgresql.Driver"
    statement => "SELECT * FROM <YOUR_TABLE>"
    jdbc_paging_enabled => true
    jdbc_page_size => 50000 # controls the number of rows fetched in a single query to PostgreSQL
    schedule => "0 */12 * * *" # run it every 12 hours
  }
}

output {
  elasticsearch {
    hosts => ["http://<YOUR_ELASTICSEARCH_HOST>:<YOUR_ELASTICSEARCH_PORT>"]
    index => "<YOUR_INDEX_NAME>"
    document_id => "%{<YOUR_PRIMARY_KEY>}"
  }
  stdout { codec => rubydebug }
}
```
3. Open a terminal and navigate to the Logstash directory.

4. Run Logstash with the configured file:

    ```bash
      Run bin/logstash -f logstash.conf

      # My case to keep record
      
          /Users/moemchawrab/Documents/logstash-8.11.3/bin/logstash -f 
          /Users/moemchawrab/Documents/Matrixian/drimble_family_api/drimble_logstash/logstash-config.conf
    
    ```

    Logstash will start and synchronize data every 12 hours based on the configured schedule.

## 4. Dockerize Logstash (Optional)

If you prefer running Logstash in a Docker container, follow these steps:

1. Create a `Dockerfile`:

    ```Dockerfile
    FROM docker.elastic.co/logstash/logstash:<LOGSTASH_VERSION>

    COPY logstash.conf /usr/share/logstash/pipeline/logstash.conf
    COPY postgresql-<VERSION>.jar /usr/share/logstash/drivers/postgresql-<VERSION>.jar
    ```

2. Build the Docker image:

    ```bash
    docker build -t my-logstash-image .
    ```

3. Create a `docker-compose.yml` file:

    ```yaml
    version: '3'

    services:
      logstash:
        image: my-logstash-image
        volumes:
          - ./path/to/your/logstash/config:/usr/share/logstash/config
          - ./path/to/your/logstash/drivers:/usr/share/logstash/drivers
    ```

    Adjust the paths based on your actual setup but make sure to be on the same network with elastic search.

4. Run the Logstash container:

    ```bash
    docker-compose up -d
    ```

    Now, Logstash runs in a Docker container, and you can monitor the logs using:

    ```bash
    docker-compose logs -f logstash
    ```

Adjust the placeholders and paths based on your actual configuration.
