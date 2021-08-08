from PIL import Image, ImageDraw

for i in range(0,470):
    print("working... image number:"+str(i))
    img1 = Image.open(str(i)+".png").convert("RGBA")
    drw1 = ImageDraw.Draw(img1)
    for x in range(64):
        for y in range(64):
            if img1.getpixel((x,y)) == (0,140,255,255):
                drw1.point((x,y),fill=(0,0,0,0))
    img1.save(str(i)+".png")