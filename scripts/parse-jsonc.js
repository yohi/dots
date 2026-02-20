const fs = require('fs');
const { parse, printParseErrorCode } = require('jsonc-parser');

const file = process.argv[2];

if (!file || file.trim() === '') {
  console.error('使い方: node scripts/parse-jsonc.js <file.jsonc>');
  process.exit(1);
}

try {
  const content = fs.readFileSync(file, 'utf8');
  const errors = [];
  const json = parse(content, errors, {
    allowTrailingComma: true,
    disallowComments: false,
  });

  if (errors.length > 0 || typeof json === 'undefined') {
    console.error(`❌ エラー: JSONCのパースに失敗しました: ${file}`);
    errors.forEach((error, index) => {
      console.error(
        `  [${index + 1}] ${printParseErrorCode(error.error)} (offset: ${error.offset}, length: ${error.length})`
      );
    });
    process.exit(1);
  }

  console.log(JSON.stringify(json));
} catch (e) {
  console.error(`❌ エラー: ${file} の読み込みに失敗しました:`, e.message || e);
  process.exit(1);
}
