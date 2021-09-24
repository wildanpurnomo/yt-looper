FROM node:lts-alpine

# make the 'app' folder the current working directory
WORKDIR /app

# copy both 'package.json' and 'package-lock.json' (if available)
COPY package*.json ./

# install project dependencies
RUN npm install
RUN npm install @vue/cli@4.5.13

# copy project files and folders to the current working directory (i.e. 'app' folder)
COPY . .

# run baby
CMD [ "npm", "run", "serve"]