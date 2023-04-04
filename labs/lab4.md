# Lab 4: Ingest Inference Processor

Useful links:

* <https://www.elastic.co/guide/en/elasticsearch/reference/current/inference-processor.html>
* <https://www.elastic.co/guide/en/machine-learning/master/ml-nlp.html>
* <https://www.elastic.co/guide/en/machine-learning/master/ml-nlp-ner-example.html>
* <https://www.elastic.co/guide/en/machine-learning/master/ml-nlp-text-emb-vector-search-example.html>

For both use cases,
- You need to clone the Eland repository then create a Docker image of Eland

   ```
    git clone git@github.com:elastic/eland.git
    cd eland 
    docker build -t elastic/eland . 
    ```
    
- Install the model by running the `eland_import_model_hub` command in the Docker image:

```
docker run -it --rm elastic/eland \
    eland_import_hub_model \
      --cloud-id $CLOUD_ID \
      -u elastic -p <password> \
      --hub-model-id <MODEL-ID> \
      --task-type ner \
      --start
   ```
 
## Use case 1: Named Entity Recognition (NER) Model
### Steps
- Deploy a named entity recognition (NER) model in Elasticsearch
- Test the deployed model
- Add the model to your inference ingest pipeline

## Use case 2: Text Embedding Model & Semantic Search
You can use any Text Embedding Model from the [third-party model reference list](https://www.elastic.co/guide/en/machine-learning/master/ml-nlp-model-ref.html#ml-nlp-model-ref-ner).

### Steps
- Deploy a text embedding model in Elasticsearch
- Test the deployed model
- Add the model to your inference ingest pipeline

[Next step](lab5.md).
