# REST Tagging

[![Build Status](https://secure.travis-ci.org/smrchy/rest-tagging.png?branch=master)](http://travis-ci.org/smrchy/rest-tagging)

A REST interface for the [Redis-Tagging](https://github.com/smrchy/redis-tagging) module.

Use Redis-Tagging on other platforms (PHP, Ruby, Coldfusion, Python etc.) via this simple REST interface.


## Installation

* Clone this repository
* Run `npm install` to install the dependencies.
* For the test make sure Redis runs locally and run `npm test`
* *Optional:* Modify the default parameters (namespaces and Redis host) in config.json
* Start the server: `npm start`


## Methods

Redis Tagging uses the concept of buckets (you might call them namespaces). This way a single Redis Tagging instance can store ids and tags for multiple applications.
A bucket name must be alphanumeric including `-` and `_` and between 1 and 80 characters in length.  
There is no limit on ids and tags. They could include any character.

### PUT /rt/id/:bucket/:id

Add or update an item. The URL contains the bucket (e.g. 'concerts') and the id for this item.

Parameters (as query parameters):

* tags (String) A JSON string with an array of one or more tags (e.g. ["chicago","rock"])
* score (Number) *optional* Default: 0 This is the sorting criteria for this item


Example:

`PUT /rt/id/concerts/571fc1ba4d?score=20130823&tags=["rock","stadium"]`

Returns:

`true`

### DELETE /rt/id/:bucket/:id

Delete an item and all its tag associations.

Example: `DELETE /rt/id/concerts/12345`

Returns:

`true`

### GET /rt/tags/:bucket?queryparams

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

Example:

`GET /rt/tags/concerts?tags=["Berlin","rock"]&limit=2&offset=4&type=inter`

Returns: 

```json
{
    "total_items":108,
    "items":["8167","25652"],
    "limit":2,
    "offset":4
}
```

The returned data is item no. 5 and 6. The first 4 got skipped (offset=4). You can now do a

```sql
SELECT * FROM Concerts WHERE ID IN (8167,25652) ORDER BY Timestamp DESC
```


### GET /rt/toptags/:bucket/:amount

Get the top *n* tags of a bucket.

Example:

`GET /rt/toptags/concerts/3`

Returns:

```json
{
    "total_items": 18374,
    "items":[
        {"tag":"rock", "count":1720},
        {"tag":"pop", "count":1585},
        {"tag":"New York", "count":720}
    ]
}
```

### GET */rt/id/:bucket/:id*

Get all associated tags for an item. Usually this operation is not needed as you will want to store all tags for an item in you database.

Example:

`GET /rt/id/concerts/12345`

Returns:

```json
[
    "rock",
    "stadium",
    "miami"
]
```

### GET /rt/allids/:bucket

Get all IDs saved in a bucket.

Example:

`GET /rt/allids/concerts`

Returns:

```json
[
    "id123",
    "id456",
    "id789"
]
```

### GET /rt/buckets

List all buckets.
**Note:** This uses redis.keys. Use with care! It will slow down Redis when lots of keys are stored in Redis.

Example:

`GET /rt/buckets`

Returns:

```json
[
    "concerts",
    "vacations",
    "users"
]
```



### DELETE /rt/removebucket/:bucket

Remove a single bucket.

Example:

`DELETE /rt/removebucket/concerts`

Returns:

`true`

