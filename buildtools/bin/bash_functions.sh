#!/bin/bash

source ~/Sety-project/devops/buildtools/bin/variables.sh
source ~/Sety-project/devops/buildtools/bin/git_functions.sh
source ~/Sety-project/devops/buildtools/bin/simex_functions.sh
source ~/Sety-project/devops/buildtools/bin/python_functions.sh

j() {
    cd ~/Sety-project/$1
}

jpl() {
    cd ~/Sety-project/pylibs/$1
}

