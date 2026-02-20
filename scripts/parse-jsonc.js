const fs = require('fs');
const { parse } = require('jsonc-parser');

const file = process.argv[2];
try {
  const content = fs.readFileSync(file, 'utf8');
  const json = parse(content);
  console.log(JSON.stringify(json));
} catch (e) {
  console.error('Error parsing ' + file, e);
  process.exit(1);
}
