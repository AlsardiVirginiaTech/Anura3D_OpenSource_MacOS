#!/bin/bash
cd ~/Projects/Anura3D/build
cmake ..
make 2>&1 | grep -i error | head -10
