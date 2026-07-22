#!/usr/bin/env node
'use strict';

const fs = require('fs');
const tls = require('tls');

const [host, port, sender, recipients, fixture] = process.argv.slice(2);
if (!host || !port || !sender || !recipients || !fixture) {
  console.error('Usage: smtp-submit.js HOST PORT SENDER RECIPIENTS_CSV FIXTURE');
  process.exit(64);
}

const message = fs.readFileSync(fixture, 'utf8')
  .replace(/\r?\n/g, '\r\n')
  .replace(/^\./gm, '..');
const socket = tls.connect({host, port: Number(port), rejectUnauthorized: false});
let buffer = '';
let waiting;

function nextResponse() {
  return new Promise((resolve, reject) => {
    waiting = {resolve, reject};
  });
}

function command(value, expected) {
  socket.write(`${value}\r\n`);
  return nextResponse().then(response => {
    if (!response.startsWith(expected)) throw new Error(`Expected ${expected}, got ${response}`);
    return response;
  });
}

socket.on('data', chunk => {
  buffer += chunk.toString('utf8');
  const lines = buffer.split('\r\n');
  buffer = lines.pop();
  for (const line of lines) {
    if (line.length && waiting && /^[0-9]{3} /.test(line)) {
      const current = waiting;
      waiting = undefined;
      current.resolve(line);
    }
  }
});

socket.on('error', error => {
  if (waiting) waiting.reject(error);
  else throw error;
});

(async () => {
  try {
    const greeting = await nextResponse();
    if (!greeting.startsWith('220')) throw new Error(`Expected greeting, got ${greeting}`);
    await command('EHLO protocol-test.invalid', '250');
    await command(`MAIL FROM:<${sender}>`, '250');
    for (const recipient of recipients.split(',')) await command(`RCPT TO:<${recipient}>`, '250');
    await command('DATA', '354');
    socket.write(`${message}\r\n.\r\n`);
    const acknowledgement = await nextResponse();
    if (!acknowledgement.startsWith('250')) throw new Error(`Expected SMTP acknowledgement, got ${acknowledgement}`);
    console.log(JSON.stringify({event: 'smtp-ack', timestamp: Date.now(), response: acknowledgement}));
    await command('QUIT', '221');
    socket.end();
  } catch (error) {
    console.error(String(error));
    socket.destroy();
    process.exitCode = 1;
  }
})();
