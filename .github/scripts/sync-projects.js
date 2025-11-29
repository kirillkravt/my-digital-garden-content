const fs = require('fs');
const path = require('path');
const matter = require('gray-matter');
const axios = require('axios');

const STRAPI_URL = process.env.STRAPI_URL || 'http://localhost:1337';
const STRAPI_TOKEN = process.env.STRAPI_TOKEN;

const strapi = axios.create({
  baseURL: STRAPI_URL,
  headers: {
    'Authorization': `Bearer ${STRAPI_TOKEN}`,
    'Content-Type': 'application/json'
  }
});

// Функция для поиска проекта по названию
async function findProjectByTitle(title) {
  try {
    const response = await strapi.get(`/api/projects?filters[Название][$eq]=${encodeURIComponent(title)}`);
    return response.data.data[0] || null;
  } catch (error) {
    console.error(`Error finding project ${title}:`, error.message);
    return null;
  }
}

// Функция для создания/обновления проекта
async function syncProject(filePath) {
  try {
    const fileContent = fs.readFileSync(filePath, 'utf8');
    const { data: frontmatter, content } = matter(filePath);
    
    console.log(`Syncing project: ${frontmatter.title}`);
    
    const projectData = {
      data: {
        Название: frontmatter.title,
        Описание: frontmatter.description || '',
        Детальное_описание: content,
        Статус: frontmatter.status || 'active',
        publishedAt: frontmatter.published !== false ? new Date().toISOString() : null
      }
    };
    
    // Ищем существующий проект
    const existingProject = await findProjectByTitle(frontmatter.title);
    
    if (existingProject) {
      // Обновляем существующий проект
      await strapi.put(`/api/projects/${existingProject.id}`, projectData);
      console.log(`✅ Updated project: ${frontmatter.title}`);
    } else {
      // Создаем новый проект
      await strapi.post('/api/projects', projectData);
      console.log(`✅ Created project: ${frontmatter.title}`);
    }
    
  } catch (error) {
    console.error(`❌ Error syncing project ${filePath}:`, error.message);
  }
}

// Главная функция
async function main() {
  console.log('Starting projects sync...');
  
  const projectsDir = path.join(process.env.GITHUB_WORKSPACE, 'projects');
  
  if (!fs.existsSync(projectsDir)) {
    console.log('No projects directory found');
    return;
  }
  
  const projectFiles = fs.readdirSync(projectsDir)
    .filter(file => file.endsWith('.md'));
  
  console.log(`Found ${projectFiles.length} project files`);
  
  for (const file of projectFiles) {
    await syncProject(path.join(projectsDir, file));
  }
  
  console.log('Projects sync completed!');
}

main().catch(console.error);