# Dockerized-Zotero

## Zotero web-library 

### Building

- You can build the Linux client like this:

    ```bash
    $  docker build -t zotero-web-library .
    $  docker run -v ./patches:/patches -v ./html:/html -v ${PWD}/../webroot:/build zotero-web-library
    ```

- The build result will be available in "build" and can be server by a standard web server.
