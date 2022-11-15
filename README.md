    docker container run -i  --rm -v $(pwd):/mnt -t rust-aarch64-linux



todo GNU C Library (GNU libc) stable release version 2.26,
todo disable ssh

update config
update -clang in bin
update cross-compile-setup

kept using cc, despite environment variable. why? symlink worked.

hello world worked without symlink cc nonsense.
is hello world reliant on glibc?

Compile openssl for musl https://qiita.com/liubin/items/6c94f0b61f746c08b74c

Need rustflags = ["-C", "target-feature=+crt-static"]?

-ld in cargo config? https://jakewharton.com/cross-compiling-static-rust-binaries-in-docker-for-raspberry-pi/

Started synology developer. Couldn't mount /proc in Docker.
https://help.synology.com/developer-guide/getting_started/first_package.html