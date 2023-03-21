# Lab 6: Workplace Search

Useful links:

* <https://fscrawler.readthedocs.io/en/latest/admin/fs/wpsearch.html>
* <https://www.elastic.co/guide/en/workplace-search/current/index.html>

## Steps

Modify job so it connects now to Workplace Search.

(optional) Use the UI to connect another data source like your Github repository, your Dropbox...

Open the search interface and search for "words" and open the description.

Click on the file to view it. Note the URL: `http://127.0.0.1/test.png`.
To expose it, you can start a local HTTP Server:

```sh
docker run -d -v "`pwd`"/files:/var/www:ro -p 8080:8080 trinitronx/python-simplehttpserver
```

Or:

```sh
cd files; python3 -m http.server --cgi 8080
```

Change the document URL so it will be served using `http://localhost:8080` instead of `http://localhost` and reindex.

## Bonus

* You can add another source, like Dropbox or whatever. It might require to create some credentials on the source side.
