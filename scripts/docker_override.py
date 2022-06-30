import sys, os
import argparse
import shutil
import subprocess

IN_DIR = '/var/lib/3d/in'
OUT_DIR = '/var/lib/3d/out'
SCRIPT_DIR = '/var/lib/nuxeo/scripts/'
BLENDER = '/usr/local/blender/blender'

def main():
    ''' Script to stand in as `docker` command and 3D run conversion commands locally. 
        We have to do this because the nuxeo uxeo-platform-3d and uxeo-platform-3d-jsf-ui
        addons create docker containers and have them run the conversion commands.

        It's not a good idea to run docker from inside docker, so this is a hack to
        run the conversion commands locally.

        See JIRA ticket: https://jira.nuxeo.com/browse/SUPNXP-40543
    '''
    args = sys.argv[1:]
    #print(f"command: {' '.join(args)}")
    docker_cmd = args[0]
    
    if docker_cmd == 'create':
        return
    elif docker_cmd == 'version':
        return
    elif docker_cmd == 'cp':
        cp_cmd(args[1], args[2])
    elif docker_cmd == 'pull':
        return
    elif docker_cmd == 'run':
        run_cmd(args)
    elif docker_cmd == 'rm':
        print('ok remove tmp files')
    else:
        print(f"unexpected command: {docker_cmd}")

def cp_cmd(src, dst):
    if dst.endswith(':/in/'):
        src_dir = src.rstrip('.')
        for filename in os.listdir(src_dir):
            source = src_dir + filename
            shutil.copy(source, IN_DIR)
    elif dst.endswith(':/scripts/'):
        pass
    else:
        raise ValueError(f"cp doesn't know what to do with src: {src}, dst: {dst}")

    # if src matches ':/out/'
    # docker create --name #{name} #{image}, parameters: image=nuxeo/blender, name=data1656470288644
    # output: usage: docker_override.py [-h] [--name NAME] docker_cmd [param1] [param2]
    # docker_override.py: error: unrecognized arguments: nuxeo/blender

def run_cmd(args):
    if len(args) >= 8 and args[6:9] == ['-P', '/scripts/pipeline.py', '--']:
        args[7] = f"{SCRIPT_DIR}/pipeline.py"
        pipeline_args = args[6:]
        pipeline_args = [BLENDER, '-b'] + pipeline_args
        print(f"{pipeline_args}")
        # blender -b pipeline_args
    else:
        raise ValueError(f"run_command expected args[6:8] to be ['-P', '/scripts/pipeline.py', '--']")


if __name__ == "__main__":
    sys.exit(main())



