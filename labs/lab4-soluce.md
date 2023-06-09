# Soluces for Lab 4

## Use case 1: Deploy a Named Entity Recognition (NER) model in Elasticsearch

### UC1 - Deploy the NER Model

* Install the model by running the `eland_import_model_hub` command in the Docker image:

```sh
docker run -it --rm elastic/eland \
    eland_import_hub_model \
      --cloud-id $CLOUD_ID \
      -u elastic -p <password> \
      --hub-model-id elastic/distilbert-base-uncased-finetuned-conll03-english \
      --task-type ner \
      --start
   ```

### UC1 - Test the deployed model

#### UC1 - Using Kibana UI

Deployed models can be evaluated in Kibana under `Machine Learning > Trained Models` by selecting the `Test model` action for the respective model.

#### UC1 - Using `_infer` API

```json
POST _ml/trained_models/elastic__distilbert-base-uncased-finetuned-conll03-english/_infer
{
  "docs": [
    {
      "text_field": "Elastic is headquartered in Mountain View, California."
    }
  ]
}
```

Output:

```json
{
"inference_results": [
  {
    "predicted_value": "[Elastic](ORG&Elastic) is headquartered in [Mountain View](LOC&Mountain+View), [California](LOC&California).",
    "entities": [
      {
        "entity": "elastic",
        "class_name": "ORG",
        "class_probability": 0.9958921231805256,
        "start_pos": 0,
        "end_pos": 7
      },
      {
        "entity": "mountain view",
        "class_name": "LOC",
        "class_probability": 0.9844731508992688,
        "start_pos": 28,
        "end_pos": 41
      },
      {
        "entity": "california",
        "class_name": "LOC",
        "class_probability": 0.9972361009811214,
        "start_pos": 43,
        "end_pos": 53
      }
    ]
  }
]
}
```

### UC1 - Load data

