const axios = require('axios');

async function test() {
  try {
    const payload = {
      "_id": "https://openalex.org/W1234567890",
      "title": "Test Frontend Payload Paper",
      "abstract": "Test abstract",
      "doi": null,
      "url": "https://doi.org/10.1234/test",
      "publicationYear": 2026,
      "citationCount": 42,
      "externalId_openalexId": "https://openalex.org/W1234567890",
      "source": "Test Source",
      "authors": [
        {
          "_id": null,
          "fullName": "Frontend Author",
          "externalAuthorId": null,
          "affiliation": null
        }
      ],
      "journalId": null,
      "keywords": null,
      "topics": null,
      "createdAt": null,
      "updatedAt": null
    };

    console.log("Sending payload:", JSON.stringify(payload, null, 2));
    
    // We need a valid token to bypass auth. I'll use the user's token from the request
    const token = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOiI2YTM1ZmJiOWNmOWRhYTRiZDdiZTg2MDIiLCJlbWFpbCI6InRlc3RAZ21haWwuY29tIiwicm9sZSI6InJlc2VhcmNoZXIiLCJpYXQiOjE3ODI0NjQzNzIsImV4cCI6MTc4MzA2OTE3Mn0.MOjaYsDr_sNzy8yMzEtRtoGpgUMDXcD4SKWz6HC2MAc";
    
    const response = await axios.post('http://localhost:5000/api/papers/import', payload, {
      headers: { Authorization: `Bearer ${token}` }
    });
    console.log("Response:", response.status, response.data);
  } catch (error) {
    if (error.response) {
      console.log("API Error:", error.response.status, error.response.data);
    } else {
      console.log("Error:", error.message);
    }
  }
}
test();
