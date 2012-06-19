#!/bin/bash

# When cross-compiling glib it will try to find glib-genmarshal from
# the system instead of using the freshly built one from the source
# tree. If the system version comes from glib >= 2.31.0 then the
# generated source will try to use g_value_get_schar when getting the
# value of a GValue containing a char. This function isn't available
# in the version of glib that these scripts try to build so the
# generated marshalling code will not build. This wrapper calls the
# normal glib-genmarshal but forces it to use the old
# g_value_get_char() function.

glib-genmarshal "$@" | sed s/g_value_get_schar/g_value_get_char/

exit $?
