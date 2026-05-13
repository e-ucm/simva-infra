#!/usr/bin/env node

/**
 * Setup script to handle local dependency deployment
 * Checks environment variables and installs local packages if enabled
 */

const fs = require('fs');
const path = require('path');
const { execSync } = require('child_process');

const JSTRACKER_LOCAL_PATH = process.env.JSTRACKER_LOCAL_PATH || '/home/node/js-tracker';
const JSTRACKER_LOCAL_DEPLOYMENT = process.env.JSTRACKER_LOCAL_DEPLOYMENT === 'true';

console.log('[Setup] Starting local dependency setup...');
console.log(`[Setup] JSTRACKER_LOCAL_DEPLOYMENT: ${process.env.JSTRACKER_LOCAL_DEPLOYMENT}`);
console.log(`[Setup] JSTRACKER_LOCAL_PATH: ${process.env.JSTRACKER_LOCAL_PATH}`);

if (JSTRACKER_LOCAL_DEPLOYMENT) {
    const jsTrackerPath = path.resolve(__dirname, JSTRACKER_LOCAL_PATH);
    const appDir = path.resolve(__dirname, '..');
    
    console.log(`[Setup] Resolving local js-tracker path: ${jsTrackerPath}`);
    
    if (fs.existsSync(jsTrackerPath)) {
        console.log(`[Setup] ✓ Local js-tracker found at: ${jsTrackerPath}`);
        console.log(`[Setup] Installing local js-tracker...`);
        
        try {
            // Install the local js-tracker using file: protocol
            execSync(`npm install file:${jsTrackerPath}`, { 
                cwd: appDir,
                stdio: 'inherit' 
            });
            console.log('[Setup] ✓ Successfully installed local js-tracker');
        } catch (error) {
            console.error('[Setup] ✗ Failed to install local js-tracker:', error.message);
            process.exit(1);
        }
    } else {
        console.warn(`[Setup] ⚠ JSTRACKER_LOCAL_DEPLOYMENT enabled but path not found: ${jsTrackerPath}`);
        console.warn('[Setup] Proceeding with npm registry version');
    }
} else {
    console.log('[Setup] Using default js-tracker from npm registry (GitHub)');
}

console.log('[Setup] Local dependency setup completed');