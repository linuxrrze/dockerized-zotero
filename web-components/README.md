# Dockerized-Zotero

## Zotero web-components 

### Building

- You can build the Linux client like this:

    ```bash
    $  docker build -t zotero-web-components .
    $  docker run -v ./build:/build -ti zotero-web-components
    ```

- The build result will be available in "build" and can be server by a standard web server.
