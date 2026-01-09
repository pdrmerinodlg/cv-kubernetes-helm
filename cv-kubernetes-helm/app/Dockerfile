# Dockerfile para CV Web Application
FROM nginx:alpine

# Metadatos
LABEL maintainer="pdrmerinodlg@gmail.com"
LABEL description="CV Personal - Pedro Merino DevOps Engineer"
LABEL version="1.0"

# Copiar configuración personalizada de nginx
COPY nginx.conf /etc/nginx/nginx.conf

# Copiar archivos HTML/CSS/JS
COPY html/ /usr/share/nginx/html/

# Exponer puerto 80
EXPOSE 80

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD wget --quiet --tries=1 --spider http://localhost/ || exit 1

# Usuario no-root por seguridad
RUN chown -R nginx:nginx /usr/share/nginx/html && \
    chmod -R 755 /usr/share/nginx/html && \
    chown -R nginx:nginx /var/cache/nginx && \
    chown -R nginx:nginx /var/log/nginx && \
    touch /var/run/nginx.pid && \
    chown -R nginx:nginx /var/run/nginx.pid

USER nginx

# Comando por defecto
CMD ["nginx", "-g", "daemon off;"]
