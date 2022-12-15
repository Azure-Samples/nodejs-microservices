const config = require('../config');

async function saveUserSettings(userId, settings) {
  const response = await fetch(`${config.settingsApiUrl}/settings/${userId}`, {
    method: 'PUT',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify(settings),
  });
  if (!response.ok) {
    throw new Error(`Cannot save settings for user ${userId}: ${response.statusText}`);
  }
}

async function getUserSettings(userId) {
  const response = await fetch(`${config.settingsApiUrl}/settings/${userId}`);
  if (!response.ok) {
    throw new Error(`Cannot get settings for user ${userId}: ${response.statusText}`);
  }
  return response.json();
}

module.exports = {
  saveUserSettings,
  getUserSettings,
};
