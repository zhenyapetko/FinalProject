FROM alpine:latest AS builder
RUN apk add --no-cache hugo git  # Добавил git
WORKDIR /src
COPY ../src .
# Клонируем тему если её нет
RUN if [ ! -d "themes/hugo-resume" ]; then \
    git clone https://github.com/eddiewebb/hugo-resume themes/hugo-resume; \
    fi
RUN hugo --minify

FROM nginx:alpine
COPY --from=builder /src/public /usr/share/nginx/html