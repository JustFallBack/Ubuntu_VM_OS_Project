#!/bin/bash

sudo apt update

sudo apt install -y apache2 python3 python3-pip gnuplot python3-bs4 python3-lxml sqlite3

sudo pip3 install beautifulsoup4 psutil

echo "All packages gave been installed successfully."