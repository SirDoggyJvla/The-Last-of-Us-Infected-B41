from PIL import Image
import os

# Add your paths to the image, the name of the image and the path where to export the images
image = r'path_to_image'
file = r'your_image.extension'
export = r'path_to_export'

image = r'C:\Users\simon\Zomboid\Workshop\The Last of Us Infected\images\main menu images'
file = r'clicker2_banner.png'
export = r'C:\Users\simon\Zomboid\Workshop\The Last of Us Infected\images\main menu images\test'





image = image.replace("\\", "/")
export = export.replace("\\", "/")
path2image = image + '/' + file

# Open the original image
image = Image.open(path2image)

# Dimensions of the original image
width, height = image.size

# Create export folder if it doesn't exist
os.makedirs(export, exist_ok=True)

# Coordinates for the four corners and corresponding filenames
crops = {
    "Title.png": (0, 0, 960, 1024),
    "Title2.png": (960, 0, 1920, 1024),
    "Title3.png": (0, 1024, 960, 1080),
    "Title4.png": (960, 1024, 1920, 1080)
}

# Crop and save each image
for filename, box in crops.items():
    cropped_image = image.crop(box)
    save_path = os.path.join(export, filename)
    cropped_image.save(save_path)

# Coordinates for the four corners and corresponding filenames
crops = {
    "Title_lightning.png": (0, 0, 960, 1024),
    "Title_lightning2.png": (960, 0, 1920, 1024),
    "Title_lightning3.png": (0, 1024, 960, 1080),
    "Title_lightning4.png": (960, 1024, 1920, 1080)
}

# Crop and save each image
for filename, box in crops.items():
    cropped_image = image.crop(box)
    save_path = os.path.join(export, filename)
    cropped_image.save(save_path)


filename = "Title_lightsoffA.png"
save_path = os.path.join(export, filename)
image.save(save_path)

print("Images have been saved.")

