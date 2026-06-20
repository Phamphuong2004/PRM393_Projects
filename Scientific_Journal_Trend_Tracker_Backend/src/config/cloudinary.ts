import { v2 as cloudinary } from "cloudinary";

// Configure Cloudinary from environment variables.
// Either provide CLOUDINARY_URL (cloudinary://key:secret@cloud_name)
// or the three individual values below.
cloudinary.config({
  cloud_name: process.env.CLOUDINARY_CLOUD_NAME,
  api_key: process.env.CLOUDINARY_API_KEY,
  api_secret: process.env.CLOUDINARY_API_SECRET,
  secure: true,
});

export const isCloudinaryConfigured = (): boolean =>
  Boolean(
    process.env.CLOUDINARY_URL ||
      (process.env.CLOUDINARY_CLOUD_NAME &&
        process.env.CLOUDINARY_API_KEY &&
        process.env.CLOUDINARY_API_SECRET),
  );

/**
 * Upload a PDF buffer to Cloudinary and return its secure URL.
 * PDFs are stored as "raw" resources so they are served verbatim.
 */
export const uploadPdfBuffer = (
  buffer: Buffer,
  filename: string,
): Promise<string> => {
  return new Promise((resolve, reject) => {
    const publicId = `${Date.now()}-${Math.round(Math.random() * 1e9)}`;
    const stream = cloudinary.uploader.upload_stream(
      {
        resource_type: "raw",
        folder: "papers",
        public_id: publicId,
        format: "pdf",
        // Keep the original filename available for downloads
        context: `original_filename=${filename}`,
      },
      (error, result) => {
        if (error) return reject(error);
        if (!result) return reject(new Error("Cloudinary upload returned no result"));
        resolve(result.secure_url);
      },
    );
    stream.end(buffer);
  });
};

export default cloudinary;
