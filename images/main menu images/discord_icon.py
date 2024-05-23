from PIL import Image

# Specify the path to the image file
image_path = "C:/Users/simon/Zomboid/Workshop/The Last of Us Infected - Beta/images/discord_icon.png"

# Open the original image
image = Image.open(image_path)

# Convert the image to RGBA mode
image = image.convert("RGBA")

# Get the data of the image
data = image.getdata()

# Define the replacement color (e.g., red)
replacement_color = (2, 4, 23, 255)  # RGB color with full opacity

# Create a new list to hold the modified pixel data
new_data = []

# Loop through each pixel in the image
for item in data:
    # Change all white (also checking for full opacity) pixels to the replacement color
    if item[:3] == (255, 255, 255):
        new_data.append(replacement_color)
    else:
        new_data.append(item)

# Update image data with the new data
image.putdata(new_data)

# Save or show the modified image
image.save("images/discord_icon.png")
image.show()

