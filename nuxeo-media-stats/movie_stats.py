import json
import os
from pathlib import Path
import requests

NUXEO_TOKEN = os.environ["NUXEO_TOKEN"]

nuxeo_request_headers = {
    "Accept": "application/json",
    "Content-Type": "application/json",
    "X-NXDocumentProperties": "*",
    "X-NXRepository": "default",
    "X-Authentication-Token": NUXEO_TOKEN
    }

query = "SELECT * FROM CustomVideo WHERE ecm:isVersion = 0 AND ecm:isTrashed = 0 AND file:content/length > 2147483648 ORDER BY file:content/length DESC"
# query = "SELECT * FROM SampleCustomPicture WHERE ecm:isVersion = 0 AND ecm:isTrashed = 0 AND file:content/length IS NOT NULL ORDER BY file:content/length DESC"
request = {
    'url': "https://nuxeo.cdlib.org/nuxeo/site/api/v1/search/lang/NXQL/execute",
    'headers': nuxeo_request_headers,
    'params': {
        'query': query
    }
}
try:
    response = requests.get(**request)
    response.raise_for_status()
except requests.exceptions.HTTPError as e:
    print(f"unable to fetch page {request}")
    raise(e)

with open("movies_larger_than_2g.json", "w") as f:
    f.write(json.dumps(response.json()))