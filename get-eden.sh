#!/bin/bash

function git_clone() {
    url=$1
    brunch=${2:-master}
    git clone "$url" -b "$brunch"
}

function get_eden() {
    brunch=${1:-master}
    git_clone https://github.com/lf-edge/eden.git "$brunch"
}

get_eden