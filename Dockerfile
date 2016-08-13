FROM node:5
EXPOSE 80
ENV WORKDIR /workdir
RUN mkdir $WORKDIR
RUN npm install -g hexo
COPY . $WORKDIR
WORKDIR $WORKDIR
RUN npm install \
    && hexo generate
CMD hexo server -s -p 80
