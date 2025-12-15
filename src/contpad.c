#include <libdragon.h>
#include "contpad.h"


ContPad PollController(int port) {
    joypad_poll();
    joypad_buttons_t keys = joypad_get_buttons_pressed(port);

    ContPad ret = {0};
    ret.a       = keys.a;
    ret.b       = keys.b;
    ret.z       = keys.z;
    ret.start       = keys.start;
    ret.d_up        = keys.d_up;
    ret.d_down      = keys.d_down;
    ret.d_left      = keys.d_left;
    ret.d_right     = keys.d_right;
    ret.y       = keys.y;
    ret.x       = keys.x;
    ret.l       = keys.l;
    ret.r       = keys.r;
    ret.c_up        = keys.c_up;
    ret.c_down      = keys.c_down;
    ret.c_left      = keys.c_left;
    ret.c_right     = keys.c_right;

    return ret;
}

