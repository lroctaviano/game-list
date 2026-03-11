# Game List Application

<hr>

# Pre-requisites
- Node version 20.xx or Higher [[link](https://nodejs.org/en/download)] for Client Application (Nuxt.js)
- Docker and Docker Compose installed on your machine. ([Docker Installation Guide](https://docs.docker.com/get-docker/))

# Running the Front-end application

1. From the root folder, go to the client folder
```bash
cd /client
```

2. Install dependencies
```bash
#yarn
yarn install

#or

#npm
npm install
```

3. Once completed, run the program:
```bash
#yarn
yarn run dev

#npm
npm run dev
```

# Running the API locally

1. From the root folder, go to the server folder
```bash
cd /client
```

2. Run the API by running docker-compose
```bash
cp .env.example .env   # Optional: customize environment variables
docker-compose up --build
```

