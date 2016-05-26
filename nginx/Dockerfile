FROM nginx
RUN apt-get update && apt-get dist-upgrade -y
ADD ./nginx.conf /etc/nginx/nginx.conf
ADD ./sites-enabled-default /etc/nginx/sites-enabled/default
