import os
import uuid
from typing import List

def batch_rename_jpgs(directory_path: str):
    """
    Renames all .jpg files in a directory to 1.jpg, 2.jpg... 
    based on their modification date (oldest to newest).
    
    Includes a safety mechanism to prevent overwriting existing files.
    
    Args:
        directory_path (str): The absolute path to the folder.
    """
    
    # 1. Validation: Check if path exists
    if not os.path.exists(directory_path):
        print(f"Error: The directory '{directory_path}' does not exist.")
        return

    # 2. Collection: Get all .jpg files (Case insensitive for MacOS 'JPG' vs 'jpg')
    # We explicitly check for both .jpg and .jpeg
    all_files = os.listdir(directory_path)
    jpg_files = [
        f for f in all_files 
        if f.lower().endswith(('.jpg', '.jpeg')) and not f.startswith('.')
    ]

    if not jpg_files:
        print("No .jpg files found to rename.")
        return

    print(f"Found {len(jpg_files)} images. Sorting by date...")

    # 3. Sorting: Sort by Modification Time (mtime)
    # On MacOS, getmtime reflects when the file content was last modified.
    # We join path + filename so the system finds the file correctly.
    try:
        jpg_files.sort(key=lambda x: os.path.getmtime(os.path.join(directory_path, x)))
    except OSError as e:
        print(f"Critical Error accessing file stats: {e}")
        return

    # 4. Execution - Pass 1: Rename to Temporary Names
    # We do this to prevent naming collisions (e.g., if '1.jpg' already exists but belongs to index 5)
    print("--- Phase 1: Assigning Temporary Names ---")
    temp_files_map = [] # Keeps track of the order

    for filename in jpg_files:
        original_full_path = os.path.join(directory_path, filename)
        
        # Generate a unique random name
        temp_name = f"temp_{uuid.uuid4()}.jpg"
        temp_full_path = os.path.join(directory_path, temp_name)
        
        try:
            os.rename(original_full_path, temp_full_path)
            # Store the new temp path in our list so we remember the sort order
            temp_files_map.append(temp_full_path)
        except OSError as e:
            print(f"Error renaming {filename}: {e}")

    # 5. Execution - Pass 2: Rename to Final Numbered Names
    print("--- Phase 2: Assigning Final Names ---")
    
    for index, temp_path in enumerate(temp_files_map):
        # index starts at 0, so we use index + 1
        new_filename = f"{index + 1}.jpg"
        final_path = os.path.join(directory_path, new_filename)
        
        try:
            os.rename(temp_path, final_path)
            print(f"Renamed: .../{os.path.basename(temp_path)} -> {new_filename}")
        except OSError as e:
            print(f"Error finalizing {new_filename}: {e}")

    print("Success! All operations completed.")



if __name__ == "__main__":
    
    # On Mac, you can drag the folder into the terminal to get the path
    target_folder = "/Users/blackbird/DEV/GitRepos/KaiOS-App-Notes-From-W/img" 
    
    # Safety check to prevent running on an example path
    if os.path.exists(target_folder):
        batch_rename_jpgs(target_folder)
    else:
        print("Please update the 'target_folder' variable in the script code.")