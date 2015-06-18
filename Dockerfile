FROM node:0.10
MAINTAINER Viz <viz@linux.com>

RUN groupadd app && useradd --create-home --home-dir /home/app -g app app

ADD . /app/
WORKDIR /app/
RUN chown -R app:app .
USER app

RUN npm install

EXPOSE 9001
CMD ["npm", "start", "--production"]
