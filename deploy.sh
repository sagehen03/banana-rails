#!/bin/bash
cd banana-rails
sudo docker-compose down
cd ..
sudo rm -rf banana-rails
git clone git@github.com:sagehen03/banana-rails.git --depth=1
cd banana-rails
touch dev.env
sudo docker-compose up -d