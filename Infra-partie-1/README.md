ATELIER 1 MONGODB EN LOCAL AVEC DOCKER
- Créer le docker-compose.yml avec à l'intérieur : 
version: "3.9"

services: 
    mongo: 
        image: mongo:7
        container_name: mongo
        restart: always
        ports: 
            -"27017:27017"
        environment: 
            MONGO_INITDB_ROOT_USERNAME: root
            MONGO_INITDB_ROOT_PASSWORD: 123
        volumes:
            -./db_data:/data/db

- docker compose up -d
- docker build -t mongo .
- docker exec -it mongo mongosh -u root -p example
- use myapp
- db.createCollection("users")
- db.users.insertOne({ name: "Alice" })
- show dbs
- show collections
- mongodb://root:example@localhost:27017/admin