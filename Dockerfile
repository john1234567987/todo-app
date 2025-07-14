FROM hashicorp/terraform:1.8.5

WORKDIR /app

COPY ./root /app/root
COPY ./modules /app/modules

CMD ["/bin/sh"]
