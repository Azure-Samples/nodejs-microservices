const apiUrl = '/api';
const sidesInput = document.getElementById('sides');
const countInput = document.getElementById('count');
const maxInput = document.getElementById('max');
const resultDiv = document.getElementById('result');

async function getUserSettings() {
  const response = await fetch(`${apiUrl}/settings`);
  if (response.ok) {
    const { sides } = await response.json();
    sidesInput.value = sides;
  } else {
    const message = await response.text();
    resultDiv.innerHTML = `Cannot load user settings: ${message}`;
  }
}

async function saveUserSettings() {
  const sides = sidesInput.value;
  const response = await fetch(`${apiUrl}/settings`, {
    method: 'PUT',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ sides }),
  });
  if (response.ok) {
    resultDiv.innerHTML = 'User settings saved';
  } else {
    const message = await response.text();
    resultDiv.innerHTML = `Cannot save user settings: ${message}`;
  }
}

async function rollDices() {
  const count = countInput.value;
  const response = await fetch(`${apiUrl}/rolls`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ count }),
  });
  if (response.ok) {
    const json = await response.json();
    resultDiv.innerHTML = json.result.join(', ');
  } else {
    const message = await response.text();
    resultDiv.innerHTML = `Cannot roll dices: ${message}`;
  }
}

async function getRollHistory() {
  const max = maxInput.value;
  const response = await fetch(`${apiUrl}/rolls/history?max=${max}`);
  if (response.ok) {
    const json = await response.json();
    resultDiv.innerHTML = json.result.join(', ');
  } else {
    const message = await response.text();
    resultDiv.innerHTML = `Cannot get roll history: ${message}`;
  }
}

async function getUser() {
  try {
    const response = await fetch(`/.auth/me`);
    if (response.ok) {
      const json = await response.json();
      return json.clientPrincipal;
    }
  } catch {}
  return undefined;
}

function login() {
  window.location.href = `/.auth/login/github`;
}

function logout() {
  window.location.href = `/.auth/logout`;
}

async function main() {
  // Check if user is logged in
  const user = await getUser();

  if (user) {
    // Load user settings
    await getUserSettings();
    
    document.getElementById('app').hidden = false;
    document.getElementById('user').innerHTML = user.userDetails;
  } else {
    document.getElementById('login').hidden = false;
  }

  // Setup event handlers
  document.getElementById('loginButton').addEventListener('click', login);
  document.getElementById('logoutButton').addEventListener('click', logout);
  document.getElementById('saveButton').addEventListener('click', saveUserSettings);
  document.getElementById('rollButton').addEventListener('click', rollDices);
  document.getElementById('historyButton').addEventListener('click', getRollHistory);
}

main();
