import fs from 'fs-extra';
import { glob } from 'glob';
import path from 'path';
import { fileURLToPath } from 'url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

async function build() {
  console.log('🚀 Building Digital Garden...');
  
  // Очищаем папку public
  await fs.remove('./public');
  await fs.ensureDir('./public');
  
  // Ищем все markdown файлы
  const mdFiles = await glob('**/*.md', {
    ignore: [
      'node_modules/**',
      '.git/**',
      'public/**',
      '**/node_modules/**'
    ]
  });
  
  console.log(`📝 Found ${mdFiles.length} markdown files`);
  
  // Копируем каждый markdown файл
  for (const file of mdFiles) {
    const sourcePath = path.join(__dirname, file);
    const destPath = path.join(__dirname, 'public', file);
    
    // Создаем директории если нужно
    await fs.ensureDir(path.dirname(destPath));
    
    // Копируем файл
    await fs.copy(sourcePath, destPath);
    console.log(`✅ Copied: ${file}`);
  }
  
  // Создаем индексный файл
  const indexContent = `
# My Digital Garden

Welcome to my digital garden! This is a collection of my notes, thoughts, and ideas.

## Recent Notes
${mdFiles.map(file => `- [${path.basename(file, '.md')}](${file})`).join('\n')}

---
*Last updated: ${new Date().toISOString()}*
  `.trim();
  
  await fs.writeFile('./public/README.md', indexContent);
  console.log('📄 Created index file');
  
  console.log('🎉 Build completed successfully!');
  console.log(`📁 Total files: ${mdFiles.length + 1}`);
}

build().catch(console.error);