import os

def get_music_files(directory):
    """Recursively scan the directory for music files."""
    music_extensions = ('.flac', '.mp3', '.m4a', '.ogg')
    music_files = []

    for root, _, files in os.walk(directory):
        for file in files:
            if file.lower().endswith(music_extensions):
                # Store the full path and the relative path (for M3U generation)
                full_path = os.path.join(root, file)
                relative_path = os.path.relpath(full_path, directory)
                music_files.append((full_path, relative_path))

    return music_files

def get_user_root_path(user):
    """Return the root path based on the selected user."""
    user_paths = {
        "Derrik": "/music/",
        "Nicole": "/music/nicole_music/",
        "Elizabeth": "/music/elizabeth_music/"
    }
    return user_paths.get(user, "/music/")

def generate_m3u(directory, user, subfolder, output_file="playlist.m3u"):
    """Generate an M3U playlist file with server-side paths."""
    music_files = get_music_files(directory)
    root_path = get_user_root_path(user)

    with open(output_file, "w", encoding="utf-8") as f:
        f.write("#EXTM3U\n")
        f.write(f"#PLAYLIST:{os.path.splitext(output_file)[0]}\n")

        for full_path, relative_path in music_files:
            duration = 0  # Placeholder for duration (use a library like mutagen to get actual duration)
            f.write(f"#EXTINF:{duration},{os.path.splitext(os.path.basename(full_path))[0]}\n")
            # Write the server-side path, including the subfolder and relative path
            f.write(f"{root_path}{subfolder}/{relative_path}\n")

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

    # Ask for the subfolder name
    subfolder = input("What is the name of the subfolder for these files? ").strip()
    if not subfolder:
        print("Subfolder name cannot be empty. Exiting.")
        return

    # Generate the M3U playlist
    output_file = input("Enter the output M3U file name (default: playlist.m3u): ").strip() or "playlist.m3u"
    generate_m3u(directory, user, subfolder, output_file)
    print(f"Playlist generated: {output_file}")

if __name__ == "__main__":
    main()
