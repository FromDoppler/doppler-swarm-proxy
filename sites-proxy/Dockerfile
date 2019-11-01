FROM nginx:stable-alpine

COPY html/* /usr/share/nginx/html/
COPY conf.d/* /etc/nginx/conf.d/

EXPOSE 80/tcp

CMD ["/bin/sh", "-c", "exec nginx -g 'daemon off;';"]

WORKDIR /usr/share/nginx/html