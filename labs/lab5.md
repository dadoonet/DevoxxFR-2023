# Lab 5: FSCrawler

Useful links:

* <https://fscrawler.readthedocs.io/en/latest/>
* <https://fscrawler.readthedocs.io/en/latest/admin/cli-options.html>
* <https://www.elastic.co/guide/en/elasticsearch/reference/current/cat-indices.html>

## Steps

The same commands can be run for both a local version of FSCrawler or the Docker image.

```sh
bin/fscrawler devoxx --config_dir config
```

or

```sh
docker run -it --rm -v "`pwd`"/config:/root/.fscrawler -v "`pwd`"/files:/tmp/es:ro dadoonet/fscrawler fscrawler devoxx
```

Launch FSCrawler for the first time and choose to create a new job.

Edit the job so it:

* uses `files` dir if you are not using Docker (skip this step otherwise)
* uses the right URL for Elasticsearch
* define the username (`elastic`) and the password.

Start again FSCrawler.

Once FSCrawler goes to sleep, stop it with CTRL+C.

Launch it again with in debug mode. You should see that no file is sent to Elasticsearch.
Fix that with the restart option.

Show created indices using the `_cat` command in the dev console.
Also look at the Stack Management / Index Management interface.

Search for "words". Note that this will only work if you used the Docker image or if you have tesseract installed and available in the path.

(optional) Use the UI to create a new App Search experience.

[Next step](lab6.md).
