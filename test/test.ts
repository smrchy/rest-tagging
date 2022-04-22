import app from "../index";
import "mocha";
import chai from "chai";
import chaiHttp from "chai-http";
chai.use(chaiHttp);
chai.should();

let requester: ChaiHttp.Agent;

before(() => {
	requester = chai.request(app).keepOpen();
});

after(() => {
	requester.close();
});

describe("REST-Tagging Test", () => {
	it("ping", async () => {
		const resp = await requester.get("/ping");
		resp.body.result.should.equal("pong");
	});

	it("PUT /rt/id/TestBucket/id123?score=100 should return 200", async () => {
		const resp = await requester.put("/rt/id/TestBucket/id123?score=100");
		resp.status.should.equal(200);
	});

	it("PUT /rt/id/TestBucket/id123?score=xyz should return 500", async () => {
		const resp = await requester.put("/rt/id/TestBucket/id123?score=xyz");
		resp.status.should.equal(500);
		resp.body.message.should.equal("Invalid score format");
	});


	it("PUT /rt/id/TestBucket/id123?score=100&tags=[\"tag1\", \"tag2\", \"all\"] should return 200 and true", async () => {
		const resp = await requester.put("/rt/id/TestBucket/id123?score=100&tags=[\"tag1\",\"tag2\",\"all\"]");
		resp.status.should.equal(200);
		resp.body.should.equal(true);
	});

	it("PUT /rt/id/TestBucket/id456?score=200&tags=[\"tag3\", \"tag4\", \"all\"] should return 200 and true", async () => {
		const resp = await requester.put("/rt/id/TestBucket/id456?score=200&tags=[\"tag3\", \"tag4\", \"all\"]");
		resp.status.should.equal(200);
		resp.body.should.equal(true);
	});

	it("GET /rt/tags/TestBucket?tags=[\"all\"]", async () => {
		const resp = await requester.get("/rt/tags/TestBucket?tags=[\"all\"]");
		resp.status.should.equal(200);
		resp.body.total_items.should.equal(2);
		resp.body.items.should.contain("id123");
		resp.body.items.should.contain("id456");
	});

	it("GET /rt/tags/TestBucket?tags=[\"tag1\"]", async () => {
		const resp = await requester.get("/rt/tags/TestBucket?tags=[\"tag1\"]");
		resp.status.should.equal(200);

		resp.body.total_items.should.equal(1);
		resp.body.items.should.contain("id123");
	});

	it("GET /rt/tags/TestBucket?tags=[\"tag3\"]", async () => {
		const resp = await requester.get("/rt/tags/TestBucket?tags=[\"tag3\"]");
		resp.status.should.equal(200);

		resp.body.total_items.should.equal(1);
	});

	it("GET /rt/tags/TestBucket?tags=[\"tag3\", \"tag1\"]", async () => {
		const resp = await requester.get("/rt/tags/TestBucket?tags=[\"tag3\", \"tag1\"]");
		resp.status.should.equal(200);

		resp.body.total_items.should.equal(0);
	});

	it("GET /rt/tags/TestBucket?tags=[\"tag3\",\"tag1\"]&type=union", async () => {
		const resp = await requester.get("/rt/tags/TestBucket?tags=[\"tag3\", \"tag1\"]&type=union");
		resp.status.should.equal(200);

		resp.body.total_items.should.equal(2);
		resp.body.items.should.contain("id123");
		resp.body.items.should.contain("id456");
	});

	it("GET /rt/tags/TestBucket?tags=[\"tag3\", \"all\"]", async () => {
		const resp = await requester.get("/rt/tags/TestBucket?tags=[\"tag3\", \"all\"]");
		resp.status.should.equal(200);

		resp.body.total_items.should.equal(1);
		resp.body.items.should.contain("id456");
	});

	it("GET /rt/toptags/TestBucket/10", async () => {
		const resp = await requester.get("/rt/toptags/TestBucket/10");
		resp.status.should.equal(200);

		resp.body.total_items.should.equal(5);
		resp.body.items[0].tag.should.equal("all");
	});

	it("GET /rt/id/TestBucket/id123", async () => {
		const resp = await requester.get("/rt/id/TestBucket/id123");
		resp.status.should.equal(200);

		resp.body.should.contain("all");
		resp.body.should.contain("tag1");
		resp.body.should.contain("tag2");
	});

	it("GET /rt/allids/TestBucket", async () => {
		const resp = await requester.get("/rt/allids/TestBucket");
		resp.status.should.equal(200);

		resp.body.should.contain("id123");
		resp.body.should.contain("id456");
	});

	it("GET /rt/buckets", async () => {
		const resp = await requester.get("/rt/buckets");
		resp.status.should.equal(200);

		resp.body.should.contain("TestBucket");
	});

	it("DELETE /rt/id/TestBucket/id123 should return 200 ", async () => {
		const resp = await requester.delete("/rt/id/TestBucket/id123");
		resp.status.should.equal(200);
	});


	it("DELETE /rt/bucket/TestBucket should return 200 ", async () => {
		const resp = await requester.delete("/rt/bucket/TestBucket");
		resp.status.should.equal(200);
	});
});

