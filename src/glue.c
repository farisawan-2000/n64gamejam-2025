/**
 * Random files to make stuff work
 */
#include <stdio.h>
#include <stdlib.h>
#include <malloc.h>
#include <string.h>
#include <stdint.h>
#include <libdragon.h>
#include "t3d/t3d.h"
#include "t3d/t3dmodel.h"

/**
 * rdpq memes
 */
void set_blend_mode_multiply() {
    rdpq_mode_blender(RDPQ_BLENDER_MULTIPLY);
}

void set_combiner_mode_flat() {
    rdpq_mode_combiner(RDPQ_COMBINER_FLAT);
}

void set_combiner_mode_shade() {
    rdpq_mode_combiner(RDPQ_COMBINER_SHADE);
}

void test_screen() {
    float v0[2] = {0.0f, 0.0f};
    float v1[2] = {160.0f, 0.0f};
    float v2[2] = {160.0f, 160.0f};
    rdpq_mode_combiner(RDPQ_COMBINER_FLAT);
    rdpq_set_fill_color((color_t){255, 255, 255, 0});
    rdpq_set_prim_color((color_t){255, 255, 255, 0});

    rdpq_triangle(
        &TRIFMT_FILL,
        v0, v1, v2
    );
}

void stop_game(char *msg, size_t len) {
    msg[len] = 0;
    assertf(0, msg);
}

void free_model_glue(T3DModel *model) {
    rspq_call_deferred((void (*)(void *))t3d_model_free, model);
}

void free_block_glue(rspq_block_t *block) {
    rspq_call_deferred((void (*)(void *))rspq_block_free, block);
}

