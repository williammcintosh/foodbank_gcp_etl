import json
import pandas as pd
from datetime import datetime
from io import BytesIO
from google.cloud import storage
from google.cloud.sql.connector import Connector, IPTypes
import pg8000
import sqlalchemy
from sqlalchemy import text
from tqdm import tqdm

class DatabaseHandler:
    def __init__(self, db_credentials_path):
        self.engine = self.connect_with_connector(db_credentials_path)
        self.client = storage.Client()
        self.bucket = self.client.bucket("uk-food-donation-bucket")

    def connect_with_connector(self, db_credentials_path) -> sqlalchemy.engine.base.Engine:
        with open(db_credentials_path) as f:
            db_creds = json.load(f)
        connector = Connector()
        def getconn() -> pg8000.dbapi.Connection:
            return connector.connect(
                db_creds['instance_connection_name'],
                "pg8000",
                user=db_creds['user'],
                password=db_creds['password'],
                db=db_creds['dbname'],
                ip_type=IPTypes.PUBLIC
            )
        return sqlalchemy.create_engine("postgresql+pg8000://", creator=getconn)

    def execute_sql_script(self, script_path, params=None):
        with open(script_path, 'r') as file, self.engine.connect() as conn:
            sql_script = file.read()
            trans = conn.begin()
            try:
                conn.execute(text(sql_script), params)
                trans.commit()
            except Exception as e:
                trans.rollback()

    def count_blobs(self, prefix):
        blobs = self.bucket.list_blobs(prefix=prefix)
        return sum(1 for _ in blobs) - 1


    def fetch_and_insert(self, prefix: str, is_csv, script_path: str):
        blobs = self.bucket.list_blobs(prefix=prefix)
        for blob in tqdm(blobs, total=self.count_blobs(prefix)):
            if blob.name.endswith('.json') or (is_csv and blob.name.endswith('.csv')):
                file_text = blob.download_as_text()
                if is_csv:
                    df = pd.read_csv(BytesIO(file_text.encode()))
                else:
                    df = pd.json_normalize(json.loads(file_text))
                df.columns = [c.replace(' ', '_').replace('.', '_').lower() for c in df.columns]
                with self.engine.begin() as conn:
                    for _, row in df.iterrows():
                        try:
                            self.execute_sql_script(script_path, row.to_dict())
                        except Exception as e:
                            print(f"Error: {str(e)}")
                            trans.rollback()
