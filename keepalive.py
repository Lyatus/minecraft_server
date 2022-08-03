import datetime
import hashlib
import json
import os
import subprocess
import urllib.request

import psutil


def json_query(url):
    return json.loads(urllib.request.urlopen(url).read())


def update_server():
    version_manifest = json_query("https://launchermeta.mojang.com/mc/game/version_manifest.json")
    latest_version_id = version_manifest["latest"]["release"]
    print("Minecraft server latest version: " + latest_version_id)

    latest_version_meta = next(filter(lambda v: v["id"] == latest_version_id, version_manifest["versions"]))
    latest_version = json_query(latest_version_meta["url"])
    latest_server = latest_version["downloads"]["server"]

    try:
        with open("server.jar", "rb") as server_file:
            sha1 = hashlib.sha1()
            sha1.update(server_file.read())
            if sha1.hexdigest() == latest_server["sha1"]:
                print("Minecraft server is already up-to-date")
                return False
    except FileNotFoundError:
        pass

    with open("server.jar", "wb") as server_file:
        print("Minecraft server is updating...")
        server_file.write(urllib.request.urlopen(latest_server["url"]).read())
    return True


def ensure_server_running(should_run):
    server_proc = None
    for proc in psutil.process_iter():
        try:
            if "server.jar" in proc.cmdline():
                server_proc = proc
        except:
            pass

    if should_run:
        if server_proc == None:
            print("Minecraft starting...")
            subprocess.run(["java", "-Xms1024M", "-Xmx1024M", "-jar", "server.jar", "nogui"], start_new_session=True, cwd=os.getcwd())
        else:
            print("Minecraft server already running")
    else:
        if server_proc != None:
            print("Minecraft server getting killed")
            server_proc.kill()
        else:
            print("Minecraft server already down")

now = datetime.datetime.now()
if now.hour == 5 and now.minute < 10:
    ensure_server_running(False)
    update_server()
else:
    ensure_server_running(True)
