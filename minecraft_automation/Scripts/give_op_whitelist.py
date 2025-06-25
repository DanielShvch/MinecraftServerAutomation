import json
import requests
import os
import sys

# === Format trimmed UUID into full UUID ===
def format_uuid(raw_uuid):
    return f"{raw_uuid[0:8]}-{raw_uuid[8:12]}-{raw_uuid[12:16]}-{raw_uuid[16:20]}-{raw_uuid[20:]}"


# === Fetch UUID from Mojang ===
def fetch_uuid(username):
    response = requests.get(f"https://api.mojang.com/users/profiles/minecraft/{username}")
    if response.status_code == 200:
        return response.json().get("id")
    return None


# === Load or initialize ops.json ===
def load_ops_file(path):
    if not os.path.exists(path):
        return []
    with open(path, "r") as f:
        try:
            return json.load(f)
        except json.JSONDecodeError:
            return []

def load_white_file(path):
    if not os.path.exists(path):
        return []
    with open(path, "r") as f:
        try:
            return json.load(f)
        except json.JSONDecodeError:
            return []

# === Save ops.json ===
def save_ops_file(path, data):
    with open(path, "w") as f:
        json.dump(data, f, indent=4)

def save_whites_file(path, data):
    with open(path, "w") as f:
        json.dump(data, f, indent=4)


# === Main ===
def main():
    if len(sys.argv) != 3:
        print("Usage: python3 add_op.py <world_number> <minecraft_username>")
        sys.exit(1)

    try:
        world_number = int(sys.argv[1])
    except ValueError:
        print("Error: World number must be an integer.")
        sys.exit(1)

    username = sys.argv[2].strip()
    if not username:
        print("Error: Username cannot be empty.")
        sys.exit(1)

    ops_path = f"/worlds/minecraft_{world_number}/ops.json"
    whitelist_path = f"/worlds/minecraft_{world_number}/whitelist.json"
    # Get and format UUID
    uuid_raw = fetch_uuid(username)
    if not uuid_raw:
        print(f"Error: Could not fetch UUID for '{username}'")
        sys.exit(1)

    uuid = format_uuid(uuid_raw)
    print(f"UUID for {username}: {uuid}")

    # Load existing ops.json
    ops = load_ops_file(ops_path)
    whites = load_white_file(whitelist_path)
    # Check for existing entry
    for op in ops:
        if op["uuid"] == uuid:
            print(f"{username} is already an operator.")
            return

    for white in whites:
        if white["uuid"] == uuid:
            print(f"{username} is already whitelisted.")
            return

    # Add new operator entry
    new_op = {
        "uuid": uuid,
        "name": username,
        "level": 4,
        "bypassesPlayerLimit": False
    }

    new_white = {
        "uuid": uuid,
        "name": username
    }

    ops.append(new_op)
    save_ops_file(ops_path, ops)
    whites.append(new_white)
    save_whites_file(whitelist_path, whites)

    print(f"{username} added to ops.json and whitelisted for world {world_number}.")


if __name__ == "__main__":
    main()
