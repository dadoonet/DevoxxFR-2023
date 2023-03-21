# Soluces for Lab 6

Edit the job:

```yml
---
name: "devoxx"
fs:
  url: "/tmp/es"
elasticsearch:
  nodes:
  - url: "https://SERVICE.es.REGION.PROVIDER.cloud.es.io"
  username: "elastic"
  password: "PASSWORD"
workplace_search:
  server: "https://SERVICE.ent.REGION.PROVIDER.cloud.es.io"
```

Restart FSCrawler from scratch:

```sh
docker run -it --rm -v "`pwd`"/config:/root/.fscrawler -v "`pwd`"/files:/tmp/es:ro dadoonet/fscrawler fscrawler devoxx --debug --restart
```

To expose it, you can start a local HTTP Server:

```sh
docker run -d -v "`pwd`"/files:/var/www:ro -p 8080:8080 trinitronx/python-simplehttpserver
```

Or:

```sh
cd files; python3 -m http.server --cgi 8080
```

Change the document URL so it will be served using `http://localhost:8080` instead of `http://localhost` and reindex.

```yaml
---
name: "devoxx"
fs:
  url: "/tmp/es"
elasticsearch:
  nodes:
  - url: "https://SERVICE.es.REGION.PROVIDER.cloud.es.io"
  username: "elastic"
  password: "PASSWORD"
workplace_search:
  server: "https://SERVICE.ent.REGION.PROVIDER.cloud.es.io"
  url_prefix: "http://localhost:8080"
```
