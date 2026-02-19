const express = require('express');
const cors = require('cors');
const multer = require('multer');
const modelEngine = require('./services/modelEngine');

const app = express();
const port = 3000;

// Middleware
app.use(cors());
app.use(express.json());

// File Upload Configuration
const storage = multer.memoryStorage();
const upload = multer({ storage: storage });

// Routes
app.get('/', (req, res) => {
  res.json({ message: "Anaj.ai (Node.js) Boss Model Running" });
});

app.post('/predict', upload.single('file'), async (req, res) => {
  try {
    if (!req.file) {
      return res.status(400).json({ error: "No image file provided" });
    }

    console.log(`Received file: ${req.file.originalname}`);

    // Call Model Engine
    const result = await modelEngine.predict(req.file.buffer);

    res.json(result);
  } catch (error) {
    console.error("Prediction Error:", error);
    res.status(500).json({ error: "Internal Server Error" });
  }
});

app.listen(port, () => {
  console.log(`Boss Model Backend running at http://localhost:${port}`);
});
