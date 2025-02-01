import sys, os
import argparse
import boto3
import json
from jinja2 import Environment, FileSystemLoader

'''
Create ucldc.conf file using values from AWS Parameter Store
'''
def main(params):
    param_path = f"/nuxeo/{params.version}-{params.env}/nuxeo_conf"
    session = boto3.Session(region_name='us-west-2')
    ssm = session.client('ssm')

    response = ssm.get_parameters_by_path(
        Path=param_path,
        WithDecryption=True
    )

    params = response['Parameters']

    param_dict = {}
    for p in params:
        param_dict[p['Name']] = p['Value']

    environment = Environment(loader=FileSystemLoader("templates/"))
    template = environment.get_template('ucldc.conf.template')

    content = template.render(
        nuxeo_url = param_dict[f'{param_path}/nuxeo_url'],
        nuxeo_db_password = param_dict[f'{param_path}/nuxeo_db_password'],
        nuxeo_db_host = param_dict[f'{param_path}/nuxeo_db_host'],
        nuxeo_redis_host = param_dict[f'{param_path}/nuxeo_redis_host'],
        elasticsearch_address_list = param_dict[f'{param_path}/elasticsearch_address_list'],
        nuxeo_s3storage_bucket = param_dict[f'{param_path}/nuxeo_s3storage_bucket'],
        nuxeo_s3storage_region = param_dict[f'{param_path}/nuxeo_s3storage_region'],
        mail_transport_user = param_dict[f'{param_path}/mail_transport_user'],
        mail_transport_password = param_dict[f'{param_path}/mail_transport_password']
    )

    filename = "ucldc.conf"
    with open(filename, "w") as f:
        f.write(content)

    print(f"Wrote file `{filename}`")

if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument('env', choices=['prod', 'stg'])
    parser.add_argument('version', choices=['2021'])
    args = parser.parse_args()
    sys.exit(main(args))