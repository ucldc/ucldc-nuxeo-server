import json
import os

entries = []
for page in [0, 1, 2]:
    with open(f"output-p{page}.json", "r") as f:
        response = json.loads(f.read())

    entries.extend(response["entries"])
    # metadata = [{'path': entry['path'], 'uid': entry['uid'], 'created': entry['properties']['dc:created'], 'size': entry['properties']['file:content']['length']} for entry in entries]

print(f"{len(entries)=}")
os.remove("big_images.tsv")
with open("big_images.tsv", "a") as f:
    f.write("Size (GB)\tCreated\tUID\tPath\n")
    for entry in entries:
        file_size_bytes = entry['properties']['file:content']['length']
        file_size_gb = int(file_size_bytes) / 1024/ 1024 / 1024
        f.write(f"{file_size_gb:.2f}\t{entry['properties']['dc:created']}\t{entry['uid']}\t{entry['path']}\n")