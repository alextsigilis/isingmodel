#!/bin/bash

make v0
make v1

./main_v0 100 10 >> v0.out
./main_v1 100 10 >> v1.out
