import subprocess

# Eg. /Users/jospicer/dev/vscode-dev-containers/containers
ABS_PATH_TO_CONTAINERS_FOLDER = ''

# Eg. /Users/jospicer/dev/vscode-dev-containers/migrations/options.json
OPTIONS_FILE = ''

containers = [
    'alpine',
    'azure-ansible',
    'azure-bicep',
    'azure-cli',
    'azure-functions-dotnet-6-inprocess',
    'azure-functions-dotnet-6-isolated',
    'azure-functions-dotnetcore-3.1',
    'azure-functions-java-11',
    'azure-functions-java-8',
    'azure-functions-node',
    'azure-functions-pwsh',
    'azure-functions-python-3',
    'azure-machine-learning-python-3',
    'azure-static-web-apps',
    'azure-terraform',
    'bash',
    'bazel',
    'chef-workstation',
    'codespaces-linux',
    'cpp',
    'cpp-mariadb',
    'dapr-dotnet',
    'dapr-javascript-node',
    'dart',
    'debian',
    'deno',
    'docker-existing-docker-compose',
    'docker-existing-dockerfile',
    'docker-from-docker',
    'docker-from-docker-compose',
    'docker-in-docker',
    'dotnet',
    'dotnet-fsharp',
    'dotnet-mssql',
    'dotnet-postgres',
    'elixir',
    'elixir-phoenix-postgres',
    'elm',
    'go',
    'go-postgres',
    'haskell',
    'hugo',
    'java',
    'java-8',
    'java-postgres',
    'javascript-node',
    'javascript-node-azurite',
    'javascript-node-mongo',
    'javascript-node-postgres',
    'jekyll',
    'julia',
    'jupyter-datascience-notebooks',
    'kubernetes-helm',
    'kubernetes-helm-minikube',
    'markdown',
    'mit-scheme',
    'perl',
    'php',
    'php-mariadb',
    'powershell',
    'puppet',
    'python-3',
    'python-3-anaconda',
    'python-3-anaconda-postgres',
    'python-3-device-simulator-express',
    'python-3-miniconda',
    'python-3-miniconda-postgres',
    'python-3-postgres',
    'python-3-pypy',
    'r',
    'reasonml',
    'ruby',
    'ruby-rails',
    'ruby-rails-postgres',
    'ruby-sinatra',
    'rust',
    'rust-postgres',
    'sfdx-project',
    'swift',
    'typescript-node',
    'ubuntu',
    'vue'
]


def template(defId, displayName, description, categories, defType, platforms, options):
    categories = '", "'.join(categories)
    platforms = '", "'.join(platforms)
    if defType == 'Dockerfile' or defType == 'Image':
        defType = 'singleContainer'
    elif defType == 'Docker Compose':
        defType = 'dockerCompose'
    else:
        raise Exception('Unknown type: ' + defType)

    if options == '':
        options = 'lc rc'

    subst = '''
		lc
			"id": "{}",
			"displayName": "{}",
			"description": "{}",
			"categories": [ "{}" ],
			"platforms": [ "{}" ],
			"type": "{}",
			"options": {}
		rc,'''.format(defId, displayName, description, categories, platforms, defType, options)

    return subst.replace('lc', '{').replace('rc', '}')


exceptions = 0
failedDetails = []
for c in containers:
    readme = f'{ABS_PATH_TO_CONTAINERS_FOLDER}/{c}/README.md'
#     print(readme)
    try:
        displayName = subprocess.check_output(
            f"/usr/bin/egrep -m 1 '^# ().*' {readme}", shell=True)
        displayName = str(displayName, 'utf-8').strip().replace('# ',
                                                                '').replace('\\n', '')

        description = subprocess.check_output(
            f"/usr/bin/egrep -m 1 '(\*|_)(.*)(\*|_)$' {readme}", shell=True)
        description = str(description, 'utf-8').strip().replace(
            '*', '').replace('\\n', '')

        categories = subprocess.check_output(
            f"/usr/bin/egrep -m 1 '(\*|_)(Categories|Category)(\*|_)' {readme}", shell=True)
        categories = str(categories, 'utf-8').split(
            '|')[2].replace('*', '').split(',')
        categories = map(str.strip, categories)

        defType = subprocess.check_output(
            f"/usr/bin/egrep -m 1 '(\*|_)Definition type(\*|_)' {readme}", shell=True)
        defType = str(defType, 'utf-8').split(
            '|')[2].replace('*', '').strip()

        platforms = subprocess.check_output(
            f"/usr/bin/egrep -m 1 '(\*|_)Languages, platforms(\*|_)' {readme}", shell=True)
        platforms = str(platforms, 'utf-8').split(
            '|')[2].replace('*', '').split(',')
        platforms = map(str.strip, platforms)

        options = ''
        try:
            options = subprocess.check_output(
                f"cat {OPTIONS_FILE}| jq -r '.[] | select(.id == \"{c}\") | .options'", shell=True)
            options = str(options, 'utf-8').strip()
        except:
            options = ''
            pass

        print(template(c, displayName, description,
              categories, defType, platforms, options))

    except Exception as e:
        failedDetails.append(f'{c}: {e}')
        exceptions += 1

        continue

print()
print('==============================')
print(f'{exceptions} exceptions')
for f in failedDetails:
    print(f)
    print('---')