You can perform bulk inference on documents as they are ingested by using an inference processor in your ingest pipeline. The novel Les Misérables by Victor Hugo is used as an example for inference in the following example. [Download](https://github.com/elastic/stack-docs/blob/8.5/docs/en/stack/ml/nlp/data/les-miserables-nd.json) the novel text split by paragraph as a JSON file, then upload it by using the [Data Visualizer](https://www.elastic.co/guide/en/kibana/master/connect-to-elasticsearch.html#upload-data-kibana). Give the new index the name `les-miserables` when uploading the file.

### UC1 - Add the model to your inference ingest pipeline

Now, you can create an ingest pipeline either in the `Stack management UI` or by using the `API`:

* Create pipeline:

```json
PUT _ingest/pipeline/ner
{
  "description": "NER pipeline",
  "processors": [
    {
      "inference": {
        "model_id": "elastic__distilbert-base-uncased-finetuned-conll03-english",
        "target_field": "ml.ner",
        "field_map": {
          "paragraph": "text_field"
        }
      }
    },
    {
      "script": {
        "lang": "painless",
        "if": "return ctx['ml']['ner'].containsKey('entities')",
        "source": "Map tags = new HashMap(); for (item in ctx['ml']['ner']['entities']) { if (!tags.containsKey(item.class_name)) tags[item.class_name] = new HashSet(); tags[item.class_name].add(item.entity);} ctx['tags'] = tags;"
      }
    }
  ],
  "on_failure": [
    {
      "set": {
        "description": "Index document to 'failed-<index>'",
        "field": "_index",
        "value": "failed-{{{ _index }}}"
      }
    },
    {
      "set": {
        "description": "Set error message",
        "field": "ingest.failure",
        "value": "{{_ingest.on_failure_message}}"
      }
    }
  ]
}
```

* Ingest some text:

```json
POST _reindex
{
  "source": {
    "index": "les-miserables"
  },
  "dest": {
    "index": "les-miserables-infer",
    "pipeline": "ner"
  }
}
```

* Take a random paragraph from the source document as an example:

```json
{
  "paragraph": "Father Gillenormand did not do it intentionally, but inattention to proper names was an aristocratic habit of his.",
  "line": 12700
}
```

* After the text is ingested through the NER pipeline, find the resulting document stored in Elasticsearch:

```json
GET /les-miserables-infer/_search
{
  "query": {
    "term": {
      "line": 12700
    }
  }
}
```

* The request returns the document marked up with one identified person:

```json
(...)
"paragraph": "Father Gillenormand did not do it intentionally, but inattention to proper names was an aristocratic habit of his.",
  "@timestamp": "2020-01-01T17:38:25.000+01:00",
  "line": 12700,
  "ml": {
    "ner": {
      "predicted_value": "Father [Gillenormand](PER&Gillenormand) did not do it intentionally, but inattention to proper names was an aristocratic habit of his.",
      "entities": [
        {
          "entity": "gillenormand",
          "class_name": "PER",
          "class_probability": 0.9452480789333386,
          "start_pos": 7,
          "end_pos": 19
        }
      ],
      "model_id": "elastic__distilbert-base-uncased-finetuned-conll03-english"
    }
  },
  "tags": {
    "PER": [
      "gillenormand"
    ]
  }
(...)
```

## Use case 2: Deploy a Text Embedding Model and use it for Semantic Search

### Deploy the Text Embedding Model

* Install the model by running the `eland_import_model_hub` command in the Docker image:

```sh
docker run -it --rm elastic/eland \
eland_import_hub_model \
  --cloud-id $CLOUD_ID \
  -u elastic -p <password> \
  --hub-model-id sentence-transformers/msmarco-MiniLM-L-12-v3 \
  --task-type text_embedding \
  --start
```

### UC2 - Test the deployed model

#### UC2 - Using Kibana UI

Deployed models can be evaluated in Kibana under `Machine Learning > Trained Models` by selecting the `Test model` action for the respective model.

#### UC2 - Using `_infer` API

```json
POST /_ml/trained_models/sentence-transformers__msmarco-minilm-l-12-v3/_infer
{
  "docs": {
    "text_field": "Welcome to Devoxx France 2023"
  }
}
```

Output:

```json
{
  "inference_results": [
  {
    "predicted_value": "Welcome to [Devoxx](ORG&Devoxx) [France](LOC&France) 2023",
    "entities": [
      {
        "entity": "devoxx",
        "class_name": "ORG",
        "class_probability": 0.9895829581741271,
        "start_pos": 11,
        "end_pos": 17
      },
      {
        "entity": "france",
        "class_name": "LOC",
        "class_probability": 0.8396867351261772,
        "start_pos": 18,
        "end_pos": 24
      }
    ]
  }
  ]
}
```

### UC2 - Load data

In this example, we use a subset of the MS MACRO Passage Ranking data set used in the testing stage of the 2019 TREC Deep Learning Track. You can upload the [data set](https://github.com/elastic/stack-docs/blob/8.5/docs/en/stack/ml/nlp/data/msmarco-passagetest2019-unique.tsv) using the [Data Visualizer](https://www.elastic.co/guide/en/kibana/master/connect-to-elasticsearch.html#upload-data-kibana).
Name the first column `id` and the second one `text`. The index name is `collection`. After the upload is done, you can see an index named `collection` with 182469 documents.

### UC2 - Add the model to your inference ingest pipeline

1 - In Kibana, you can create and edit pipelines in `Stack Management > Ingest Pipelines`.

* Click `Create pipeline` or edit an existing pipeline.
* Add an inference processor to your pipeline:
  * Click `Add a processor` and select the Inference processor type.
  * Set `Model ID` to the name of your trained model, for example `elastic__distilbert-base-cased-finetuned-conll03-english` or `lang_ident_model_1`.
  * Click Add to save the processor.
* To test the pipeline, click `Add documents`.

```json
[
  {
    "_source": {
    "text_field":"How is the weather in Jamaica?"
    }
  }
 ]
```

* Click `Run` the pipeline and verify the pipeline worked as expected.
* If everything looks correct, close the panel, and click `Create pipeline`. The pipeline is now ready for use.

2 - Using API

```json
PUT _ingest/pipeline/text-embeddings
{
  "description": "Text embedding pipeline",
  "processors": [
    {
      "inference": {
        "model_id": "sentence-transformers__msmarco-minilm-l-12-v3",
        "target_field": "text_embedding",
        "field_map": {
          "text": "text_field"
        }
      }
    }
  ],
  "on_failure": [
    {
      "set": {
        "description": "Index document to 'failed-<index>'",
        "field": "_index",
        "value": "failed-{{{_index}}}"
      }
    },
    {
      "set": {
        "description": "Set error message",
        "field": "ingest.failure",
        "value": "{{_ingest.on_failure_message}}"
      }
    }
  ]
}
```

* Before ingesting the data through the pipeline, create the mappings of the destination index, in particular for the field `text_embedding.predicted_value` where the ingest processor stores the embeddings.

```json
PUT collection-with-embeddings
{
  "mappings": {
    "properties": {
      "text_embedding.predicted_value": {
        "type": "dense_vector",
        "dims": 384,
        "index": true,
        "similarity": "cosine"
      },
      "text": {
        "type": "text"
      }
    }
  }
}
```

* Create the text embeddings by reindexing the data to the `collection-with-embeddings` index through the inference pipeline.

```json
POST _reindex?wait_for_completion=false
{
  "source": {
    "index": "collection"
  },
  "dest": {
    "index": "collection-with-embeddings",
    "pipeline": "text-embeddings"
  }
}
```

After the reindexing is finished, the documents in the new index contain the inference results – the vector embeddings.

### UC2 - Semantic search

After the dataset has been enriched with vector embeddings, you can query the data using semantic search.

```json
GET collection-with-embeddings/_search
{
  "knn": {
    "field": "text_embedding.predicted_value",
    "query_vector_builder": {
      "text_embedding": {
        "model_id": "sentence-transformers__msmarco-minilm-l-12-v3",
        "model_text": "How is the weather in Jamaica?"
      }
    },
    "k": 10,
    "num_candidates": 100
  },
  "_source": [
    "id",
    "text"
  ]
}
```

As a result, you receive the top 10 documents that are closest in meaning to the query from the `collection-with-embedings` index sorted by their proximity to the query:

```json
"hits" : [
      {
        "_index" : "collection-with-embeddings",
        "_id" : "47TPtn8BjSkJO8zzKq_o",
        "_score" : 0.94591534,
        "_source" : {
          "id" : 434125,
          "text" : "The climate in Jamaica is tropical and humid with warm to hot temperatures all year round. The average temperature in Jamaica is between 80 and 90 degrees Fahrenheit. Jamaican nights are considerably cooler than the days, and the mountain areas are cooler than the lower land throughout the year. Continue Reading."
        }
      },
      {
        "_index" : "collection-with-embeddings",
        "_id" : "3LTPtn8BjSkJO8zzKJO1",
        "_score" : 0.94536424,
        "_source" : {
          "id" : 4498474,
          "text" : "The climate in Jamaica is tropical and humid with warm to hot temperatures all year round. The average temperature in Jamaica is between 80 and 90 degrees Fahrenheit. Jamaican nights are considerably cooler than the days, and the mountain areas are cooler than the lower land throughout the year"
        }
      },
      {
        "_index" : "collection-with-embeddings",
        "_id" : "KrXPtn8BjSkJO8zzPbDW",
        "_score" :  0.9432083,
        "_source" : {
          "id" : 190804,
          "text" : "Quick Answer. The climate in Jamaica is tropical and humid with warm to hot temperatures all year round. The average temperature in Jamaica is between 80 and 90 degrees Fahrenheit. Jamaican nights are considerably cooler than the days, and the mountain areas are cooler than the lower land throughout the year. Continue Reading"
        }
      },
      (...)
]
```
