import os
import subprocess

image_dir = '/Users/bhui/Documents/nuxeo-test-images'
width = 16500
output_dir = f"{image_dir}/{width}"
os.makedirs(output_dir, exist_ok=True)

for file in os.listdir(f"{image_dir}/orig"):
    convert_cmd = f"magick {image_dir}/orig/{file} -resize {width}x {image_dir}/{width}/{file}"
    convert_cmd = convert_cmd.split(" ")
    print(convert_cmd)
    subprocess.run(convert_cmd)