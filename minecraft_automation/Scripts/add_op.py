# If this looks like it was made with ChatGPT, Its because it was.

import json
import requests
import os
import sys


def fetch_uuid(username):
    response = requests.get(f"https://api.mojang.com/users/profiles/minecraft/{username}")
    if response.status_code == 200:
        return response.json().get("id")
    return None

def load_ops_file(path):
    if not os.path.exists(path):
        return []
    with open(path, "r") as f:
        try:
            return json.load(f)
        except json.JSONDecodeError:
            return []

def save_ops_file(path, data):
    with open(path, "w") as f:
        json.dump(data, f, indent=4)

def main():
    if len(sys.argv) != 3:
        print("Usage: python3 add_op.py <world_number> <minecraft_username>")
        sys.exit(1)

    try:
        world_number = int(sys.argv[1])
    except ValueError:
        print(" World number must be an integer.")
        sys.exit(1)

    username = sys.argv[2].strip()

    ops_path = f"/worlds/minecraft_{world_number}/ops.json"

    uuid = fetch_uuid(username)
    if not uuid:
        print(f" Could not fetch UUID for '{username}'")
        sys.exit(1)

    print(f" UUID for {username} is {uuid}")
    ops = load_ops_file(ops_path)

    for op in ops:
        if op["uuid"] == uuid:
            print(f"{username} is already an operator.")
            return

    new_op = {
        "uuid": uuid,
        "name": username,
        "level": 4,
        "bypassesPlayerLimit": False
    }

    ops.append(new_op)
    save_ops_file(ops_path, ops)

    print(f"[{username} added to ops.json for world {world_number}.")

if __name__ == "__main__":
    main()
