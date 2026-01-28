#include <libdragon.h>
#include "contpad.h"


ContPad PollController(int port) {
    joypad_inputs_t joypad = joypad_get_inputs(port);
    joypad_buttons_t keysPressed = joypad_get_buttons_pressed(port);
    joypad_buttons_t keysHeld = joypad_get_buttons_held(port);

    ContPad ret = {0};
    ret.held.a       = keysHeld.a;
    ret.held.b       = keysHeld.b;
    ret.held.z       = keysHeld.z;
    ret.held.start       = keysHeld.start;
    ret.held.d_up        = keysHeld.d_up;
    ret.held.d_down      = keysHeld.d_down;
    ret.held.d_left      = keysHeld.d_left;
    ret.held.d_right     = keysHeld.d_right;
    ret.held.y       = keysHeld.y;
    ret.held.x       = keysHeld.x;
    ret.held.l       = keysHeld.l;
    ret.held.r       = keysHeld.r;
    ret.held.c_up        = keysHeld.c_up;
    ret.held.c_down      = keysHeld.c_down;
    ret.held.c_left      = keysHeld.c_left;
    ret.held.c_right     = keysHeld.c_right;


    ret.pressed.a       = keysPressed.a;
    ret.pressed.b       = keysPressed.b;
    ret.pressed.z       = keysPressed.z;
    ret.pressed.start       = keysPressed.start;
    ret.pressed.d_up        = keysPressed.d_up;
    ret.pressed.d_down      = keysPressed.d_down;
    ret.pressed.d_left      = keysPressed.d_left;
    ret.pressed.d_right     = keysPressed.d_right;
    ret.pressed.y       = keysPressed.y;
    ret.pressed.x       = keysPressed.x;
    ret.pressed.l       = keysPressed.l;
    ret.pressed.r       = keysPressed.r;
    ret.pressed.c_up        = keysPressed.c_up;
    ret.pressed.c_down      = keysPressed.c_down;
    ret.pressed.c_left      = keysPressed.c_left;
    ret.pressed.c_right     = keysPressed.c_right;

    ret.stick_x = joypad.stick_x & 0xFF;
    ret.stick_y = joypad.stick_y & 0xFF;

    // TODO: gc support?

    return ret;
}

