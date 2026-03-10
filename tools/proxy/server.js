const express = require('express');
const bodyParser = require('body-parser');
const axios = require('axios');
const cors = require('cors');

const app = express();
app.use(cors());
app.use(bodyParser.json({ limit: '10mb' }));

const PORT = process.env.PORT || 8080;
const AI_API_KEY = process.env.DEEPSEEK_API_KEY || process.env.OPENAI_API_KEY;
const AI_API_URL = process.env.DEEPSEEK_API_URL || 'https://api.openai.com/v1/chat/completions';
const MODEL = process.env.AI_MODEL || 'gpt-4o-mini';

if (!AI_API_KEY) {
  console.warn('Warning: No DEEPSEEK_API_KEY / OPENAI_API_KEY provided in environment. Requests will fail.');
}

app.post('/ask', async (req, res) => {
  const { question, category } = req.body || {};
  if (!question) return res.status(400).json({ error: 'Missing question' });

  try {
    // Build a simple system prompt.
    let system = 'You are a helpful AI health assistant. Provide safe, general guidance and include a short disclaimer.';
    if (category) {
      system += ` Category: ${category}`;
    }

    const messages = [
      { role: 'system', content: system },
      { role: 'user', content: question }
    ];

    const payload = {
      model: MODEL,
      messages: messages,
      max_tokens: 800
    };

    const r = await axios.post(AI_API_URL, payload, {
      headers: {
        'Authorization': `Bearer ${AI_API_KEY}`,
        'Content-Type': 'application/json'
      }
    });

    // Try to extract text from common OpenAI-style responses
    let text = null;
    if (r.data) {
      if (r.data.choices && r.data.choices[0] && r.data.choices[0].message) {
        text = r.data.choices[0].message.content;
      } else if (r.data.choices && r.data.choices[0] && r.data.choices[0].text) {
        text = r.data.choices[0].text;
      }
    }

    res.json({ text: text || '' });
  } catch (err) {
    console.error('Proxy error', err?.response?.data || err.message || err);
    const status = err?.response?.status || 500;
    const message = err?.response?.data || err.message || 'proxy_error';
    res.status(status).json({ error: message });
  }
});

app.post('/askWithImage', async (req, res) => {
  // Basic support: receive base64 image and a prompt, then forward as text input
  // The server could be extended to call multimodal endpoints if available.
  const { image_b64, mime_type, prompt, category } = req.body || {};
  if (!image_b64) return res.status(400).json({ error: 'Missing image_b64' });

  try {
    let system = 'You are a helpful AI health assistant. Analyze the provided image and give safe, general guidance.';
    if (category) system += ` Category: ${category}`;

    // For simplicity, include a short note that image is attached as base64.
    const userContent = `${prompt || 'Please analyze this image.'}\n\n[Image: base64(${mime_type || 'image'}) length=${image_b64.length}]`;

    const payload = {
      model: MODEL,
      messages: [
        { role: 'system', content: system },
        { role: 'user', content: userContent }
      ],
      max_tokens: 800
    };

    const r = await axios.post(AI_API_URL, payload, {
      headers: {
        'Authorization': `Bearer ${AI_API_KEY}`,
        'Content-Type': 'application/json'
      }
    });

    let text = null;
    if (r.data) {
      if (r.data.choices && r.data.choices[0] && r.data.choices[0].message) {
        text = r.data.choices[0].message.content;
      } else if (r.data.choices && r.data.choices[0] && r.data.choices[0].text) {
        text = r.data.choices[0].text;
      }
    }

    res.json({ text: text || '' });
  } catch (err) {
    console.error('Proxy image error', err?.response?.data || err.message || err);
    const status = err?.response?.status || 500;
    const message = err?.response?.data || err.message || 'proxy_error';
    res.status(status).json({ error: message });
  }
});

app.listen(PORT, () => {
  console.log(`AI proxy listening on port ${PORT}`);
});
