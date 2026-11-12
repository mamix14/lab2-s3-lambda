#!/usr/bin/env bash
# Wdrożenie Lab 2 do LocalStack (polecenia przez lstk aws)
set -x
WWW=raport-koszykow-www
TPL=raport-koszykow-szablony
FN=raport-koszykow-lambda

lstk status

# --- Wariant 1: S3 Website ---
lstk aws s3 mb s3://$WWW
lstk aws s3 cp www/index.html s3://$WWW/index.html --content-type "text/html; charset=utf-8"
lstk aws s3 cp www/style.css  s3://$WWW/style.css  --content-type "text/css"
lstk aws s3 website s3://$WWW --index-document index.html
lstk aws s3api put-bucket-policy --bucket $WWW --policy file://policy.json
lstk aws s3api get-bucket-website --bucket $WWW

# --- Wariant 2: Lambda + szablon w osobnym, prywatnym buckecie ---
lstk aws s3 mb s3://$TPL
lstk aws s3 cp template.html s3://$TPL/template.html --content-type "text/html; charset=utf-8"
(cd lambda && rm -f ../funkcja.zip && zip -q ../funkcja.zip lambda_function.py)
lstk aws lambda create-function --function-name $FN \
  --runtime python3.12 --handler lambda_function.handler \
  --zip-file fileb://funkcja.zip \
  --role arn:aws:iam::000000000000:role/lambda-role \
  --environment "Variables={TEMPLATE_BUCKET=$TPL,TEMPLATE_KEY=template.html}"
lstk aws lambda wait function-active-v2 --function-name $FN
lstk aws lambda create-function-url-config --function-name $FN --auth-type NONE
