# Buildroot
A Docker container for using [Buildroot][buildroot].

## Get started
To get started build the Docker image.

``` shell
$ docker build -t "orangetux/buildroot" .
```

Create a [data-only container][data-only] to use as build and download
cache and to store your build products. 

``` shell
$ docker run -i --name buildroot_output orangetux/buildroot /bin/echo "Data only."
```

This container has 2 volumes at `/root/buildroot/dl` and `/buildroot_output`. 
Buildroot downloads al data to the first volume, the last volume is used as
build cache.

## Usage
Buildroot needs a configuration. Mounting an existing configuration at
`/root/buildroot/.config` won't work. When you use `make` Buildroot will fail
with:

> Error while writing of the configuration.
> Your configuration changes were NOT saved.

The trick is to mount a defconfig in the container. Then in the container
create `.config` from this defconfig, edit configuration using `menuconfig` and
create a new defconfig from the updated `.config` file. Then run the build.
The edits to your configuration will be saved on the host machine.

Start the container and execute the commands as stated below. If your build
requires more configuration files, like board files or a kernel configuration
you have to mount them too using the `-v` flag.

```shell
$ docker run --rm -ti --volumes-from buildroot_output -v $(pwd)/.defconfig:/root/buildroot/.defconfig orangetux/buildroot bash
root@8211b942171e:~/buildroot# make defconfig BR2_DEFCONFIG=.defconfig O=/buildroot_output
[...]
root@8211b942171e:~/buildroot# make menuconfig O=/buildroot_output
[...]
root@8211b942171e:~/buildroot# make savedefconfig BR2_DEFCONFIG=.defconfig O=/buildroot_output
root@8211b942171e:~/buildroot# make O=/buildroot_output 
[...]
```

Now copy the build products from the data-only container to your disk:

```shell
$ docker run -ti --volumes-from buildroot_output -v $(pwd):/data orangetux/buildroot cp -va /buildroot_output/images /data/
```

[buildroot]:http://buildroot.uclibc.org/
[data-only]:https://docs.docker.com/userguide/dockervolumes/
