# Docker Template Service
This service contains a library of opinionated Docker images which can be spun up or down as services.

The current services include:
- Postgres (15.2)
- pgvector (0.4)

# Usage
## List available services
To obtain a list of available images, run:
```
service list
```
## Start a service
Start a service by running the command:
```
service start [service_name] [project_name]
```
For example: `service start postgres demo` will start a postgres docker container.

To run the generator in interactive mode, you may omit the service and project name arguments.

## Stop a service
To stop a running service, use the following command:
```
```

# Creating services
Services can be created by adding a new Dockerfile and .env file to the `services` directory.

For example:

To create a new service called `spud`:
1. Create a subdirectory in `services` called `spud`
2. Add a Dockerfile which defines the Docker image
3. Add a .env file with the relevant environment variables for the service (see [Environment](#Environment) below)

The directory structure should look like the following:
```
..
services/
  |__ spud/
      |__ Dockerfile
      |__ .env
```

# Environment
The following environment variables may be set in the .env file of a service.

| Variable | Value | Purpose |
--- | --- | ---
SVC_PORT | int | Defines the port inside the container which should be bound to the external system. Ex: Postgres listens on port 5432. Therefore, `SVC_PORT=5432`. _Note: the external system port will likely be different_