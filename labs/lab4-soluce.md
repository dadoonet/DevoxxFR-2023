# Soluces for Lab 4


## Prerequisite:
If you have done these steps before, you can skip this section.
- Adding a Machine Learning instance to your deplyment
- This instance should be at least 16 GB RAM and 8 vCPU
- Note: you can always edit your deployment to add more capacity to your cluster.
- For both use cases, you need to clone the Eland repository then create a Docker image of Eland

   ```
    git clone git@github.com:elastic/eland.git
    cd eland 
    docker build -t elastic/eland . 
    ```

## Use case 1: Deploy a Named Entity Recognition (NER) model in Elasticsearch
### Deploy the NER Model
- Install the model by running the `eland_import_model_hub` command in the Docker image:

```
docker run -it --rm elastic/eland \
    eland_import_hub_model \
      --cloud-id $CLOUD_ID \
      -u elastic -p <password> \
      --hub-model-id elastic/distilbert-base-uncased-finetuned-conll03-english \
      --task-type ner \
      --start
   ```

### Test the deployed model
- Using Kibana UI
Deployed models can be evaluated in Kibana under` Machine Learning > Trained Models` by selecting the `Test model` action for the respective model.

- Using `_infer` API
 ```
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
 ```
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

### Add the model to your inference ingest pipeline
You can create an ingest pipeline either in the `Stack management UI` or by using the `API`:
- Create pipeline:
```
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
 
 - Ingest some text:
 ```
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

 - Take a random paragraph from the source document as an example:
 ```
 {
    "paragraph": "Father Gillenormand did not do it intentionally, but inattention to proper names was an aristocratic habit of his.",
    "line": 12700
}
```

 - After the text is ingested through the NER pipeline, find the resulting document stored in Elasticsearch:
 ```
 GET /les-miserables-infer/_search
{
  "query": {
    "term": {
      "line": 12700
    }
  }
}
```

 - The request returns the document marked up with one identified person:
```
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
- Install the model by running the `eland_import_model_hub` command in the Docker image:

   ```
    docker run -it --rm elastic/eland \
    eland_import_hub_model \
      --cloud-id $CLOUD_ID \
      -u elastic -p <password> \
      --hub-model-id sentence-transformers/msmarco-MiniLM-L-12-v3 \
      --task-type text_embedding \
      --start
    ```
### Test the deployed model
- Using Kibana UI
Deployed models can be evaluated in Kibana under` Machine Learning > Trained Models` by selecting the `Test model` action for the respective model.

- Using `_infer` API
 ```
 POST /_ml/trained_models/sentence-transformers__msmarco-minilm-l-12-v3/_infer
{
  "docs": {
    "text_field": "Welcome to Devoxx France 2023"
  }
}
 ```
 
 Output: 
 
  ```
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
### Add the model to your inference ingest pipeline
- In Kibana, you can create and edit pipelines in `Stack Management > Ingest Pipelines`.
  - Click `Create pipeline` or edit an existing pipeline.
  - Add an inference processor to your pipeline:
   - Click `Add a processor` and select the Inference processor type.
   - Set `Model ID` to the name of your trained model, for example `elastic__distilbert-base-cased-finetuned-conll03-english` or `lang_ident_model_1`.
   - Click Add to save the processor.
  - To test the pipeline, click `Add documents`.
```
  [
  {
    "_source": {
    "text_field":"Hello, my name is Maha and I live in Grenoble."
    }
  }
 ]
 ```
  - Click `Run` the pipeline and verify the pipeline worked as expected.
  - If everything looks correct, close the panel, and click `Create pipeline`. The pipeline is now ready for use.
