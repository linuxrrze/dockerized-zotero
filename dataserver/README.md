# Component: dataserver

The dataserver provides the API for Zotero.

## Zotero Server 

### More information

[github zotero/dataserver](https://github.com/zotero/dataserver)

### Usefull commands

*List user's items*:
```bash
$ curl -H "Zotero-API-Key: ${APIKEY}" http://localhost:8080/users/${USERID}/items
```

In order to get an API key (${APIKEY}) and the user's id (${USERID}) use list-users.sh/list-keys.sh, like:

```bash
$ sudo docker exec -ti zotero-dataserver /list-users.sh
userID  username        role    email
1       admin   normal  admin@zotero.org
```

```bash
$ sudo docker exec -ti zotero-dataserver /list-keys.sh
username        key
admin   s77Cxmzv7lFhT6L88XEYkRUC
admin   k65hHoaXPMmrja0U0RjzoNj2
admin   8AVgb64sEatvhQxNR9CSzdlV
```
