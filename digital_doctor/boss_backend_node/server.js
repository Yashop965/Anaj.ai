const express = require('express');
const cors = require('cors');
const multer = require('multer');
const modelEngine = require('./services/modelEngine');
const { GoogleGenerativeAI } = require("@google/generative-ai");
require('dotenv').config();

const app = express();
const port = 3000;

const genAI = new GoogleGenerativeAI(process.env.GEMINI_API_KEY || "YOUR_API_KEY_HERE");

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

    const mode = req.body.mode || 'predict';
    const localLabel = req.body.local_label || 'Unknown';
    const crop = req.body.crop || 'Crop';

    console.log(`Received file: ${req.file.originalname}, Mode: ${mode}, Local: ${localLabel}`);

    if (mode === 'report') {
      const apiKey = process.env.GEMINI_API_KEY;
      if (!apiKey || apiKey === "YOUR_API_KEY_HERE") {
        console.error("Gemini API Key missing");
        return res.status(500).json({ error: "Server Configuration Error: API Key Missing" });
      }

      console.log("Generating Real Report with Gemini...");

      try {
        const model = genAI.getGenerativeModel({ model: "gemini-1.5-flash" });

        const prompt = `
            You are an expert Phytopathologist (Plant Doctor). 
            Analyze this image of a ${crop} crop. 
            The local AI model identified it as: "${localLabel}".
            
            1. Verify if the local model is correct. If not, identify the real issue.
            2. Assess severity (Low/Medium/High).
            3. Provide a detailed analysis of symptoms visible in the image.
            4. Provide a 7-day personalized treatment plan (Action Plan).
            5. Generate a conversational audio summary in 'Hinglish' (Hindi + English mixed) suitable for an Indian farmer to listen to.
            
            Return ONLY valid JSON with this structure:
            {
                "type": "detailed_report",
                "title": "Report Title",
                "severity": "High/Medium/Low",
                "ai_insight": "Detailed analysis...",
                "personalized_plan": ["Step 1", "Step 2", ...],
                "audio_summary": "Namaste Kisan bhai... (Hinglish text)"
            }
            `;

        const imagePart = {
          inlineData: {
            data: req.file.buffer.toString("base64"),
            mimeType: req.file.mimetype,
          },
        };

        const result = await model.generateContent([prompt, imagePart]);
        const response = await result.response;
        const text = response.text();

        // Clean Markdown code blocks if present
        const jsonStr = text.replace(/```json/g, "").replace(/```/g, "").trim();
        const jsonResponse = JSON.parse(jsonStr);

        res.json(jsonResponse);

      } catch (error) {
        console.error("Gemini API Error:", error);
        res.status(500).json({ error: "AI Generation Failed" });
      }
      return;
    }

    // Call Model Engine (Standard Fallback)
    const result = await modelEngine.predict(req.file.buffer);

    res.json(result);
  } catch (error) {
    console.error("Prediction Error:", error);
    res.status(500).json({ error: "Internal Server Error" });
  }
});

app.listen(port, '0.0.0.0', () => {
  console.log(`Boss Model Backend running at http://0.0.0.0:${port}`);
  console.log(`To access from phone, use your laptop's IP address (e.g., http://192.168.1.5:${port})`);
});
