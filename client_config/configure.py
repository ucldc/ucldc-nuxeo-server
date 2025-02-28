import sys, os
import json

import boto3
from botocore.exceptions import ClientError
from jinja2 import Environment, FileSystemLoader

def get_passwords_from_parameter_store(prefix, session):
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

def get_secret(secret_name, session):

    client = session.client(
        service_name='secretsmanager'
    )

    try:
        get_secret_value_response = client.get_secret_value(
            SecretId=secret_name
        )
    except ClientError as e:
        raise e

    return get_secret_value_response['SecretString']

def main():
    '''
    Create nuxeo.conf file for environment (prod or stg)
    '''
    template_dir = os.path.join(os.path.dirname(os.path.realpath(__file__)), "templates")
    environment = Environment(loader=FileSystemLoader(template_dir))
    template = environment.get_template("nuxeo.conf.j2")

    boto_session = boto3.Session(region_name="us-west-2")
    parameter_prefix = f"/nuxeo/{os.environ['NUXEO_ENV']}"
    parameter_store_passwords = get_passwords_from_parameter_store(parameter_prefix, boto_session)
    msk_sasl_credentials = json.loads(get_secret("AmazonMSK_nuxeo", boto_session))

    content = template.render(
        nuxeo_url = os.environ["NUXEO_URL"],
        nuxeo_db_password = parameter_store_passwords[f'{parameter_prefix}/db_password'],
        nuxeo_db_host = os.environ["NUXEO_DB_HOST"],
        kafka_bootstrap_servers = os.environ["NUXEO_KAFKA_BOOTSTRAP_SERVERS"],
        msk_sasl_username = msk_sasl_credentials['username'],
        msk_sasl_password = msk_sasl_credentials['password'],
        elasticsearch_address = os.environ["NUXEO_ELASTICSEARCH_ENDPOINT"],
        nuxeo_s3storage_bucket = os.environ["NUXEO_S3_BUCKET"],
        nuxeo_s3storage_region = os.environ["NUXEO_S3_REGION"],
        mail_transport_user = os.environ["NUXEO_MAIL_TRANSPORT_USER"],
        mail_transport_password = parameter_store_passwords[f'{parameter_prefix}/mail_transport_password']
    )

    with open('/etc/nuxeo/conf.d/ucldc.conf', 'w') as f:
        f.write(content)

    print(f"Wrote /etc/nuxeo/conf.d/ucldc.conf for {env}")

if __name__ == "__main__":
    sys.exit(main())