const config = require('../config');
const { getUserSettings } = require('./settings');

async function rollDices(userId, count) {
  const settings = await getUserSettings(userId);
  const sides = settings.sides ?? 6;
  const requests = [];
  const makeRequest = async () => {
    const response = await fetch(`${config.diceApiUrl}/rolls`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ sides }),
    });
    if (!response.ok) {
      throw new Error(`Cannot roll dice for user ${userId}: ${response.statusText}`);
    }
    const json = await response.json();
    return json.result;
  }

  for (let i = 0; i < count; i++) {
    requests.push(makeRequest());
  }

  return { result: await Promise.all(requests) };
}

async function getHistory(userId, max) {
  max = max ?? '';
  const settings = await getUserSettings(userId);
  const sides = settings.sides ?? '';
  const response = await fetch(`${config.diceApiUrl}/rolls/history?max=${max}&sides=${sides}`);
  if (!response.ok) {
    throw new Error(`Cannot get roll history for user ${userId}: ${response.statusText}`);
  }
  return response.json();
}

module.exports = {
  rollDices,
  getHistory,
};
