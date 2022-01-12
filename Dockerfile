FROM golang:1.17-alpine3.15 AS build

WORKDIR /app

COPY go.mod ./
COPY go.sum ./
RUN go mod download

COPY *.go ./

RUN go build -o ./bin/helloworld ./

FROM gcr.io/distroless/base-debian10 AS main

WORKDIR /

COPY --from=build /app/bin/helloworld /helloworld

EXPOSE 8080

USER nonroot:nonroot

ENTRYPOINT ["/helloworld"]