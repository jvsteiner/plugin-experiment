all: clean plug bin/server

run: all
	./bin/server

plug: ./plug/plug.go
	go build -buildmode=plugin -o plug/plug.so plug/plug.go

clean:
	rm -f `find . -iname "*.so"`
	# rm -rf plug/*.so || true
	rm bin/server || true

bin/server: cmd/main.go
	go build -o bin/server cmd/main.go

# Tasks that don not match output artifact name
.PHONY: all \
	run \
	plug \
	clean \
