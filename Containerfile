FROM docker.io/library/golang:1.24 as base

WORKDIR /app

COPY ./go.mod ./go.sum ./logfetcher/
WORKDIR /app/logfetcher
RUN go mod download;

FROM base as dev
RUN go install github.com/air-verse/air@latest

# volume is mounted by compose for hot reload
COPY ./ ./

ENTRYPOINT [ \
  "air", \
  "--build.poll=true", \
  "--build.send_interrupt=true", \
  "--build.kill_delay=1", \
  "--build.cmd", "/usr/bin/true", \
  "--build.bin", "go run ./" \
]

### Build
FROM base as logfetcher
COPY ./ ./
RUN CGO_ENABLED=0 GOOS=linux go build -mod=mod -o /logfetcher ./

ENTRYPOINT [ "/logfetcher" ]
