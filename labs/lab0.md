# Lab 0: Setup

## Cloud setup

* Create a trial account on <https://cloud.elastic.co/>.
* Create a new cluster:
  * Choose your prefered cloud provider
  * Choose your region
  * Click on Advanced Settings and:
    * Choose 1 zone
    * Remove the Integration Server
* Store the password somewhere: `XYZ`
* And wait...

## FSCrawler setup

Get the FSCrawler docker image:

```sh
docker pull dadoonet/fscrawler
docker pull trinitronx/python-simplehttpserver
```

Or get the latest version of FSCrawler (java 11+ required) from <https://s01.oss.sonatype.org/content/repositories/snapshots/fr/pilato/elasticsearch/crawler/fscrawler-distribution/2.10-SNAPSHOT/>.

## Ingest Inference Processor Prerequisite:
- Adding a Machine Learning instance to your deployment
- This instance should be at least 16 GB RAM and 8 vCPU
- Note: you can always edit your deployment to add more capacity to your cluster.
- For both use cases, you need to clone the Eland repository then create a Docker image of Eland

   ```
    git clone git@github.com:elastic/eland.git
    cd eland 
    docker build -t elastic/eland . 
    ```


[Next step](lab1.md).
