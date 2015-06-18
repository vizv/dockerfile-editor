FROM node:0.10
MAINTAINER Viz <viz@linux.com>

ADD . /app/
WORKDIR /app/

RUN npm install

EXPOSE 9001
CMD ["npm", "start", "--production"]
