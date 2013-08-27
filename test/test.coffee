_ = require "underscore"
should = require "should"
async = require "async"
app = require "../app"
http = require "../test/support/http"

#
describe 'REST-Sessions Test', ->

	before (done) ->
		http.createServer(app,done)
		return

	after (done) ->
		done()		
		return

	it 'PUT /rt/id/TestBucket/id123?score=100 should return 200', (done) ->
		http.request().put('/rt/id/TestBucket/id123?score=100').end (resp) ->
			resp.statusCode.should.equal(200)
			console.log resp.body
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

	it 'GET /rt/tags/TestBucket?tags=["all"]', (done) ->
		http.request().get('/rt/tags/TestBucket?tags=["all"]').end (resp) ->
			resp.statusCode.should.equal(200)
			result = JSON.parse(resp.body)
			result.total_items.should.equal(1)
			result.items[0].should.equal("id123")
			done()
			return
		return
	

	it 'DELETE /rt/id/TestBucket/id123 should return 200 ', (done) ->
		http.request().delete('/rt/id/TestBucket/id123').expect(200,done)
		return
	




	return