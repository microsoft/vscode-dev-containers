function cleanup {
  echo -e "\e[33mCleanup... please wait\e[0m"
  cd ../../..
  kill -9 `cat save_pid.txt`
  rm save_pid.txt
  rm -rf workspace/
}
npm i
mkdir -p workspace
nohup node server.js > /dev/null &
sleep 1
echo $! > save_pid.txt
exercism configure -t=TEST_TOKEN_123 -w $(pwd)/workspace -a http://localhost:3000/v1
exercism download --exercise=hello-world --track=javascript
cd workspace/javascript/hello-world
npm i
echo "
//
// This is only a SKELETON file for the 'Hello World' exercise. It's been provided as a
// convenience to get you started writing code faster.
//

export const hello = () => {
  return 'Hello, World!';
};
" > hello-world.js
npm run test
echo -e "🏆 \e[32mexercism cli test - Download solution completed successfully\e[0m"
if exercism submit hello-world.js 2>&1 | grep -q "Your solution has been submitted successfully."; then
  echo -e "🏆 \e[32mexercism cli test - Submit solution completed successfully\e[0m"
else
  echo -e "💥 \e[31mexercism cli test - Submit solution failed\e[0m"
  cleanup
  exit 1
fi
cleanup
