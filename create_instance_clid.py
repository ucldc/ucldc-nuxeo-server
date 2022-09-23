import sys, os
import argparse
import boto3
import json
from jinja2 import Environment, FileSystemLoader

'''
Create instance.clid file using values from AWS Parameter Store
Also set CLID env var
'''
def main(params):

    ######################################################################################
    # get the CLID related values from AWS Parameter Store
    ######################################################################################
    param_path = f"/nuxeo/{params.version}-{params.env}/instance_cliid"
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

    ######################################################################################
    # create instance.clid file, which Nuxeo checks to confirm the instance is registered
    ######################################################################################
    environment = Environment(loader=FileSystemLoader("templates/"))
    template = environment.get_template('instance.clid.template')

    content = template.render(
        CLID=param_dict[f'{param_path}/cli_id'],
        UUID=param_dict[f'{param_path}/uuid'],
        description=param_dict[f'{param_path}/description'],
    )

    filename = "instance.clid"
    with open(filename, "w") as f:
        f.write(content)

    print(f"Wrote file `{filename}`")

    ################################################################################################
    # create a file containing the value of CLID, which CodeBuild will then use to set CLID env var
    ################################################################################################
    with open('.clid', 'w') as f:
        f.write(param_dict[f'{param_path}/cli_id'])

if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument('env', choices=['prod', 'stg'])
    parser.add_argument('version', choices=['2021'])
    args = parser.parse_args()
    sys.exit(main(args))