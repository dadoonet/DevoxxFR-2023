# Soluces for Lab 2

```json
# Simulate the pipeline for our document
POST _ingest/pipeline/_simulate
{
  "pipeline": {
    "processors": [
      {
        "dissect": {
          "field": "content",
          "pattern": "%{message}|%{session}|%{date}|%{note}"
        }
      },
      {
        "remove": {
          "field": "content"
        }
      },
      {
        "date": {
          "field": "date",
          "formats": ["yyyy-MM-dd"],
          "target_field": "date"
        }
      },
      {
        "convert": {
          "field": "note",
          "type": "float"
        }
      }
    ]
  },
  "docs": [
    {
      "_source": {
        "content": "Welcome to Devoxx France 2013|Un moteur de recherche de documents d'entreprise|2023-04-12|4.5"
      }
    }
  ]
}

# Once the pipeline is working, store it as `devoxxpipeline`.
PUT _ingest/pipeline/devoxxpipeline
{
  "processors": [
    {
      "dissect": {
        "field": "content",
        "pattern": "%{message}|%{session}|%{date}|%{note}"
      }
    },
    {
      "remove": {
        "field": "content"
      }
    },
    {
      "date": {
        "field": "date",
        "formats": ["YYYY-MM-DD"],
        "target_field": "date"
      }
    },
    {
      "convert": {
        "field": "note",
        "type": "float"
      }
    }
  ]
}

# Then define it as the default pipeline for the index `devoxxfr`.
PUT /devoxxfr/_settings
{
  "index.default_pipeline" : "devoxxpipeline"
}

# Then index the following documents (using the bulk API)
POST /devoxxfr/_bulk
{ "index" : { } }
{ "content" : "Welcome to Devoxx France 2013|Un moteur de recherche de documents d'entreprise|2023-04-12|4.5" }
{ "index" : { } }
{ "content" : "Welcome to Devoxx France 2013|The Developer Portal: Open the Gate to Productivity 🚀|2023-04-13|5.0" }

# Check all documents
GET /devoxxfr/_search
```
