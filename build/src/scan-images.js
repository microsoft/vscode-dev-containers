const asyncUtils = require('./utils/async');
const configUtils = require('./utils/config');
const path = require('path');

// Command to install, setup, and execute a clamav scan on the whole image
const scanCommand = "apt-get update \
    && apt-get install -yq clamav clamav-daemon \
    && /etc/init.d/clamav-freshclam start \
    && freshclam \
    && /etc/init.d/clamav-daemon start \
    && clamscan -i -r --exclude-dir='/proc' --exclude-dir='/dev' --exclude-dir='/sys' /"

async function scanImagesForMalware(release, registry, registryPath, alwaysPull, page, pageTotal, definitionsToSkip, definitionId) {  
    page = page || 1;
    pageTotal = pageTotal || 1;
    await configUtils.loadConfig(path.join(__dirname, '..', '..'));
    const definitionsToScan = definitionId ? [definitionId] : configUtils.getSortedDefinitionBuildList(page, pageTotal, definitionsToSkip);
    const imagesWithMalware = [];
    const imageScanFailures = [];
    await asyncUtils.forEach(definitionsToScan, async (definitionId) => {
        console.log(`(*) Scanning images for ${definitionId} definition...`);
        const imagesToScan = getImageListForDefinition(definitionId, release, registry, registryPath);
        await asyncUtils.forEach(imagesToScan, async (imageToScan) => {
            console.log(`(*) Scanning ${imageToScan}...`);
            try {
                await asyncUtils.spawn('docker', [
                    'run', 
                    '--init', 
                    '--privileged', 
                    '--rm', 
                    '--pull', alwaysPull ? 'always' : 'missing',
                    '-u', 'root', 
                    imageToScan,
                    `sh -c "${scanCommand}"`
                ], { shell: true, stdio: 'inherit' })
            } catch (err) {
                // clamscan returns an exit code of 1 specifically if malware is detected
                if(err.code === 1) {
                    console.error(`(!) Scan returned exit code 1 - Malware detected in ${imageToScan}!!`);
                    imagesWithMalware.push(imageToScan);
                } else {
                    console.error(`(!) Scan returned exit code ${err.code} - scan failed.`);
                    imageScanFailures.push(imageToScan);
                }
            }
        });
    });

    console.log(`(*) Scan summary\n    Images w/malware: ${imagesWithMalware}\n    Scan failures: ${imageScanFailures}`);

    if (imagesWithMalware > 0) {
        console.log('\n\n(!) ** MALWARE DETECTED! **');
        throw('Malware detected!');
    }

    if (imageScanFailures > 0) {
        console.log('\n\n(!) One or more scans hit an error or warning.');
        throw('One or more scans hit an error or warning.');
    }
}

function getImageListForDefinition(definitionId, release, registry, registryPath) {
            // Get one image per variant
            const variants = configUtils.getVariants(definitionId);
            if (variants) {    
                return variants.map((variant) => configUtils.getTagList(definitionId, release, false, registry, registryPath, variant)[0]);
            }
            return configUtils.getTagList(definitionId, release, false, registry, registryPath)[0];
    
}

module.exports = {
    scanImagesForMalware: scanImagesForMalware
}