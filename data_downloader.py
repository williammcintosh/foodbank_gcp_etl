import requests
import pandas as pd
from datetime import datetime
import json
from google.cloud import storage
from io import StringIO


def save_to_gcs(data, is_csv, filename, folder):
    bucket_name = "uk-food-donation-bucket"
    bucket_key = "uk-food-donation-082c1bfa8045.json"
    client = storage.Client.from_service_account_json(bucket_key)
    bucket = client.bucket(bucket_name)
    blob = bucket.blob(f"data_via_direct_download/{folder}/{filename}")
    if is_csv:
        blob.upload_from_string(data.to_csv(index=False), content_type='text/csv')
    else:
        blob.upload_from_string(json.dumps(data), content_type='application/json')
    print(f"Data saved successfully to GCS with filename {filename}")


def get_data(fooddata_type, is_csv):
    file_ext = "csv" if is_csv else "json"
    url = f'https://raw.githubusercontent.com/givefood/data/main/{fooddata_type}.{file_ext}'
    response = requests.get(url)
    if response.status_code == 200:
        if is_csv:
            return pd.read_csv(StringIO(response.text))
        else:
            return response.json()
    return None


def save_data(fooddata_type, is_csv):
    today_date = datetime.now().strftime("%Y-%m-%d")
    filename = f"Food_{fooddata_type.capitalize()}__{today_date}.json"
    fooddata = get_data(fooddata_type, is_csv)
    if fooddata is not None:
        save_to_gcs(fooddata, is_csv, filename, folder=fooddata_type)
    else:
        print(f"{fooddata_type} is none. :(")


if __name__ == "__main__":
    save_data("needs", is_csv=False)
    save_data("foodbanks", is_csv=True)
