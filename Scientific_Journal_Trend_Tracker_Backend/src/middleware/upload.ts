import multer from "multer";

// Store the uploaded PDF in memory so the controller can stream the buffer
// straight to Cloudinary (Railway's filesystem is ephemeral, so writing to
// disk loses the file on every redeploy/restart).
const storage = multer.memoryStorage();

const fileFilter = (req: any, file: any, cb: any) => {
  if (file.mimetype === "application/pdf") {
    cb(null, true);
  } else {
    cb(new Error("Only PDF files are allowed!"), false);
  }
};

export const uploadPaperPdf = multer({
  storage: storage,
  fileFilter: fileFilter,
  limits: {
    fileSize: 25 * 1024 * 1024 // 25MB limit
  }
});
