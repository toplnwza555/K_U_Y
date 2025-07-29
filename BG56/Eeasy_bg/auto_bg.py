import os
from rembg import remove
from PIL import Image

def center_crop_and_resize(img, size):
    # ครอปตรงกลางก่อน แล้ว resize
    target_w, target_h = size
    w, h = img.size
    aspect_target = target_w / target_h
    aspect_img = w / h

    # ตัดส่วนเกินให้ได้อัตราส่วนที่ต้องการ
    if aspect_img > aspect_target:
        # กว้างเกิน — ตัดซ้ายขวา
        new_w = int(h * aspect_target)
        left = (w - new_w) // 2
        img = img.crop((left, 0, left + new_w, h))
    else:
        # สูงเกิน — ตัดบนล่าง
        new_h = int(w / aspect_target)
        top = (h - new_h) // 2
        img = img.crop((0, top, w, top + new_h))
    # Resize ให้พอดีเป๊ะ
    return img.resize((target_w, target_h), Image.LANCZOS)

input_folder = r"E:\Eeasy_bg\input_img"
output_folder = r"E:\Eeasy_bg\bgdone"

if not os.path.exists(output_folder):
    os.makedirs(output_folder)

for fname in os.listdir(input_folder):
    if fname.lower().endswith(('.jpg', '.jpeg', '.png')) and not fname.startswith("output_"):
        inpath = os.path.join(input_folder, fname)
        outname = os.path.splitext(fname)[0] + "_bluebg_crop.png"
        outpath = os.path.join(output_folder, outname)
        if os.path.exists(outpath):
            continue
        with Image.open(inpath) as input_image:
            no_bg = remove(input_image)
            crop_img = center_crop_and_resize(no_bg, (350, 425)) # กำหนดขนาดที่ต้องการ
            blue_bg = Image.new("RGBA", crop_img.size, (41,168,243,255))  # #29A8F3
            blue_bg.paste(crop_img, mask=crop_img.split()[3])
            blue_bg.save(outpath)
        print(f"✅ {fname} → {outname}")
