FROM golang:1.22.3 as builder

RUN apt update && apt upgrade -y && apt install iptables -y

RUN git clone --single-branch --branch v1.11.1 https://github.com/coredns/coredns.git /coredns

WORKDIR /coredns

RUN make gen
RUN make

RUN mkdir -p plugin/netmaker
RUN echo 'netmaker:github.com/gravitl/netmaker-coredns-plugin' >> /coredns/plugin.cfg

COPY *.go /coredns/plugin/netmaker/
RUN make
RUN chmod 0755 /coredns/coredns

FROM alpine:3.19
RUN apk add iptables

COPY --from=builder /coredns/coredns /
COPY Corefile /

EXPOSE 53

ENTRYPOINT ["/coredns"]