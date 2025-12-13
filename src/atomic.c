#include <stdbool.h>
#include <stdint.h>

uint64_t __atomic_fetch_xor_8(volatile void *ptr, uint64_t value, int memorder) {
    uint64_t ret = *(uint64_t *)ptr;

    return ret ^ value;
}

uint64_t __atomic_load_8(volatile void *ptr, int order) {
    uint32_t *ptru32 = (uint32_t *)ptr;

    uint64_t ret = 0;

    ret  = ((uint64_t)__atomic_load_4(&ptru32[0], order)) << 32;
    ret |= __atomic_load_4(&ptru32[1], order);

    return ret;
}

bool __atomic_compare_exchange_8(volatile void *ptr,
    void *expected, uint64_t desired,
    bool a, int success, int failure
) {
    uint64_t value = *(uint64_t *)ptr;
    if (value == *(uint64_t *)ptr) {
        *(uint64_t *)ptr = desired;
        return true;
    } else {
        return false;
    }
}

void __atomic_store_8(volatile void *ptr, uint64_t value, int memorder) {
    *(uint64_t *)ptr = value;
}
