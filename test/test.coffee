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


	it 'PUT /rt/id/TestBucket/id123?score=100&tags=["tag1","tag2","all"] should return 200 and true', (done) ->
		http.request().put('/rt/id/TestBucket/id123?score=100&tags=["tag1","tag2","all"]').end (resp) ->
			resp.statusCode.should.equal(200)
			resp.body.should.equal("true")
			done()
			return
		return
	

	it 'DELETE /rt/id/TestBucket/id123 should return 200 ', (done) ->
		http.request().delete('/rt/id/TestBucket/id123').expect(200,done)
		return
	




	return