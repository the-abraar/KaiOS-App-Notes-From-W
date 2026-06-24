import os
from PIL import Image


def process_images():
    """
    Scans the current directory for .jpg, .jpeg, and .webp files.
    Crops them from the center to match 240:320 aspect ratio,
    then resizes them to exactly 240x320 pixels.
    """
    
    # 1. Configuration
    TARGET_WIDTH = 240
    TARGET_HEIGHT = 320
    TARGET_RATIO = TARGET_WIDTH / TARGET_HEIGHT
    
    # Supported extensions
    exts = ('.jpg', '.jpeg', '.webp')

    # 2. Get files in current directory
    files = [f for f in os.listdir('.') if f.lower().endswith(exts)]

    if not files:
        print("No .jpg or .webp files found in this directory.")
        return

    print(f"Found {len(files)} images. Processing...")

    for filename in files:
        try:
            with Image.open(filename) as img:
                # We convert to RGB to handle inconsistencies (like PNGs renamed to JPGs)
                if img.mode in ("RGBA", "P"):
                    img = img.convert("RGB")

                current_w, current_h = img.size
                current_ratio = current_w / current_h

                # 3. Calculate Crop Box
                # If image is 'wider' than target (ratio > 0.75)
                if current_ratio > TARGET_RATIO:
                    # Height matches, calculate new width based on target ratio
                    # New Width = Current Height * 0.75
                    new_width = int(current_h * TARGET_RATIO)
                    new_height = current_h
                    
                    # Calculate center offset
                    offset = (current_w - new_width) // 2
                    box = (offset, 0, offset + new_width, current_h)
                
                # If image is 'taller' than target (ratio < 0.75)
                else:
                    # Width matches, calculate new height
                    # New Height = Current Width / 0.75
                    new_width = current_w
                    new_height = int(current_w / TARGET_RATIO)
                    
                    # Calculate center offset
                    offset = (current_h - new_height) // 2
                    box = (0, offset, current_w, offset + new_height)

                # 4. Perform the Crop
                # box = (left, top, right, bottom)
                img_cropped = img.crop(box)

                # 5. Perform the Resize
                # LANCZOS is a high-quality resampling filter
                img_final = img_cropped.resize((TARGET_WIDTH, TARGET_HEIGHT), Image.Resampling.LANCZOS)

                # 6. Save
                # We add a prefix to prevent destroying original data. 
                # To overwrite, change output_name to just 'filename'
                output_name = f"resized_{filename}"
                
                # If input was webp, save as webp, else jpg
                if filename.lower().endswith(".webp"):
                    img_final.save(output_name, "WEBP", quality=90)
                else:
                    img_final.save(output_name, "JPEG", quality=90)

                print(f"Processed: {filename} -> {output_name}")

        except Exception as e:
            print(f"Error processing {filename}: {e}")


if __name__ == "__main__":
    process_images()