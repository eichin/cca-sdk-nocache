# Containerized Cordova App Building for Android

## Why

https://developer.chrome.com/apps/chrome_apps_on_mobile describes
using Apache Cordoba to turn Chrome Apps into Mobile apps for Android
(and iOS, but this won't actually help you with that.)

Sounds great - but once you dig in to the instructions you find a lot
of downloading and a lot of java installation and unpacking, all of
which is tedious and in the longer term, prone to version skew
problems - and since none of this plays well with your operating
system's packaging tools, there's reason to be a bit fearful of the
install.

There are two ways to reduce this fear.  The traditional way would be
to actually package all of the components; this works ok up until you
hit the underlying android sdk tool, which is *itself* an
application-specific package manager.  The "modern" way is to take a
huge shortcut - instead of caring about how messy the install is, just
do it inside a docker container, which you can just throw away when
you're done or need to upgrade.

## How

The problem is broken into two parts: creating a docker image with the
complete build environment, and using it for your own development.

### Building the image

The "zeroeth" step is to create a docker image you can use at all
(since public docker images are Just Wrong - not only is the
documented provenance of an image usually unclear, but the tools
themselves don't validate that the downloads match the manifests, so
you don't have any confidence that you even *got* the
intended-but-unverified packages.)  On Debian, at least, the `make
basedeb` step uses `mkimage.sh` to produce one locally with
`debootstrap` which will get packages using your `sources.list` and
already-configured package-signing mechanisms to assure that you're
building something out of Debian packages which you actually got from
Debian itself - there is of course room for more concern beyond that,
but it seems like a reasonable standard to start from.

For the first step, simply `make image` which took about an hour over
DSL, and will probably be faster for you... two things you should know
in advance:

* the `Dockerfile` just types `y` at all license prompts for you, so
  be sure to read through them afterwards.
* all of the explicit downloads (and as far as I can tell all of the
  implicit ones) are done with `https` - this is good and correct, but
  means there is no useful caching you can do to save time iterating
  over the configuration if anything goes wrong.  (It is possible to
  force some of the tools to use `http`, but there's no alternate way
  to verify them, so don't do that.)  Ultimately you're going to use
  the Docker Image as your cache anyway.

The build step runs `cca checkenv` to perform installation self-tests
at the end; running `make check` will repeat the test.

### Using the image

If you're starting from scratch like I am, after the image is built,
simply `make sample` which will create and build a sample app - it
displays the Chrome logo and a little text, producing a 20M `apk` to
do so. The output will show you where to find the `apk` files, pick
the relevant one (which is *probably* `android-armv7-debug.apk`) and
copy it to your phone, and you should be able to launch it from there.
On a 2014 model Intel NUC with SSD, this applications build takes
about four minutes.

### Doing your own development

This is where you want to go back to [the chrome apps page, step 3 "develop"](https://developer.chrome.com/apps/chrome_apps_on_mobile#step-3-develop)
for help.  You can take basic baby steps simply by exploring the
`code` directory that `make sample` created; in particular, the app
itself is just rendering `code/sample/www/index.html`, so if you just
edit that (and add other content there, look at the existing layout
for images and javascript assets) and re-run the `cca build` in that
directory (`make rebuild-sample` will do this directly) you should be
able to copy the new `apk` over to your phone and see the results.

You will likely want to copy the lines in the `Makefile` to fit your
app as you develop it - or even just run a shell inside the docker
image (`make shell`) and then run `cca` and other dev-kit commands
directly.  (Bonus points for coming up with an `inotify`/`cca build`
loop that you can just leave running.) Also you'll very quickly want
to actually set up an android emulator, or have it push directly to
your phone; see the develop step linked above.

### Updates

In theory, you could take new updates to the Android and Chrome SDKs
by setting up a dockerfile that based a new image on the one generated
here, run the update inside that, then re-run `cca build`.  (Since
`/code` is *outside* the image, that survives the upgrade.)  This
mostly suggests the need for `docker rebase`, though it might turn out
that just re-tagging the new image with the old name is enough.

Alternatively, you can just discard (`docker rmi`) the image and
recreate it when there's a new upstream release that you actually
want; this avoids having to care about whether the "update" process
actually works.

## What Next

If you find this prep work useful, drop me a note describing your app;
if it doesn't work out, please open issues about the problems (I
haven't gotten my own apps beyond the `hello world` step here.)
