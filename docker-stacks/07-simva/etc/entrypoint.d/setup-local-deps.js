#!/usr/bin/env node

/**
 * Setup script to handle local dependency deployment
 * Checks environment variables and installs local packages if enabled
 */

const fs = require('fs');
const os = require('os');
const path = require('path');
const { execSync } = require('child_process');

const JSTRACKER_LOCAL_PATH = process.env.JSTRACKER_LOCAL_PATH || '/home/node/js-tracker';
const JSTRACKER_LOCAL_DEPLOYMENT = process.env.JSTRACKER_LOCAL_DEPLOYMENT === 'true';
const APP_DIR = process.env.SIMVA_APP_DIR || '/home/node/app';

console.log('[Setup] Starting local dependency setup...');
console.log(`[Setup] JSTRACKER_LOCAL_DEPLOYMENT: ${process.env.JSTRACKER_LOCAL_DEPLOYMENT}`);
console.log(`[Setup] JSTRACKER_LOCAL_PATH: ${process.env.JSTRACKER_LOCAL_PATH}`);

if (JSTRACKER_LOCAL_DEPLOYMENT) {
    const jsTrackerPath = path.resolve(__dirname, JSTRACKER_LOCAL_PATH);
    const appDir = APP_DIR;
    
    console.log(`[Setup] Resolving local js-tracker path: ${jsTrackerPath}`);
    
    if (fs.existsSync(jsTrackerPath)) {
        console.log(`[Setup] ✓ Local js-tracker found at: ${jsTrackerPath}`);
        const tempBuildDir = fs.mkdtempSync(path.join(os.tmpdir(), 'js-tracker-build-'));

        console.log(`[Setup] Copying local js-tracker to writable temp dir: ${tempBuildDir}`);
        
        try {
            // Build in a temp copy to avoid permission issues on host-mounted folders.
            fs.cpSync(jsTrackerPath, tempBuildDir, {
                recursive: true,
                force: true,
                filter: (src) => !src.includes(`${path.sep}node_modules${path.sep}`)
            });

            console.log('[Setup] Installing js-tracker dependencies...');
            execSync('npm install', {
                cwd: tempBuildDir,
                stdio: 'inherit'
            });

            console.log('[Setup] Building local js-tracker...');
            execSync('npm run build', {
                cwd: tempBuildDir,
                stdio: 'inherit'
            });

            console.log('[Setup] Installing local js-tracker into simva-api...');
            // Pack first to force a real copy into node_modules (not a symlink to tempBuildDir).
            const tarballName = execSync('npm pack --silent', {
                cwd: tempBuildDir,
                stdio: ['ignore', 'pipe', 'inherit']
            }).toString().trim();
            const tarballPath = path.join(tempBuildDir, tarballName);

            // Install only into node_modules without mutating app manifests.
            execSync(`npm install --no-save --no-package-lock file:${tarballPath}`, {
                cwd: appDir,
                stdio: 'inherit'
            });
            console.log('[Setup] ✓ Successfully installed local js-tracker');
        } catch (error) {
            console.error('[Setup] ✗ Failed to install local js-tracker:', error.message);
            process.exit(1);
        } finally {
            try {
                fs.rmSync(tempBuildDir, { recursive: true, force: true });
            } catch (cleanupError) {
                console.warn(`[Setup] ⚠ Failed to cleanup temp dir: ${cleanupError.message}`);
            }
        }
    } else {
        console.warn(`[Setup] ⚠ JSTRACKER_LOCAL_DEPLOYMENT enabled but path not found: ${jsTrackerPath}`);
        console.warn('[Setup] Proceeding with npm registry version');
    }
} else {
    console.log('[Setup] Using default js-tracker from npm registry (GitHub)');
}

console.log('[Setup] Local dependency setup completed');