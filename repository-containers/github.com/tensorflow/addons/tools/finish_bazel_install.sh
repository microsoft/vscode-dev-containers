set -e
# hack to have the dependecies in the docker cache
# and have much faster local build with docker
# can be removed once docker buildx/buildkit is stable
# and we'll use "RUN --mount=cache ..." instead
cd /tmp
git clone https://github.com/tensorflow/addons.git
cd addons
python ./configure.py --no-deps
bazel build --nobuild -- //tensorflow_addons/...
cd ..
rm -rf ./addons