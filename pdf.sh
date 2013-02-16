#!/bin/sh

make latex
pwd=`pwd`
cd build/latex
tex=`ls | find *.tex`
xelatex $tex
pdf=`ls | find *.pdf`
evince $pdf &
cd "$pwd"
