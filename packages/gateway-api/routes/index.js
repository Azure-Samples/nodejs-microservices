const express = require('express');
const router = express.Router();
const settingsService = require('../services/settings');
const rollsService = require('../services/rolls');

router.put('/settings', async function(req, res) {
  const settings = req.body;
  try {
    await settingsService.saveUserSettings(req.user, settings);
    res.sendStatus(204);
  } catch (error) {
    res.status(502).send(error.message || 'Bad gateway');
  }
});

router.get('/settings', async function(req, res) {
  try {
    const settings = await settingsService.getUserSettings(req.user);
    res.json(settings);
  } catch (error) {
    res.status(502).send(error.message || 'Bad gateway');
  }
});

router.post('/rolls', async function(req, res) {
  const count = Number(req.body?.count);
  if (isNaN(count) || count < 1) {
    return res.status(400).send('Invalid count parameter');
  }
  try {
    const result = await rollsService.rollDices(req.user, req.body.count);
    res.json(result);
  } catch (error) {
    res.status(502).send(error.message || 'Bad gateway');
  }
});

router.get('/rolls/history', async function(req, res) {
  try {
    const result = await rollsService.getRollsHistory(req.user, req.query.max);
    res.json(result);
  } catch (error) {
    res.status(502).send(error.message || 'Bad gateway');
  }
});

module.exports = router;
