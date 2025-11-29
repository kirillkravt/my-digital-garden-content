const fs = require('fs');
const path = require('path');
const matter = require('gray-matter');
const axios = require('axios');

// Конфигурация из environment variables
const STRAPI_URL = process.env.STRAPI_URL || 'http://localhost:1337';
const STRAPI_TOKEN = process.env.STRAPI_TOKEN;

// Создаем axios instance с авторизацией
const strapi = axios.create({
  baseURL: STRAPI_URL,
  headers: {
    'Authorization': `Bearer ${STRAPI_TOKEN}`,
    'Content-Type': 'application/json'
  }
});

// Функция для преобразования markdown в Strapi Rich Text формат
function markdownToStrapiBlocks(markdown) {
  const lines = markdown.split('\n');
  const blocks = [];
  
  for (const line of lines) {
    if (line.trim() === '') continue;
    
    blocks.push({
      type: 'paragraph',
      children: [
        {
          type: 'text',
          text: line
        }
      ]
    });
  }
  
  return blocks;
}

// Функция для поиска поста по slug
async function findPostBySlug(slug) {
  try {
    const response = await strapi.get(`/api/posts?filters[Slug][$eq]=${slug}`);
    return response.data.data[0] || null;
  } catch (error) {
    console.error(`Error finding post ${slug}:`, error.message);
    return null;
  }
}

// Функция для создания/обновления поста
async function syncPost(filePath) {
  try {
    const fileContent = fs.readFileSync(filePath, 'utf8');
    const { data: frontmatter, content } = matter(fileContent);
    
    const slug = frontmatter.slug || path.basename(filePath, '.md');
    
    console.log(`Syncing post: ${frontmatter.title} (${slug})`);
    
    const postData = {
      data: {
        Title: frontmatter.title,
        Excerpt: frontmatter.excerpt || '',
        Content: markdownToStrapiBlocks(content),
        Slug: slug,
        publishedAt: frontmatter.published !== false ? new Date().toISOString() : null
      }
    };
    
    // Ищем существующий пост
    const existingPost = await findPostBySlug(slug);
    
    if (existingPost) {
      // Обновляем существующий пост
      await strapi.put(`/api/posts/${existingPost.id}`, postData);
      console.log(`✅ Updated post: ${frontmatter.title}`);
    } else {
      // Создаем новый пост
      await strapi.post('/api/posts', postData);
      console.log(`✅ Created post: ${frontmatter.title}`);
    }
    
  } catch (error) {
    console.error(`❌ Error syncing post ${filePath}:`, error.message);
  }
}

// Главная функция
async function main() {
  console.log('Starting posts sync...');
  
  const postsDir = path.join(process.env.GITHUB_WORKSPACE, 'posts');
  
  if (!fs.existsSync(postsDir)) {
    console.log('No posts directory found');
    return;
  }
  
  const postFiles = fs.readdirSync(postsDir)
    .filter(file => file.endsWith('.md'));
  
  console.log(`Found ${postFiles.length} post files`);
  
  for (const file of postFiles) {
    await syncPost(path.join(postsDir, file));
  }
  
  console.log('Posts sync completed!');
}

main().catch(console.error);