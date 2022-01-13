FROM golang:1.17-buster AS build

WORKDIR /app

COPY go.mod ./
RUN go mod download

COPY *.go ./

RUN CGO_ENABLED=0 GOOS=linux go build -o ./bin/helloworld ./

FROM gcr.io/distroless/base-debian10 AS main

WORKDIR /

COPY --from=build /app/bin/helloworld /helloworld

EXPOSE 8080

USER nonroot:nonroot

ENTRYPOINT ["/helloworld"]