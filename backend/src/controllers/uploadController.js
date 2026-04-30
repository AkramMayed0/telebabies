const sharp  = require('sharp');
const crypto = require('crypto');
const supabase = require('../config/supabase');

const BUCKET  = 'products';
const MAX_DIM = 1200;        // px — longest edge
const QUALITY = 82;          // WebP quality

const uploadImage = async (req, res) => {
  if (!req.file) {
    return res.status(400).json({ error: 'No image file provided' });
  }

  // compress with sharp → WebP
  let compressed;
  try {
    compressed = await sharp(req.file.buffer)
      .rotate()                          // auto-orient from EXIF
      .resize(MAX_DIM, MAX_DIM, {
        fit:        'inside',
        withoutEnlargement: true,
      })
      .webp({ quality: QUALITY })
      .toBuffer();
  } catch {
    return res.status(422).json({ error: 'Could not process image' });
  }

  const filename = `${Date.now()}-${crypto.randomBytes(6).toString('hex')}.webp`;
  const path     = `uploads/${filename}`;

  const { error: uploadError } = await supabase.storage
    .from(BUCKET)
    .upload(path, compressed, {
      contentType:  'image/webp',
      cacheControl: '3600',
      upsert:       false,
    });

  if (uploadError) {
    return res.status(500).json({ error: uploadError.message });
  }

  const { data } = supabase.storage.from(BUCKET).getPublicUrl(path);

  const meta = await sharp(compressed).metadata();

  res.status(201).json({
    url:    data.publicUrl,
    path,
    size_kb: Math.round(compressed.length / 1024),
    width:  meta.width,
    height: meta.height,
  });
};

module.exports = { uploadImage };
