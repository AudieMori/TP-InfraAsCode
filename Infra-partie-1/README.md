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

ATERLIER 2 - MISE EN PLACE D’UNE VM ET D’UN CONTENEUR

- Installer VirtualBox
- Nouvelle
Nom : UbuntuServer
Type : Linux
Version : Ubuntu (64-bit)
- Télécharger l'iso
- Mettre le .iso dans la vm, stockage
- suivre ce que la vm  te dit au lancement
- sudo apt install -y docker.io
- sudo systemctl enable --now docker
- sudo systemctl status docker
- sudo docker run -d -p 80:80 --name webserver nginx:latest
- sudo docker ps
- curl localhost
- sudo shutdown now
- sudo docker rm -f webserver
- sudo docker ps