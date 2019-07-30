FROM golang:1.9-alpine as builder

RUN apk add -U git \
    && go get github.com/golang/dep/...

ADD src /go/src

WORKDIR /go/src/github.com/frederikleemans/etcdkeeper

ADD src ./
ADD Gopkg.* ./

RUN dep ensure -update
RUN go build -o etcdkeeper.bin etcdkeeper/main.go


FROM alpine:3.7

ENV HOST="0.0.0.0"
ENV PORT="8080"

RUN apk add --no-cache ca-certificates

RUN apk add --no-cache ca-certificates

WORKDIR /etcdkeeper
COPY --from=builder /go/src/github.com/frederikleemans/etcdkeeper/etcdkeeper.bin .
ADD assets assets

# Create a user group 'e3wg'
RUN addgroup -S etcdkeeper

# Create a user 'e3wu' under 'e3wg'
RUN adduser -S -D -h /etcdkeeper -G etcdkeeper etcdkeeper

# Chown all the files to the app user.
RUN chown -R etcdkeeper:etcdkeeper /etcdkeeper

# Switch to 'etcdkeeper'
USER etcdkeeper

EXPOSE ${PORT}

ENTRYPOINT ./etcdkeeper.bin -h $HOST -p $PORT
