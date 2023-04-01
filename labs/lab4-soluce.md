# Soluces for Lab 4

## Prerequsits:
- Adding a Machine Learning instance to your deplyment
- This instance should be at least 16 GB RAM and 8 vCPU
- Note: you can alwyas edit your deployment to add more capacity to ypur cluster.

## Use case 1: Deploy a Named Entity Recognition (NER) model in Elasticsearch
- 

## Use case 2: Deploy a Text Embedding Model and use it for Semantic Search
### Deploy the Text Embedding Model
- First, you need to clone the Eland repository then create a Docker image of Eland

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
      -u <username> -p <password> \
      --hub-model-id sentence-transformers/msmarco-MiniLM-L-12-v3 \
      --task-type text_embedding \
      --start
    ```
### Test the deployed model
- Using Kibana UI
Deployed models can be evaluated in Kibana under Machine Learning > Trained Models by selecting the Test model action for the respective model.

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
### Add the model to your inference ingest pipeline.
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
