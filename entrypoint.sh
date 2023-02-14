#!/usr/bin/env bash
(tcp-tcp 127.0.0.1:10800 0.0.0.0:1080 >/tmp/tcp-tcp.log 2>&1 &)
warp-svc
