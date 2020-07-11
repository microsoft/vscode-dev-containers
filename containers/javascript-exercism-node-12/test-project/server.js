const express = require('express')
const bodyParser = require('body-parser')
let multer = require('multer')
const app = express()
const port = 3000
const upload = multer({ storage: multer.memoryStorage() });

// Content-Disposition: form-data; name="files[]"; filename="hello-world.js"
// Content-Type: application/octet-stream

const solutionContent = `
//
// This is only a SKELETON file for the 'Hello World' exercise. It's been provided as a
// convenience to get you started writing code faster.
//

export const hello = () => {
  return 'Hello, World!';
};
`

const downloadTemplate = (requester = true, baseSiteUrl ='http://localhost:3000/', baseUrl = 'javascript/hello-world/') => ({
	"solution": {
		"id": "8e36e667",
		"user": {
			"handle": "CyberLight",
			"is_requester": requester
		},
		"team": null,
		"exercise": {
			"id": "hello-world",
			"instructions_url": `${baseSiteUrl}/v1`,
			"auto_approve": false,
			"track": {
				"id": "javascript",
				"language": "JavaScript"
			}
		},
		"file_download_base_url": `${baseSiteUrl}${baseUrl}`,
		"files": [
			"babel.config.js",
			".eslintrc",
			".exercism/metadata.json",
			"hello-world.js",
			"hello-world.spec.js",
			".npmrc",
			"package.json",
			"README.md",
		],
		"iteration": {
			"submitted_at": "2020-07-11T10:13:37.100Z"
		}
	}
});

app.use(bodyParser.urlencoded({
	extended: true
})).use(bodyParser.json());
app.use((req, res, next) => {
	console.warn(req.originalUrl);
	next();
});

app.get('/v1/validate_token', (_, res) => {
	res.json({});
});
app.get('/v1/ping', (_, res) => {
	console.warn('PING')
	return res.json({ "status": { "website": true, "database": true } });
});
app.use('/javascript/hello-world', express.static(__dirname + '/javascript/hello-world'));
app.get('/v1/solutions/latest', (_, res) => {
	res.json(downloadTemplate());
});
app.patch('/v1/solutions/:id', upload.single('files[]'), (req, res) => {
	if (req.file.originalname === 'hello-world.js' && 
		req.file.buffer.toString().trim() === solutionContent.trim()) return res.send('ok');
	res.status(400).json({ type: 'error', message: 'Wrong solution!' });
});
app.listen(port, () => console.log(`Example app listening at http://localhost:${port}`))