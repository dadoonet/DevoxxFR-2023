# Lab 2: Ingest Pipelines

Useful links:

* <https://www.elastic.co/guide/en/elasticsearch/reference/current/ingest.html>
* <https://www.elastic.co/guide/en/elasticsearch/reference/current/processors.html>
* <https://www.elastic.co/guide/en/elasticsearch/reference/current/indices-update-settings.html>
* <https://www.elastic.co/guide/en/elasticsearch/reference/current/index-modules.html#dynamic-index-settings>
* <https://www.elastic.co/guide/en/elasticsearch/reference/current/docs-bulk.html>

## Steps

The source document is:

```json
{
  "content": "Welcome to Devoxx France 2023|Un moteur de recherche de documents d'entreprise|2023-04-12|4.5"
}
```

Build/simulate a pipeline which transforms it to:

```json
{
  "message": "Welcome to Devoxx France 2023",
  "session": "Un moteur de recherche de documents d'entreprise",
  "date": "2023-01-02T00:00:00.000Z",
  "note": 4.5
}
```

Hint: one of the most useful processors for text extraction is `dissect`.

Once the pipeline is working, store it as `devoxxpipeline`.

Then define it as the default pipeline for the index `devoxxfr`.

Then index the following documents (using the bulk API):

```json
{ "content" : "Welcome to Devoxx France 2023|Un moteur de recherche de documents d'entreprise|2023-04-12|4.5" }
{ "content" : "Welcome to Devoxx France 2023|The Developer Portal: Open the Gate to Productivity 🚀|2023-04-13|5.0" }
```

[Next step](lab3.md).
