#!/bin/bash
ip link add vbr0 type bridge
ip link set vbr0 up
ip link set $1 master vbr0
dhclient vbr0
