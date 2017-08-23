#!/bin/sh

chmod +x 1_create_package/gitea/gitea
cd 1_create_package 
tar cvfz package.tgz * 
mv package.tgz ../2_create_project/ 
cd ../2_create_project/ 
tar cvfz gitea.spk * 
mv gitea.spk ..
rm -f package.tgz
