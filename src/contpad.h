#pragma once

#include <stdint.h>
#include <stdbool.h>

/**
 * Vaguely-compatible joypad_buttons_t, which we're gluing with C.
 *  This is because `Zig translate-c` can't parse the original, due to having a weird combo of
 *  bitfields, unions, and substructs.
 *  We just flatten everything here.
 */

struct Buttons {
    bool a;
    bool b;
    bool z;
    bool start;
    bool d_up;
    bool d_down;
    bool d_left;
    bool d_right;
    bool y;
    bool x;
    bool l;
    bool r;
    bool c_up;
    bool c_down;
    bool c_left;
    bool c_right;
};

typedef struct ContPad {
    struct Buttons pressed;
    struct Buttons held;
    int8_t stick_x;
    int8_t stick_y;
    int8_t cstick_x;
    int8_t cstick_y;
    uint8_t analog_l;
    uint8_t analog_r;
} ContPad;

ContPad PollController(int port);
