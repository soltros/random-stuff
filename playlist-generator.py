import os

def get_music_files(directory):
    """Scan the directory for music files."""
    music_extensions = ('.flac', '.mp3', '.m4a', '.ogg')
    return [f for f in os.listdir(directory) if f.lower().endswith(music_extensions)]

def get_user_root_path(user):
    """Return the root path based on the selected user."""
    user_paths = {
        "Derrik": "/music/",
        "Nicole": "/music/nicole_music/",
        "Elizabeth": "/music/elizabeth_music/"
    }
    return user_paths.get(user, "/music/")

def generate_m3u(directory, user, output_file="playlist.m3u"):
    """Generate an M3U playlist file."""
    music_files = get_music_files(directory)
    root_path = get_user_root_path(user)

    with open(output_file, "w", encoding="utf-8") as f:
        f.write("#EXTM3U\n")
        f.write(f"#PLAYLIST:{output_file}\n")

        for file in music_files:
            file_path = os.path.join(directory, file)
            duration = 0  # Placeholder for duration (you can use a library like mutagen to get actual duration)
            f.write(f"#EXTINF:{duration},{os.path.splitext(file)[0]}\n")
            f.write(f"{root_path}{file}\n")

def main():
    # Ask for the directory containing music files
    directory = input("Where are your music files stored? ").strip()
    if not os.path.isdir(directory):
        print("Invalid directory. Exiting.")
        return

    # Ask for the user
    user = input("What user is it for? (Derrik, Nicole, Elizabeth): ").strip()
    if user not in ["Derrik", "Nicole", "Elizabeth"]:
        print("Invalid user. Exiting.")
        return

    # Generate the M3U playlist
    output_file = input("Enter the output M3U file name (default: playlist.m3u): ").strip() or "playlist.m3u"
    generate_m3u(directory, user, output_file)
    print(f"Playlist generated: {output_file}")

if __name__ == "__main__":
    main()
