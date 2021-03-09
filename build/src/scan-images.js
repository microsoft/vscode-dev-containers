const asyncUtils = require('./utils/async');
const configUtils = require('./utils/config');
const path = require('path');
const packageJson = require('../../package.json');

// Command to install, setup, and execute a clamav scan on the whole image
const scanCommand = {
    "debian": "echo '(*) Setting up ClamAV...' \
        && apt-get -qq update && export DEBIAN_FRONTEND=noninteractive \
        && apt-get -qq -y install --no-install-recommends clamav clamav-daemon 1>/dev/null \
        && freshclam --no-warnings \
        && echo '(*) Running scan (this can take a while)...' \
        && clamscan -i -r --exclude-dir='/proc' --exclude-dir='/dev' --exclude-dir='/sys' /",
    "ubuntu": "echo '(*) Setting up ClamAV...' \
        && apt-get -qq update && export DEBIAN_FRONTEND=noninteractive \
        && apt-get -qq -y install --no-install-recommends clamav clamav-daemon 1>/dev/null \
        && freshclam --no-warnings \
        && echo '(*) Running scan (this can take a while)...' \
        && clamscan -i -r --exclude-dir='/proc' --exclude-dir='/dev' --exclude-dir='/sys' /",
    "alpine": "echo '(*) Setting up ClamAV...' \
        && apk add clamav clamav-daemon unrar clamav-libunrar \
        && freshclam --no-warnings \
        && echo '(*) Running scan (this can take a while)...' \
        && clamscan -i -r --exclude-dir='/proc' --exclude-dir='/dev' --exclude-dir='/sys' /"
}

async function scanImagesForMalware(release, registry, registryPath, alwaysPull, page, pageTotal, definitionsToSkip, pruneBetweenDefinitions, definitionId) {  
    page = page || 1;
    pageTotal = pageTotal || 1;
    
    // Warn if image versions might be out of sync
    if (release.charAt(0) === 'v' && !isNaN(parseInt(release.charAt(1))) && release !== `v${packageJson.version}`) {
        console.log(`(!) WARNING: Release specified (${release}) does not match the package.json\n    version (${packageJson.version}). Some image versions will be based on\n    local source code so this can lead to unexpected results.\n`);
    }

    await configUtils.loadConfig(path.join(__dirname, '..', '..'));
    const definitionsToScan = definitionId ? [definitionId] : configUtils.getSortedDefinitionBuildList(page, pageTotal, definitionsToSkip);
    const imagesWithMalware = [];
    const imageScanFailures = [];

    await asyncUtils.forEach(definitionsToScan, async (currentDefinitionId) => {
        console.log(`**** Scanning images for ${currentDefinitionId} ****`);
        const imagesToScan = getImageListForDefinition(currentDefinitionId, release, registry, registryPath);
        await asyncUtils.forEach(imagesToScan, async (imageToScan) => {
            console.log(`(*) Scanning ${imageToScan}...`);
            const rootDistro = configUtils.getLinuxDistroForDefinition(currentDefinitionId);
            try {
                await asyncUtils.spawn('docker', [
                    'run', 
                    '--init', 
                    '--privileged', 
                    '--rm', 
                    '-v', 'clamav:/var/lib/clamav',
                    '--pull', alwaysPull ? 'always' : 'missing',
                    '-u', 'root', 
                    imageToScan,
                    `sh -c "${scanCommand[rootDistro]}"`
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
            // Prune images if setting enabled
            if (pruneBetweenDefinitions) {
                await asyncUtils.spawn('docker', ['image', 'prune', '-a']);
            }
            console.log();
        });
        console.log('(*) Done!\n');
    });

    console.log(`(*) Scan results:\n    Images w/malware:  ${imagesWithMalware.length} ${imagesWithMalware.length > 0 ? '(' + imagesWithMalware + ')' : ''}\n    Scan failures: ${imageScanFailures.length} ${imageScanFailures.length > 0 ? '(' + imageScanFailures + ')' : ''}`);

    if (imagesWithMalware > 0) {
        console.log('\n(!) ***** MALWARE DETECTED! *****');
        throw('Malware detected!');
    }

    if (imageScanFailures > 0) {
        console.log('\n(!) One or more scans hit an error or warning.');
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