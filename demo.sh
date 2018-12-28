#!/usr/bin/env bash
printf "First we need to clean up, and build the required artifacts\n"
make all
printf "Now we launch the originally compiled server, and track its pid\n"
./bin/server & echo $! > "pid"
sleep 1
printf "curl confirms the originally compiled code returns the initial response, as expected:\n"
printf "\n\n****Response****\n"
curl localhost:8080
printf "\n****End Response****\n\n"
printf "Now we chmod the plugin, and the running process will load it:\n"
chmod 666 ./plug/plug.so
sleep 3
printf "The plugin replaces the request handler, now curl returns:\n"
printf "\n\n****Response****\n"
curl localhost:8080
printf "\n****End Response****\n\n"
printf "Now let's compile version 2 of the plugin, but give it the same filename, using:\n"
printf "go build -buildmode=plugin -o plug/plug.so plug/plug2.go\n"
go build -buildmode=plugin -o plug/plug.so plug/plug2.go
chmod 666 ./plug/plug.so
sleep 3
printf "The plugin will not be replaced, because the path is the same.\n"
printf "This is the documented behavior, and we see that curl still returns:\n"
printf "\n\n****Response****\n"
curl localhost:8080
printf "\n****End Response****\n\n"

printf "****PART TWO****\n"
printf "Now we will recompile the ORIGINAL plugin, but place it in a different directory, using:\n"
printf "go build -buildmode=plugin -o plug/1/plug1.so plug/plug.go\n"
go build -buildmode=plugin -o plug/1/plug1.so plug/plug.go
chmod 666 ./plug/1/plug1.so
sleep 3
printf "\n\n****Response****\n"
curl localhost:8080
printf "\n****End Response****\n\n"
printf "Even though it's in a different directory, has a different name, and the timestamp\n"
printf "variable would be different, the go runtime recognizes it as the same module,\n"
printf "the handler is not switched, and the response does not change.\n"
printf "\n****PART THREE****\n"
printf "Now we will compile v2 of the module, which differs by one character of source code,\n"
printf "but give it a different name in the same directory, using:\n"
printf "go build -buildmode=plugin -o plug/plug2.so plug/plug2.go\n"
go build -buildmode=plugin -o plug/plug2.so plug/plug2.go
chmod 666 ./plug/plug2.so
sleep 3
printf "\n\n****Response****\n"
curl localhost:8080
printf "\n****End Response****\n\n"
printf "Now, since the path is different, AND THE CODE IS DIFFERENT, you will see that the response\n"
printf "has changed.\n"
printf "\n****PART FOUR****\n"
printf "Now we will try something different.  Let's try and rollback to the original plugin.\n"
printf "Maybe we can just CHMOD the original plugin, and reload it...\n"
chmod 644 ./plug/plug.so
sleep 3
printf "\n\n****Response****\n"
curl localhost:8080
printf "\n****End Response****\n\n"
printf "As you can see, you can rollback in this way, because the previous module has not gone anywhere.\n"
kill `cat "pid"` && rm "pid"