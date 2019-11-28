FROM nginx:1.16-alpine

COPY html/* /usr/share/nginx/html/
COPY conf.d/* /etc/nginx/conf.d/
ARG version=unknown
RUN echo $version > /usr/share/nginx/html/version.txt

EXPOSE 80/tcp
EXPOSE 443/tcp

CMD ["/bin/sh", "-c", "exec nginx -g 'daemon off;';"]

WORKDIR /usr/share/nginx/html