import html
import os

import boto3

BUCKET = os.environ.get("TEMPLATE_BUCKET", "raport-koszykow-szablony")
KEY = os.environ.get("TEMPLATE_KEY", "template.html")

# W LocalStack zmienna AWS_ENDPOINT_URL jest ustawiana automatycznie
s3 = boto3.client("s3", endpoint_url=os.environ.get("AWS_ENDPOINT_URL"))


def handler(event, context):
    params = event.get("queryStringParameters") or {}
    imie = (params.get("imie") or "").strip()

    if not imie:
        return {
            "statusCode": 400,
            "headers": {"Content-Type": "text/plain; charset=utf-8"},
            "body": "Brak parametru imie. Użyj np. ?imie=Ola",
        }

    # Szablon pobierany przy każdym żądaniu - zmiana w S3 widoczna bez ponownego wdrożenia
    szablon = s3.get_object(Bucket=BUCKET, Key=KEY)["Body"].read().decode("utf-8")
    strona = szablon.replace("{{IMIE}}", html.escape(imie))

    return {
        "statusCode": 200,
        "headers": {"Content-Type": "text/html; charset=utf-8"},
        "body": strona,
    }
