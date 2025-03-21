import os
from mutagen.easyid3 import EasyID3
from mutagen.flac import FLAC
from mutagen.oggvorbis import OggVorbis
from mutagen.mp4 import MP4
from mutagen.id3 import ID3, APIC

def get_audio_files(directory):
    """Scan the directory for audio files."""
    audio_extensions = ('.mp3', '.flac', '.ogg', '.m4a')
    audio_files = []

    for root, _, files in os.walk(directory):
        for file in files:
            if file.lower().endswith(audio_extensions):
                audio_files.append(os.path.join(root, file))

    return audio_files

def get_album_name(file_path):
    """Get the album name from the audio file's metadata."""
    if file_path.lower().endswith('.mp3'):
        audio = EasyID3(file_path)
    elif file_path.lower().endswith('.flac'):
        audio = FLAC(file_path)
    elif file_path.lower().endswith('.ogg'):
        audio = OggVorbis(file_path)
    elif file_path.lower().endswith('.m4a'):
        audio = MP4(file_path)
    else:
        return None

    return audio.get('album', ['Unknown Album'])[0]

def extract_album_art(file_path, album_folder):
    """Extract embedded album art and save it to the album folder."""
    if file_path.lower().endswith('.mp3'):
        try:
            audio = ID3(file_path)
            for tag in audio.getall('APIC'):
                if tag.type == 3:  # Front cover
                    image_data = tag.data
                    image_ext = tag.mime.split('/')[-1]  # Extract image extension (e.g., 'jpeg', 'png')
                    image_path = os.path.join(album_folder, f"cover.{image_ext}")
                    with open(image_path, 'wb') as img_file:
                        img_file.write(image_data)
                    print(f"Extracted album art to {image_path}")
                    return
        except Exception as e:
            print(f"Could not extract album art from {file_path}: {e}")

    elif file_path.lower().endswith('.flac'):
        try:
            audio = FLAC(file_path)
            for picture in audio.pictures:
                if picture.type == 3:  # Front cover
                    image_data = picture.data
                    image_ext = picture.mime.split('/')[-1]
                    image_path = os.path.join(album_folder, f"cover.{image_ext}")
                    with open(image_path, 'wb') as img_file:
                        img_file.write(image_data)
                    print(f"Extracted album art to {image_path}")
                    return
        except Exception as e:
            print(f"Could not extract album art from {file_path}: {e}")

    elif file_path.lower().endswith('.m4a'):
        try:
            audio = MP4(file_path)
            if 'covr' in audio:
                image_data = audio['covr'][0]
                image_ext = 'jpg' if image_data.imageformat == image_data.FORMAT_JPEG else 'png'
                image_path = os.path.join(album_folder, f"cover.{image_ext}")
                with open(image_path, 'wb') as img_file:
                    img_file.write(image_data)
                print(f"Extracted album art to {image_path}")
                return
        except Exception as e:
            print(f"Could not extract album art from {file_path}: {e}")

    print(f"No album art found in {file_path}")

def organize_audio_files(directory):
    """Organize audio files into folders based on their album name."""
    audio_files = get_audio_files(directory)

    for file_path in audio_files:
        album_name = get_album_name(file_path)
        if not album_name:
            print(f"Could not retrieve album name for {file_path}")
            continue

        # Create a folder for the album if it doesn't exist
        album_folder = os.path.join(directory, album_name)
        if not os.path.exists(album_folder):
            os.makedirs(album_folder)

        # Move the file to the album folder
        file_name = os.path.basename(file_path)
        new_file_path = os.path.join(album_folder, file_name)

        if not os.path.exists(new_file_path):
            os.rename(file_path, new_file_path)
            print(f"Moved {file_name} to {album_folder}")
        else:
            print(f"{file_name} already exists in {album_folder}")

        # Extract album art
        extract_album_art(file_path, album_folder)

if __name__ == "__main__":
    directory = input("Enter the directory to scan: ").strip()
    if os.path.isdir(directory):
        organize_audio_files(directory)
    else:
        print("Invalid directory. Please provide a valid directory path.")
