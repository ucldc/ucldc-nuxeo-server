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

query = "SELECT * FROM SampleCustomPicture WHERE ecm:isVersion = 0 AND ecm:isTrashed = 0 AND file:content/length IS NOT NULL ORDER BY file:content/length DESC"
for page_index in [0, 1, 2]:
    outfile = f"output-p{page_index}.json"
    Path(outfile).unlink(missing_ok=True)
    request = {
        'url': "https://nuxeo.cdlib.org/nuxeo/site/api/v1/search/lang/NXQL/execute",
        'headers': nuxeo_request_headers,
        'params': {
            'pageSize': '1000',
            'currentPageIndex': {page_index},
            'query': query
        }
    }

    try:
        response = requests.get(**request)
        response.raise_for_status()
    except requests.exceptions.HTTPError as e:
        print(f"unable to fetch page {request}")
        raise(e)

    with open(outfile, "a") as f:
        f.write(json.dumps(response.json()))