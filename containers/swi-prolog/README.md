# SWI Prolog Dev Container

Sets up SWI Prolog in a VS Code [development
container](https://code.visualstudio.com/docs/remote/containers). You need
[Docker](https://www.docker.com/products/docker-desktop) and [VS
Code](https://code.visualstudio.com/) with [Microsoft's Remote
Containers](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers)
extension. You can run SWI Prolog from a docker container within Visual Studio
Code.

## X11 and Emacs

The container sets up `DISPLAY` for X11 connectivity.

	"runArgs": [
		"-e", "DISPLAY=host.docker.internal:0"
	],

You can then run the `emacs` predicate, e.g.

    $ swipl -g emacs

or, of course, you can launch it and other graphical Prolog tools from the
ubiquitous _Do What I Mean_ prompt.

	Welcome to SWI-Prolog (threaded, 64 bits, version 8.5.0)
	SWI-Prolog comes with ABSOLUTELY NO WARRANTY. This is free software.
	Please run ?- license. for legal details.

	For online help and background, visit https://www.swi-prolog.org
	For built-in help, use ?- help(Topic). or ?- apropos(Word).

	?- emacs.
	true.

	?- prolog_ide(thread_monitor), prolog_ide(xref).

This assumes that you have an X server at `host.docker.internal` which
corresponds to the host interface.

On Windows, you can install an X11 server using [VcXsrv Windows X
Server](https://community.chocolatey.org/packages/vcxsrv) using Chocolatey. Do
not forget to disable access control.
