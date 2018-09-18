# q3vm-objc-example

This is a small demo project, that demonstrates calling Objective-C from
within the [Q3VM](https://github.com/jnz/q3vm).

The Q3VM files vm.h and vm.c have their own license.


## How to build

This is a [mulle-sde](https://mulle-sde.github.io/) project.

It has it's own virtual environment, that will be automatically setup for you
once you enter it with:

```
$ mulle-sde q3vm-objc-example
```

Now you can let **mulle-sde** fetch the required dependencies and build the 
project for you:

```
$ mulle-sde craft --debug
```

## Additional requirement

See that [q3vm]((https://github.com/jnz/q3vm) is checked out alongside `q3vm-objc-example` and build it:

```
$ ls
q3vm
q3vm-objc-example
$ cd q3vm ; make
```

## Run

```
$ cd q3vm-objc-example/qvm-src
$ mkdir build
$ make
$ ../build/Debug/q3vm-objc-example ./call-objc.qvm
```

