# Common stage
FROM node:14 AS CommonStage
WORKDIR /workspace
USER root
RUN npm config --global set user root

# Development stage
FROM CommonStage AS DevStage
EXPOSE 4000 4200 4433 5000 8080 9876
RUN yarn global add eslint tslint typescript @angular/cli
RUN ng config -g cli.packageManager yarn

# Deployment stage <enter your deployment logic>
FROM CommonStage
