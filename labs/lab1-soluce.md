# Soluces for Lab 1

```json
# Index a first document
PUT /devoxxfr/_doc/1
{
  "message": "Welcome to Devoxx France 2013"
}
# Check that the document has been correctly indexed
GET /devoxxfr/_doc/1

# Update the document
PUT /devoxxfr/_doc/1
{
  "message": "Welcome to Devoxx France 2013",
  "session": "2023-04-12"
}
# Check that the document has been correctly updated
GET /devoxxfr/_doc/1

# Remove the document
DELETE /devoxxfr/_doc/1
# Check that the document has been correctly removed
GET /devoxxfr/_doc/1

# Create a new document
PUT /devoxxfr/_doc/2
{
  "message": "Welcome to Devoxx France 2013",
  "session": "Un moteur de recherche de documents d'entreprise"
}

# Get the mapping
GET /devoxxfr/_mapping

# Change the mapping to use `text` for both `message` and `session` fields
DELETE /devoxxfr
PUT /devoxxfr
{
  "mappings": {
    "properties": {
      "message": {
        "type": "text"
      },
      "session": {
        "type": "text"
      }
    }
  }
}

# Reindex doc 1
PUT /devoxxfr/_doc/1
{
  "message": "Welcome to Devoxx France 2013",
  "session": "2023-04-12"
}
# Then doc 2
PUT /devoxxfr/_doc/2
{
  "message": "Welcome to Devoxx France 2013",
  "session": "Un moteur de recherche de documents d'entreprise"
}

# Search for documents where `message` has `"Devoxx"`.
GET /devoxxfr/_search
{
  "query": {
    "match": {
      "message": "Devoxx"
    }
  }
}

# Search for documents where `message` has `"Devoxx"` or `session` has `recherche`, the more terms, the better.
GET /devoxxfr/_search
{
  "query": {
    "bool": {
      "should": [
        {
          "match": {
            "message": "Devoxx"
          }
        },        {
          "match": {
            "session": "recherche"
          }
        }
      ]
    }
  }
}
```
