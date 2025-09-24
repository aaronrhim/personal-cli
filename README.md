# Installation

npm pack

Build the image
```docker build -t personal-demo .```

Run a new container
```docker run -it --name mycontainer personal-demo zsh```

Start an existing container
```docker start -ai mycontainer```