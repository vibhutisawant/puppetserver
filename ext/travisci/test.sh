#!/bin/bash

set -e

echo "Total memory available: $(grep MemTotal /proc/meminfo | awk '{print $2}')"

git submodule update --recursive --init
lein clean
rm -rf vendor

./dev/install-test-gems.sh

unzip -q ~/.m2/repository/org/jruby/jruby-stdlib/9.2.17.0/jruby-stdlib-9.2.17.0.jar
cp META-INF/jruby.home/lib/ruby/stdlib/ffi/platform/powerpc-aix/syslog.rb META-INF/jruby.home/lib/ruby/stdlib/ffi/platform/s390x-linux/
zip -qr jruby-stdlib.jar META-INF
cp jruby-stdlib.jar ~/.m2/repository/org/jruby/jruby-stdlib/9.2.17.0/jruby-stdlib-9.2.17.0.jar
if [ "$MULTITHREADED" = "true" ]; then
  filter=":multithreaded"
else
  filter=":singlethreaded"
fi
test_command="lein -U $ADDITIONAL_LEIN_ARGS test $filter"
echo $test_command
$test_command

rake spec
