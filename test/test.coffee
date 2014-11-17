_ = require "lodash"
should = require "should"
async = require "async"
app = require "../app"
http = require "../test/support/http"

#
describe 'REST-Tagging Test', ->

	before (done) ->
		http.createServer(app,done)
		return

	after (done) ->
		done()		
		return

	it 'PUT /rt/id/TestBucket/id123?score=100 should return 200', (done) ->
		http.request().put('/rt/id/TestBucket/id123?score=100').end (resp) ->
			resp.statusCode.should.equal(200)
			done()
			return
		return

	it 'PUT /rt/id/TestBucket/id123?score=xyz should return 500', (done) ->
		http.request().put('/rt/id/TestBucket/id123?score=xyz').end (resp) ->
			resp.statusCode.should.equal(500)
			result = JSON.parse(resp.body)
			result.message.should.equal("Invalid score format")
			done()
			return
		return


	it 'PUT /rt/id/TestBucket/id123?score=100&tags=["tag1","tag2","all"] should return 200 and true', (done) ->
		http.request().put('/rt/id/TestBucket/id123?score=100&tags=["tag1","tag2","all"]').end (resp) ->
			resp.statusCode.should.equal(200)
			resp.body.should.equal("true")
			done()
			return
		return

	it 'PUT /rt/id/TestBucket/id456?score=200&tags=["tag3","tag4","all"] should return 200 and true', (done) ->
		http.request().put('/rt/id/TestBucket/id456?score=200&tags=["tag3","tag4","all"]').end (resp) ->
			resp.statusCode.should.equal(200)
			resp.body.should.equal("true")
			done()
			return
		return

	it 'GET /rt/tags/TestBucket?tags=["all"]', (done) ->
		http.request().get('/rt/tags/TestBucket?tags=["all"]').end (resp) ->
			resp.statusCode.should.equal(200)
			result = JSON.parse(resp.body)
			result.total_items.should.equal(2)
			result.items.should.containEql("id123")
			result.items.should.containEql("id456")
			done()
			return
		return

	it 'GET /rt/tags/TestBucket?tags=["tag1"]', (done) ->
		http.request().get('/rt/tags/TestBucket?tags=["tag1"]').end (resp) ->
			resp.statusCode.should.equal(200)
			result = JSON.parse(resp.body)
			result.total_items.should.equal(1)
			result.items.should.containEql("id123")
			done()
			return
		return
	
	it 'GET /rt/tags/TestBucket?tags=["tag3"]', (done) ->
		http.request().get('/rt/tags/TestBucket?tags=["tag3"]').end (resp) ->
			resp.statusCode.should.equal(200)
			result = JSON.parse(resp.body)
			result.total_items.should.equal(1)
			done()
			return
		return

	it 'GET /rt/tags/TestBucket?tags=["tag3","tag1"]', (done) ->
		http.request().get('/rt/tags/TestBucket?tags=["tag3","tag1"]').end (resp) ->
			resp.statusCode.should.equal(200)
			result = JSON.parse(resp.body)
			result.total_items.should.equal(0)
			done()
			return
		return

	it 'GET /rt/tags/TestBucket?tags=["tag3","tag1"]&type=union', (done) ->
		http.request().get('/rt/tags/TestBucket?tags=["tag3","tag1"]&type=union').end (resp) ->
			resp.statusCode.should.equal(200)
			result = JSON.parse(resp.body)
			result.total_items.should.equal(2)
			result.items.should.containEql("id123")
			result.items.should.containEql("id456")
			done()
			return
		return

	it 'GET /rt/tags/TestBucket?tags=["tag3","all"]', (done) ->
		http.request().get('/rt/tags/TestBucket?tags=["tag3","all"]').end (resp) ->
			resp.statusCode.should.equal(200)
			result = JSON.parse(resp.body)
			result.total_items.should.equal(1)
			result.items.should.containEql("id456")
			done()
			return
		return

	it 'GET /rt/toptags/TestBucket/10', (done) ->
		http.request().get('/rt/toptags/TestBucket/10').end (resp) ->
			resp.statusCode.should.equal(200)
			result = JSON.parse(resp.body)
			result.total_items.should.equal(5)
			result.items[0].tag.should.equal("all")
			done()
			return
		return

	it 'GET /rt/id/TestBucket/id123', (done) ->
		http.request().get('/rt/id/TestBucket/id123').end (resp) ->
			resp.statusCode.should.equal(200)
			result = JSON.parse(resp.body)
			result.should.containEql("all")
			result.should.containEql("tag1")
			result.should.containEql("tag2")
			done()
			return
		return

	it 'GET /rt/allids/TestBucket', (done) ->
		http.request().get('/rt/allids/TestBucket').end (resp) ->
			resp.statusCode.should.equal(200)
			result = JSON.parse(resp.body)
			result.should.containEql("id123")
			result.should.containEql("id456")
			done()
			return
		return

	it 'GET /rt/buckets', (done) ->
		http.request().get('/rt/buckets').end (resp) ->
			resp.statusCode.should.equal(200)
			result = JSON.parse(resp.body)
			result.should.containEql("TestBucket")
			done()
			return
		return

	it 'DELETE /rt/id/TestBucket/id123 should return 200 ', (done) ->
		http.request().delete('/rt/id/TestBucket/id123').expect(200,done)
		return
	

	it 'DELETE /rt/bucket/TestBucket should return 200 ', (done) ->
		http.request().delete('/rt/bucket/TestBucket').expect(200,done)
		return
	
	



	return