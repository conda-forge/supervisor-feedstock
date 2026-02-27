#!/bin/bash -ex
function render()
{
    src_file=$1
    dst_file=$2/$(basename $src_file)

    [ -f $src_file ] || exit 127

    mkdir -p $2

    cp $src_file $dst_file
    sed -i "s;\${PREFIX};$PREFIX;g" $dst_file
}

function mkdir_touch()
{
    dir=$1
    mkdir -p $dir
    touch $dir/.mkdir
}

$PYTHON -m pip install --no-deps -vv .
# Don't install the test suite.
rm -r $SP_DIR/supervisor/tests

mkdir_touch $PREFIX/etc/supervisord/conf.d
mkdir_touch $PREFIX/etc/supervisord/startup
mkdir_touch $PREFIX/var/log
mkdir_touch $PREFIX/var/run

render $RECIPE_DIR/supervisord.conf $PREFIX/etc/supervisord/
# Create a symlink in $PREFIX/etc so that supervisorctl can find the config file:
# ../etc/supervisord.conf (Relative to the executable).
# See https://supervisord.org/configuration.html
ln -s $PREFIX/etc/supervisord/supervisord.conf $PREFIX/etc/supervisord.conf

mkdir -p $PREFIX/etc/rc.d/init.d/
render $RECIPE_DIR/Debian-supervisord $PREFIX/etc/rc.d/init.d/
render $RECIPE_DIR/RedHat-supervisord $PREFIX/etc/rc.d/init.d/


mkdir -p $PREFIX/etc/systemd/system/
render $RECIPE_DIR/supervisord.service $PREFIX/etc/systemd/system/
