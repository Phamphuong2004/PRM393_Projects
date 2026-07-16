const fs = require('fs');
const path = require('path');

const sharedDir = path.join(__dirname, 'shared', 'src');
const services = ['auth-service', 'core-service', 'interaction-service', 'admin-service'];

function copyFolderSync(from, to) {
    if (!fs.existsSync(from)) return;
    if (!fs.existsSync(to)) fs.mkdirSync(to, { recursive: true });

    fs.readdirSync(from).forEach(element => {
        const fromElement = path.join(from, element);
        const toElement = path.join(to, element);

        if (fs.lstatSync(fromElement).isFile()) {
            fs.copyFileSync(fromElement, toElement);
        } else {
            copyFolderSync(fromElement, toElement);
        }
    });
}

console.log('🔄 Sychronizing shared modules to all services...');

services.forEach(service => {
    const serviceDir = path.join(__dirname, service, 'src');
    
    // We only copy if the service actually needs it (e.g. if the folder already exists or we force it)
    // Here we sync middleware and config folders
    ['middleware', 'config', 'utils'].forEach(folder => {
        const sourceFolder = path.join(sharedDir, folder);
        const destFolder = path.join(serviceDir, folder);
        
        // Always sync if source exists
        if (fs.existsSync(sourceFolder)) {
            copyFolderSync(sourceFolder, destFolder);
            console.log(`✅ Synced ${folder} to ${service}`);
        }
    });
});

console.log('🎉 Sync completed successfully!');
