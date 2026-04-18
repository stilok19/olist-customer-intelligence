from google.cloud import storage
import os
import glob

PROJECT_ID = "olist-analytics-493621"   # replace with your project ID
BUCKET_NAME = "olist-raw-data-stilok19"
DATA_DIR = "data/"

def upload_csvs_to_gcs():
    client = storage.Client(project=PROJECT_ID)
    bucket = client.bucket(BUCKET_NAME)

    csv_files = glob.glob(os.path.join(DATA_DIR, "*.csv"))

    print(f"Found {len(csv_files)} CSV files to upload...")

    for filepath in csv_files:
        filename = os.path.basename(filepath)
        destination = f"raw/{filename}"

        blob = bucket.blob(destination)
        blob.upload_from_filename(filepath)

        print(f"  ✅ Uploaded {filename} → gs://{BUCKET_NAME}/{destination}")

    print(f"\nDone! All files uploaded to gs://{BUCKET_NAME}/raw/")

if __name__ == "__main__":
    upload_csvs_to_gcs()