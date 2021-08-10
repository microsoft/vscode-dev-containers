import * as fs from 'fs';
import * as cp from 'child_process';
import copyFilesCb from 'copyfiles';
import rimrafCb from 'rimraf';
import * as  crypto from 'crypto';
import * as https from 'https';
import * as path from 'path';

export class ProcessError extends Error {
    result: string = '';
    code: number = -1;
    signal: string = '';
}

export async function spawn(command: string, args: string[], opts: any = { stdio: 'inherit', shell: true }): Promise<string> {
    console.log(`(*) Spawn: ${command}${args.reduce((prev, current) => `${prev} ${current}`, '')}`);
    let echo = false;
    if (opts.stdio === 'inherit') {
        opts.stdio = 'pipe';
        echo = true;
    }
    return new Promise((resolve, reject) => {
        let result = '';
        const proc = cp.spawn(command, args, opts);

        proc.on('close', (code, signal) => {
            if (code !== 0) {
                console.log(result);
                const err = new ProcessError(`Non-zero exit code: ${code} ${signal || ''}`);
                err.result = result;
                err.code = code;
                err.signal = signal;
                reject(err);
                return;
            }
            resolve(result);
        });

        if (proc.stdout) {
            proc.stdout.on('data', (chunk) => {
                const stringChunk = chunk.toString();
                result += stringChunk;
                if (echo) {
                    console.log(stringChunk);
                }
            });
        }
        if (proc.stderr) {
            proc.stderr.on('data', (chunk) => {
                const stringChunk = chunk.toString();
                result += stringChunk;
                if (echo) {
                    console.error(stringChunk);
                }
            });
        }
        proc.on('error', reject);
    });
}


export async function readFile(filePath: string): Promise<string> {
    return new Promise((resolve, reject) => {
        fs.readFile(filePath, 'utf8', (err, data) => err ? reject(err) : resolve(data.toString()));
    });
}

export async function writeFile(filePath: string, data: string): Promise<void> {
    return new Promise((resolve, reject) => {
        fs.writeFile(filePath, data, 'utf8', (err) => err ? reject(err) : resolve());
    });
}

export async function exec(command: string, opts: any = {}) {
    console.log(`(*) Exec: ${command}`);
    return new Promise((resolve, reject) => {
        let result = '';
        const proc = cp.exec(command, opts);
        proc.on('close', (code, signal) => {
            if (code !== 0) {
                console.log(result);
                const err = new ProcessError(`Non-zero exit code: ${code} ${signal || ''}`);
                err.result = result;
                err.code = code;
                err.signal = signal;
                reject(err);
                return;
            }
            resolve(result);
        });
        if (proc.stdout) {
            proc.stdout.on('data', (chunk) => result += chunk.toString());
        }
        if (proc.stderr) {
            proc.stderr.on('data', (chunk) => result += chunk.toString());
        }
        proc.on('error', reject);
    });
}

export async function forEach(array: Array<any>, cb: Function) {
    for (let i = 0; i < array.length; i++) {
        await cb(array[i], i, array);
    }
}

export async function rename(from: string, to: string): Promise<void> {
    return new Promise((resolve, reject) => {
        fs.rename(from, to, (err) => err ? reject(err) : resolve());
    });
}

export async function mkdirp(directoryPath: string): Promise<string> {
    return new Promise((resolve, reject) => {
        fs.mkdir(directoryPath, <fs.MakeDirectoryOptions>{recursive: true},  (err) => err ? reject(err) : resolve(directoryPath));
    });
}

export async function rimraf(pathToRemove: string, opts: rimrafCb.Options = {}): Promise<string> {
    return new Promise((resolve, reject) => {
        rimrafCb(pathToRemove, opts, (err) => err ? reject(err) : resolve(pathToRemove));
    });
}

export async function copyFiles(source: string, blobs: string[], target: string): Promise<string> {
    return new Promise((resolve, reject) => {
        process.chdir(source);
        copyFilesCb(
            blobs.concat(target),
            { all: true },
            (err) => err ? reject(err) : resolve(target));
    });
}

// async copyfile
export async function copyFile(src: string, dest: string): Promise<void> {
    return new Promise((resolve, reject) => {
        fs.copyFile(src, dest, (err) => err ? reject(err) : resolve());
    });
}


// async chmod
export async function chmod(src: string, mod: string): Promise<void> {
    return new Promise((resolve, reject) => {
        fs.chmod(src, mod, (err) => err ? reject(err) : resolve());
    });
}

// async readdir
export async function readdir(dirPath: string, opts: {} = {}): Promise<string[] | Buffer[] | fs.Dirent[]> {
    return new Promise((resolve, reject) => {
        fs.readdir(dirPath, opts, (err, files) => err ? reject(err) : resolve(files));
    });
}

interface ReadDirRecursiveResult {
    files: string[];
    directories: string[];
}

// async recursiveReaddir
export async function readdirRecursive(dirPath: string, relativeTo: string = dirPath): Promise<ReadDirRecursiveResult> {
    return new Promise<ReadDirRecursiveResult>((resolve, reject) => {
        const promises: Promise<ReadDirRecursiveResult>[] = [];
        fs.readdir(dirPath, { withFileTypes: true }, (err, entries) => {
            if(err) {
                return reject(err);
            }
            const currentFiles: string[] = [];
            const currentDirectories: string[] = [];
            entries.forEach((entry) => {
                const entryPath = path.resolve(dirPath, entry.name);
                const entryRelativePath = path.relative(relativeTo, entryPath);
                if(entry.isDirectory()) {
                    promises.push(readdirRecursive(entryPath, relativeTo));
                    currentDirectories.push(entryRelativePath);
                } else {
                    currentFiles.push(entryRelativePath);
                }
            })
            const resultsPromise: Promise<ReadDirRecursiveResult[]> = Promise.all(promises);
            resultsPromise.then((results) => {
                resolve(results.reduce((prev, result) => {
                    prev.files = prev.files.concat(result.files);
                    prev.directories = prev.directories.concat(result.directories);
                    return prev;
                },{
                    files: currentFiles,
                    directories: currentDirectories
                }));
            }, reject);
        });
    });
   
}

// async exists
export async function exists(filePath: string): Promise<boolean> {
    return fs.existsSync(filePath);
}

// async gen SHA 256 hash for file
export async function shaForFile(filePath: string) : Promise<string> {
    return new Promise((resolve, reject) => {
        const fd = fs.createReadStream(filePath);
        const hash = crypto.createHash('sha256');
        hash.setEncoding('hex');
        fd.on('end', function () {
            hash.end();
            resolve(hash.read());
        });
        fd.on('error', (err) => {
            reject(err);
        });
        fd.pipe(hash);
    })
}

// async gen SHA 256 hash for string
export async function shaForString(content: string) {
    const hash = crypto.createHash('sha256');
    hash.update(content);
    return hash.digest('hex');
}

// async HTTPS get
export async function getUrlAsString(url: string): Promise<string> {
    return new Promise((resolve, reject) => {
        let content: string = '';
        const req = https.get(url, function (res) {
            res.on('data', function (chunk: string | Buffer) {
                content += chunk.toString();
            });
        });
        req.on("error", reject);
        req.on('close', () => resolve(content));
    });
}
