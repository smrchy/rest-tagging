# REST Tagging

[![Build Status](https://secure.travis-ci.org/smrchy/rest-tagging.png?branch=master)](http://travis-ci.org/smrchy/rest-tagging)

A REST interface for the [Redis-Tagging](https://github.com/smrchy/redis-tagging) module.

Use Redis-Tagging on other platforms (PHP, Ruby, Coldfusion, Python etc.) via this simple REST interface.


## Installation

* Clone this repository
* Run `npm install` to install the dependencies.
* For the test make sure Redis runs locally and run `npm test`
* *Optional:* Modify the server port in server.js
* Start the server: `node server.js`


## Methods

### PUT /rt/id/:namespace/:id

Add or update an item. The URL contains the namespace (e.g. 'concerts') and the id for this item.

Parameters (as query parameters):

* tags (String) A JSON string with an array of one or more tags (e.g. ["chicago","rock"])
* score (Number) *optional* Default: 0 This is the sorting criteria for this item


Example:

`PUT /rt/id/concerts/571fc1ba4d?score=20130823&tags=["rock","stadium"]`

Response:

`true`

### DELETE /rt/id/:namespace/:id

Delete an item and all its tag associations.

Example: `DELETE /tagger/id/concerts/12345`

Response:

`true`

### GET /rt/tags/:namespace?queryparams

**The main method.** Return the IDs for one or more tags. When more than one tag is supplied the query can be an intersection (default) or a union.
`type=inter` (default) only those IDs will be returned where all tags match. 
`type=union` all IDs where any tag matches will be returned.

Parameters:

- `tags` (String) a JSON string of one or more tags.
- `type` (String) *optional* Either **inter** (default) or **union**.
- `limit` (Number) *optional* Default: 100.
- `offset` (Number) *optional* Default: 0 The amount of items to skip. Useful for paging thru items.
- `withscores` (Number) *optional* Default: 0 Set this to 1 to also return the scores for each item.
- `order` (String) *optional* Either **asc** or **desc** (default).

Example: `GET /tagger/tags/concerts?tags=["Berlin","rock"]&limit=2&offset=4&type=inter`

Returns: 

    {"total_items":108,
     "items":["8167","25652"],
     "limit":2,
     "offset":4}

The returned data is item no. 5 and 6. The first 4 got skipped (offset=4). You can now do a

`SELECT * FROM Concerts WHERE ID IN (8167,25652) ORDER BY Timestamp DESC`

Important: `redis-tagging` uses Redis Sorted Sets. This is why the order of the items that you supplied with the `score` parameter is maintained. This way you can page thru large result sets without doing huge SQL queries.

Idea: You might consider to use a reverse proxy on this URL so clients can access this data via AJAX. JSONP via standard `callback` URL parameter is supported.

- GET */tagger/toptags/:namespace/:amount*

    Get the top *n* tags for a namespace.

    Example: `GET /tagger/toptags/concerts/3`

    Returns:

        {"total_items": 18374,
         "items":[
            {"tag":"rock", "count":1720},
            {"tag":"pop", "count":1585},
            {"tag":"New York", "count":720}
        ]}

- GET */tagger/id/:namespace/:id*

    Get all associated tags for an item. Usually this operation is not needed as you will want to store all tags for an item in you database.

    Example: `GET /tagger/id/concerts/12345`

- GET */tagger/allids/:namespace*

    Get all IDs saved for a namespace. This is a costly operation that you should only use for scheduled cleanup routines.

    Example: `GET /tagger/allids/concerts`



## TODO

* Error handling
* more tests
