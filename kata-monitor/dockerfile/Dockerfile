FROM registry.access.redhat.com/ubi8/ubi:latest

RUN dnf install -y golang curl git make
COPY . /go/src/github.com/kata-containers/kata-containers
WORKDIR /go/src/github.com/kata-containers/kata-containers/src/runtime
RUN SKIP_GO_VERSION_CHECK=true make monitor

FROM registry.access.redhat.com/ubi8/ubi-minimal:latest
COPY --from=0 /go/src/github.com/kata-containers/kata-containers/src/runtime/kata-monitor /usr/bin/kata-monitor
CMD ["-h"]
ENTRYPOINT ["/usr/bin/kata-monitor"]
