import sys, os

import boto3
from jinja2 import Environment, FileSystemLoader

def get_passwords_from_parameter_store(prefix):
    session = boto3.Session(region_name="us-west-2")
    ssm = session.client("ssm")

    response = ssm.get_parameters(
        Names=[
            f"{prefix}/db_password",
            f"{prefix}/mail_transport_password"
        ],
        WithDecryption=True
    )
    params = response["Parameters"]
    param_dict = {}
    for p in params:
        param_dict[p["Name"]] = p["Value"]
    
    return param_dict

def main():
    '''
    Create nuxeo.conf file for environment (prod or stg)
    '''
    template_dir = os.path.join(os.path.dirname(os.path.realpath(__file__)), "templates")
    environment = Environment(loader=FileSystemLoader(template_dir))
    template = environment.get_template("nuxeo.conf.j2")

    env = os.environ['NUXEO_ENV']
    parameter_prefix = f"/nuxeo/{env}"
    passwords = get_passwords_from_parameter_store(parameter_prefix)

    content = template.render(
        nuxeo_url = os.environ["NUXEO_URL"],
        nuxeo_db_password = passwords[f'{parameter_prefix}/db_password'],
        nuxeo_db_host = os.environ["NUXEO_DB_HOST"],
        nuxeo_redis_host = os.environ["NUXEO_REDIS_HOST"],
        elasticsearch_address_list = os.environ["NUXEO_ELASTICSEARCH_ENDPOINT"],
        nuxeo_s3storage_bucket = os.environ["NUXEO_S3_BUCKET"],
        nuxeo_s3storage_region = os.environ["NUXEO_S3_REGION"],
        mail_transport_user = os.environ["MAIL_TRANSPORT_USER"],
        mail_transport_password = passwords[f'{parameter_prefix}/mail_transport_password']
    )

    with open('/etc/nuxeo/nuxeo.conf', 'w') as f:
        f.write(content)

    print(f"Configured nuxeo.conf for {env}")

if __name__ == "__main__":
    sys.exit(main())