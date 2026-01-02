/**
 * Random files to make stuff work
 */
#include <stdio.h>
#include <stdlib.h>
#include <malloc.h>
#include <string.h>
#include <stdint.h>
#include <libdragon.h>


void stop_game(char *msg, size_t len) {
    msg[len] = 0;
    assertf(0, msg);
}

