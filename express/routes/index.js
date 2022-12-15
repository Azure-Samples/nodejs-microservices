const express = require('express');
const router = express.Router();
const settingsService = require('../services/settings');
const rollsService = require('../services/rolls');

router.put('/settings', async function(req, res) {
  const settings = req.body;
  try {
    settingsService.saveUserSettings(req.user, settings);
    res.sendStatus(204);
  } catch (error) {
    res.status(502).send(error.message);
  }
});

router.get('/settings', async function(req, res) {
  try {
    const settings = await settingsService.getUserSettings(req.user);
    res.json(settings);
  } catch (error) {
    res.status(502).send(error.message);
  }
});

router.post('/rolls', async function(req, res) {
  if (!req.body.count || isNaN(Number(req.body.count))) {
    return res.status(400).send('Invalid count parameter');
  }
  try {
    const result = await rollsService.rollDices(req.user, req.body.count);
    res.json(result);
  } catch (error) {
    res.status(502).send(error.message);
  }
});

router.get('/rolls/history', async function(req, res) {
  try {
    const result = await rollsService.getHistory(req.user, req.query.max);
    res.json(result);
  } catch (error) {
    res.status(502).send(error.message);
  }
});

module.exports = router;
