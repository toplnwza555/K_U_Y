from fastapi import FastAPI, File, UploadFile
from fastapi.responses import StreamingResponse
from PIL import Image
from rembg import remove
import io

app = FastAPI()

def fit_and_center(img, size=(350, 425)):
    tw, th = size
    iw, ih = img.size

    # fit รูปให้พอดีกับกรอบ (350x425) โดยไม่ขยายเกิน
    ratio = min(tw / iw, th / ih)
    nw, nh = int(iw * ratio), int(ih * ratio)
    img = img.resize((nw, nh), Image.LANCZOS)

    # สร้างพื้นหลังสีฟ้า
    bg = Image.new("RGBA", (tw, th), (41, 168, 243, 255))

    # วางภาพตรงกลางพื้นหลัง
    x = (tw - nw) // 2
    y = (th - nh) // 2
    bg.paste(img, (x, y), mask=img.split()[3] if img.mode == "RGBA" else None)
    return bg

@app.post("/crop-bg")
async def crop_and_remove_bg(file: UploadFile = File(...)):
    contents = await file.read()
    with Image.open(io.BytesIO(contents)) as input_image:
        no_bg = remove(input_image)
        # fit แล้ววางตรงกลาง
        final_img = fit_and_center(no_bg, (350, 425))
        output_buffer = io.BytesIO()
        final_img.convert("RGB").save(output_buffer, format="PNG")
        output_buffer.seek(0)
        return StreamingResponse(output_buffer, media_type="image/png")
