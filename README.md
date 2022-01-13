# helloworld app
A sample Golang "Hello world" application deployed locally using [kind](https://kind.sigs.k8s.io/)

## Required tools
### Packaged using:
- [Docker](https://docs.docker.com/)
- [helm](https://helm.sh/docs)

### Tested locally using:
- [kind](https://kind.sigs.k8s.io/)

# Usage
Assumes all required external dependencies listed above are installed.

Run:
```shell
make start
```

Open a new browser window and visit: [http://localhost/](http://localhost/)

After running the application clean up using:
```shell
make clean
```

For more information on configuring private local domain see:
- https://mjpitz.com/blog/2020/10/21/local-ingress-domains-kind/