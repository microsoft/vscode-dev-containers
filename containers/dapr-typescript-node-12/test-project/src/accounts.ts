import * as express from 'express';

const router = express.Router();

router.get('/:id', (req, res) => {
    res.send(req.params.id);
});

router.post('/:id/deposit', (req, res) => {
    res.send(req.params.id);
});

router.post('/:id/withdraw', (req, res) => {
    res.send(req.params.id);
});

export default router;
