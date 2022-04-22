/*
Rest-Tagging

The MIT License (MIT)

Copyright © 2013-2016 Patrick Liess, http://www.tcs.de

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the “Software”), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

import express, { Request, Response, NextFunction } from "express";
import morgan from "morgan";
import RedisTagging from "redis-tagging";

import config from "./config.json";
import packageJson from "./package.json";

const rt = new RedisTagging(config.redis);

const PORT = process.env.PORT || config.port || 3000;
const VERSION = packageJson.version;
const RESTPREFIX = config.rest_path_prefix
	? (
		config.rest_path_prefix.startsWith("/")
			? config.rest_path_prefix
			: "/" + config.rest_path_prefix
	)
	: "";

const app = express();
app.use(morgan(process.env.NODE_ENV === "production" ? "combined" : "dev", {
	skip: (req) => req.url === "/ping"
}));
app.use(express.json({limit: "50mb"}));
app.use(express.urlencoded({limit: "50mb", extended: true}));
app.disable("x-powered-by");

app.get("/ping", (req, res) => {
	return res.json({
		result: "pong",
		version: VERSION
	});
});

/**
 * create an item with tags
 */
app.put(RESTPREFIX + "/id/:bucket/:id", async (req: Request, res: Response, next: NextFunction) => {
	console.log(req.query.tags);

	const tags = req.query.tags ? (JSON.parse(req.query.tags as string) || []) : [];
	const score = req.query.score as (string | undefined);

	try {
		const resp = await rt.set({bucket: req.params.bucket, id: req.params.id, score, tags});
		return res.json(resp);
	} catch (err) {
		return next(err);
	}
});

/**
 * delete an id
 */
app.delete(RESTPREFIX + "/id/:bucket/:id", async (req: Request, res: Response, next: NextFunction) => {
	try {
		const resp = await rt.remove({bucket: req.params.bucket, id: req.params.id});
		return res.json(resp);
	} catch (err) {
		return next(err);
	}
});

/**
 * get all tags of an id
 */
app.get(RESTPREFIX + "/id/:bucket/:id", async (req: Request, res: Response, next: NextFunction) => {
	try {
		const resp = await rt.get({bucket: req.params.bucket, id: req.params.id});
		return res.json(resp);
	} catch (err) {
		return next(err);
	}
});

/**
 * get all ids of a bucket
 */
app.get(RESTPREFIX + "/allids/:bucket", async (req: Request, res: Response, next: NextFunction) => {
	try {
		const resp = await rt.allids({bucket: req.params.bucket});
		return res.json(resp);
	} catch (err) {
		return next(err);
	}
});

/**
 * tags: the main query. query items for some tags
 */
app.get(RESTPREFIX + "/tags/:bucket", async (req: Request, res: Response, next: NextFunction) => {
	try {
		const resp = await rt.tags({
			...req.query,
			bucket: req.params.bucket,
			tags: JSON.parse(req.query.tags as string)
		});
		return res.json(resp);
	} catch (err) {
		return next(err);
	}
});

/**
 * top tags
 */
app.get(RESTPREFIX + "/toptags/:bucket/:amount", async (req: Request, res: Response, next: NextFunction) => {
	try {
		const resp = await rt.toptags({bucket: req.params.bucket, amount: parseInt(req.params.amount, 10)});
		return res.json(resp);
	} catch (err) {
		return next(err);
	}
});

/**
 * get all buckets
 */
app.get(RESTPREFIX + "/buckets", async (req: Request, res: Response, next: NextFunction) => {
	try {
		const resp = await rt.buckets();
		return res.json(resp);
	} catch (err) {
		return next(err);
	}
});

/**
 * remove bucket
 */
app.delete(RESTPREFIX + "/bucket/:bucket", async (req: Request, res: Response, next: NextFunction) => {
	try {
		const resp = await rt.removebucket({bucket: req.params.bucket});
		return res.json(resp);
	} catch (err) {
		return next(err);
	}
});

// error handler
app.use((err: any, req: Request, res: Response, next: NextFunction) => {
	return res.status(500).send({name: err.name, message: err.message});
});

if (require.main === module) {
	app.listen(PORT, () => {
		console.log("Server started on port " + PORT);
	});
}

export default app;