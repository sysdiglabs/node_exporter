FROM golang:1.17.0 as builder

WORKDIR /go/src/github.com/prometheus/node_exporter

COPY . .
RUN go mod download
RUN make 

RUN mkdir /user && \
    echo 'nobody:x:65534:65534:nobody:/:' > /user/passwd && \
    echo 'nobody:x:65534:' > /user/group

FROM scratch as scratch
COPY --from=builder /go/src/github.com/prometheus/node_exporter/node_exporter /bin/node_exporter
COPY --from=builder /user/group /user/passwd /etc/

EXPOSE      9100
USER        nobody
ENTRYPOINT  [ "/bin/node_exporter" ]

FROM quay.io/sysdig/sysdig-mini-ubi9:1.2.0 as ubi
COPY --from=builder /go/src/github.com/prometheus/node_exporter/node_exporter /bin/node_exporter

EXPOSE      9100
USER        nobody
ENTRYPOINT  [ "/bin/node_exporter" ]
