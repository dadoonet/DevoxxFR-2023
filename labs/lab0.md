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
```

Or get the latest version of FSCrawler (java 11+ required) from <https://s01.oss.sonatype.org/content/repositories/snapshots/fr/pilato/elasticsearch/crawler/fscrawler-distribution/2.10-SNAPSHOT/>.

[Next step](lab1.md).
