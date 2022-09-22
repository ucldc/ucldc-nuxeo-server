import sys, os
import json
from jinja2 import Environment, FileSystemLoader
from get_secret import main as get_secret

'''
Create instance.clid file using value from AWS Secrets Manager
'''
def main():
    secret = json.loads(get_secret("nuxeo/cliid", "us-west-2"))
    cli_id = secret["nuxeo-cli-id"]
    uuid = secret["uuid"]
    desc = secret["description"]

    environment = Environment(loader=FileSystemLoader("templates/"))
    template = environment.get_template('instance.clid.template')

    content = template.render(
        CLID=cli_id,
        UUID=uuid,
        description=desc
    )

    with open("instance.clid", "w") as f:
        f.write(content)

if __name__ == "__main__":
    sys.exit(main())