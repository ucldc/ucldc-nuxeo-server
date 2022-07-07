import sys, os
import argparse
import shutil
from distutils import dir_util
import subprocess

FILE_DIR = '/var/lib/3d'
IN_DIR = '/var/lib/3d/in'
OUT_DIR = '/var/lib/3d/out'
SCRIPT_DIR = '/usr/local/bin/pipeline_scripts'
BLENDER = '/usr/local/blender/blender'
COLLADA2GLTF = '/usr/local/bin/collada2gltf'

def main():
    ''' Script to stand in as `docker` command and 3D run conversion commands locally. 
        We have to do this because the nuxeo uxeo-platform-3d and uxeo-platform-3d-jsf-ui
        addons create docker containers and have them run the conversion commands.

        It's not a good idea to run docker from inside docker, so this is a hack to
        run the conversion commands locally.

        See JIRA ticket: https://jira.nuxeo.com/browse/SUPNXP-40543
    '''
    args = sys.argv[1:]
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
        raise ValueError(f"unexpected command: {docker_cmd}")

def cp_cmd(src, dst):
    if dst.endswith(':/in/'):
        src_dir = src.rstrip('.')
        for filename in os.listdir(src_dir):
            source = os.path.join(src_dir, filename)
            shutil.copy(source, IN_DIR)
    elif dst.endswith(':/scripts/'):
        pass
    elif src.endswith(':/out/.'):
        dir_util.copy_tree(OUT_DIR, dst)
    else:
        raise ValueError(f"cp_cmd doesn't know what to do with src: {src}, dst: {dst}")

def run_cmd(args):
    if args[5] == 'nuxeo/blender' and args[6:9] == ['-P', '/scripts/pipeline.py', '--']:
        args[7] = f"{SCRIPT_DIR}/pipeline.py"
        if args[9] == '--input' and args[11] == '--outdir':
            args[10] = f"{FILE_DIR}{args[10]}"
            args[12] = OUT_DIR
        else:
            raise ValueError(f"run_command for blender expected args[9] to be '--input' and args[11] to be '--outdir")
        pipeline_args = args[6:]
        blender_cmd = [BLENDER, '-b'] + pipeline_args
        blender_cmd = ' '.join(blender_cmd)
        print(f"{blender_cmd}")
        subprocess.run(blender_cmd, shell=True, check=True)
    elif args[5] == 'nuxeo/collada2gltf':
        print(f"args: {args}")
        gltf_cmd = [COLLADA2GLTF] + args[6:]
    else:
        raise ValueError(f"run_cmd doesn't know what to do with these args: {args}")


if __name__ == "__main__":
    sys.exit(main())


