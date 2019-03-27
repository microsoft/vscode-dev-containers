import * as yargs from 'yargs';
import * as glob from 'glob';
import * as https from 'https';

const DEV_CONTAINERS_REPO = 'Microsoft/vscode-dev-containers';
const DEFINITIONS_PATH = 'containers';

yargs.command('add <definitionId>', 
    'Add files from the container definition to a local folder', 
    (yargs: any) => {
        return yargs.positional('definitionId', {
                describe: 'Dev Container Definition ID',
                requiresArg: true,
                type: 'string'
            })
            .option('output', { 
                alias: 'o', 
                describe: 'Folder to output container definition files.', 
                default: process.cwd(),
                type: 'string'
            });
    }, (argv: any)=> {
        add(argv.definitionId, argv.output);
    })
    .help();

async function list(devContainersRepo: string = DEV_CONTAINERS_REPO, definitionsPath: string = DEFINITIONS_PATH) {

    try {
        const ghResponse = await getContent('', devContainersRepo, definitionsPath);
        if(!Array.isArray(ghResponse)) {
            console.error('Failed to get ist of dev container definitions! Response object is not an Array.');
            process.exit(1);
        }
        console.log('Current available dev container definitions: \n\n');
        ghResponse.forEach((folder: any)=> {
            if(!folder.name) {
                console.error('Failed to get ist of dev container definitions! Object has no name property.');
                process.exit(1);
            }
            console.log(folder.name);
        });
    } catch (err) {
        console.error('Failed to get ist of dev container definitions! ' + err);
    }
}

async function add(definitionId: string, outputFolder: string = process.cwd(), devContainersRepo: string = DEV_CONTAINERS_REPO, definitionsPath: string = DEFINITIONS_PATH) {
    try {
        const definitionContents = await getContent(definitionId, devContainersRepo, definitionsPath);
        if(!Array.isArray(definitionContents)) {
            if(definitionContents.message === 'Not Found') {
                console.error(`Dev container definition ${definitionId} not found.`);
            } else {
                console.error(`Failed to get dev container definition ${definitionId}! Response object is not an Array.`);
            }
            process.exit(1);
        }

        // see if .vscodeignore is present, parse it if so, filter out contents, then download each file and place them in outputFolder

    } catch (err) {
        console.error('Failed to get ist of dev container definitions! ' + err);
    }
}

async function getContent(path: string = '',  devContainersRepo: string = DEV_CONTAINERS_REPO, definitionsPath: string = DEFINITIONS_PATH): Promise<any> {
    const contentPath = definitionsPath + (path !== '' ? '/' + path : '');
    return new Promise((resolve, reject) => {
        https.get(`https://api.github.com/repos/${devContainersRepo}/contents/${contentPath}`, (res)=> {
            let ghResponseString = '';
            res.on('data', (data) => ghResponseString += data);
            res.on('end', (aborted: boolean) => {
                if (aborted) {
                    reject(`Failed to get content from ${contentPath} in ${devContainersRepo}.`);
                    return;
                }
                try {
                    resolve(JSON.parse(ghResponseString));
                } catch (err) {
                    reject(`Failed to parse GitHub response. ` + err);
                }
            });
        }).on('error', (err) => {
            reject('Failed to get ist of dev container definitions! ' + err);
        });    
    });
}