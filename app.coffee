###
Rest-Tagging

The MIT License (MIT)

Copyright © 2013-2016 Patrick Liess, http://www.tcs.de

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the “Software”), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

###
_partial = require "lodash/partial"
cfg = require "./config.json"
RESTPREFIX = cfg.rest_path_prefix

RedisTagging = require "redis-tagging"
bodyParser = require "body-parser"
morgan = require "morgan"
rt = new RedisTagging(cfg.redis)
express = require 'express'
app = express()

app.use(bodyParser.json({limit:60000}))
app.use(morgan('dev'))

_respond = (res, err, resp) ->
	res.header('Content-Type', "application/json")
	res.removeHeader("X-Powered-By")
	if err
		res.status(500).send(err)
		return
	res.send(resp)
	return

# create an item with tags
app.put '/' + RESTPREFIX + '/id/:bucket/:id', (req, res) ->
	tags = JSON.parse(req.query.tags or "[]")
	rt.set {bucket: req.params.bucket, id: req.params.id, score: req.query.score, tags: tags}, _partial(_respond, res)
	return

# delete an id
app.delete '/' + RESTPREFIX + '/id/:bucket/:id', (req, res) ->
	rt.remove req.params, _partial(_respond, res)
	return

# get all tags of an id
app.get '/' + RESTPREFIX + '/id/:bucket/:id', (req, res) ->
	rt.get req.params, _partial(_respond, res)
	return

# get all ids of a bucket
app.get '/' + RESTPREFIX + '/allids/:bucket', (req, res) ->
	rt.allids req.params, _partial(_respond, res)
	return

# tags: the main query. query items for some tags
app.get '/' + RESTPREFIX + '/tags/:bucket', (req, res) ->
	req.query.bucket = req.params.bucket
	req.query.tags = JSON.parse(req.query.tags or "[]")
	rt.tags req.query, _partial(_respond, res)
	return

# top tags
app.get '/' + RESTPREFIX + '/toptags/:bucket/:amount', (req, res) ->
	rt.toptags req.params, _partial(_respond, res)
	return

# buckets
app.get '/' + RESTPREFIX + '/buckets', (req, res) ->
	rt.buckets _partial(_respond, res)
	return

# removebucket
app.delete '/' + RESTPREFIX + '/bucket/:bucket', (req, res) ->
	rt.removebucket req.params, _partial(_respond, res)
	return

module.exports = app
