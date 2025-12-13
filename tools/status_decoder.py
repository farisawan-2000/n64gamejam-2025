
flags = {
    0: "SP_CLR_HALT", #/* clear halt */
    1: "SP_SET_HALT", #/*   set halt */
    2: "SP_CLR_BROKE", #/* clear broke */
    3: "SP_CLR_INTR", #/* clear interrupt */
    4: "SP_SET_INTR", #/*   set interrupt */
    5: "SP_CLR_SSTEP", #/* clear sstep */
    6: "SP_SET_SSTEP", #/*   set sstep */
    7: "SP_CLR_INTR_BREAK", #/* clear interrupt on break */
    8: "SP_SET_INTR_BREAK", #/*   set interrupt on break */
    9: "SP_CLR_SIG0", #/* clear signal 0 */
    10: "SP_SET_SIG0", #*   set signal 0 */
    11: "SP_CLR_SIG1", #* clear signal 1 */
    12: "SP_SET_SIG1", #*   set signal 1 */
    13: "SP_CLR_SIG2", #* clear signal 2 */
    14: "SP_SET_SIG2", #*   set signal 2 */
    15: "SP_CLR_SIG3", #* clear signal 3 */
    16: "SP_SET_SIG3", #*   set signal 3 */
    17: "SP_CLR_SIG4", #* clear signal 4 */
    18: "SP_SET_SIG4", #*   set signal 4 */
    19: "SP_CLR_SIG5", #* clear signal 5 */
    20: "SP_SET_SIG5", #*   set signal 5 */
    21: "SP_CLR_SIG6", #* clear signal 6 */
    22: "SP_SET_SIG6", #*   set signal 6 */
    23: "SP_CLR_SIG7", #* clear signal 7 */
    24: "SP_SET_SIG7", #*   set signal 7 */
}

import sys

value = int(sys.argv[1], 16)

for i in range(32):
    if value & 1:
        print(f"{flags[i]} | ", end="")
    value >>= 1
