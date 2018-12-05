/*
 * Filename: getFileCount.s
 * Author: Jason Chau
 * Userid: cs30fie
 * Description: This file is in charge of counting the total number of files in
 * a tree of files
 * Date: 11/28/18
 * Sources of Help: Piazza
 */

.syntax unified

.equ FP_OFFSET, 4
.equ PARAM_SPACE, 24
.equ CSIZE, -8
.equ CHILD, -12
.equ COUNT, -16
.equ COUNTER, -20

.text
.align 2
.global getFileCount

/*
 * Function name: getFilecount 
* Function prototype: int getFileCount(const struct fileInfo *fi)
 * Description: This funcion will defines the nameCompare funtion
 that is passed in as parameter for qsort() function used in the 
 PA4 program.
 * Parameters: p1 is a pointer to a struct
 * p2 is a pointer to a struct
 * Side Effects: None.
 * Error Conditions: None.
 * Return Value: 1, if name is smaller, 0 if same , -1 if name is larger
 * Registers Used: 
 *  r0 - childrensize
 *  r1 - children
 */

 /*
 int count = 0;
 int getFileCount (const struct fileInfo *fi) {
    if ( fi->children == NULL) {
    return 1;
    }
    for ( int x = 0; x < fi->childrenSize; x++) {
       count +=  getFileCount(&(fi->children[x]));
    }
    return count + 1;
 }
 
 */
getFileCount:
    @ Save caller's registers on the stack
    push {fp, lr}
    
    add     fp, sp, FP_OFFSET
    sub     sp, sp, PARAM_SPACE
   
    ldr     r0, [r0]                @dereference to get that table
    ldr     r3, =offset_children
    ldr     r3, [r3]
    ldr     r1, [r0, r3]            @get the children of the table
    str     r1, [fp, CHILD]
    ldr     r3, =offset_childrenSize 
    ldr     r0, [r0,r3]             @get the children size
    str     r0, [fp,CSIZE]

    ldr     r0, [fp, CHILD]
    ldr     r1, [fp, CSIZE]
    mov     r2, 0                   @r2 becomes the counter for for loop
    str     r2, [fp, COUNTER]
    cmp     r1, 0                   @compare children size with 0
    bne     for_loop                @go into for loop if it has children
    mov     r0, 1                   @return 1 if it has no children
    b       end

for_loop:                           @loop through all the children
    ldr     r0, [fp, CHILD]
    ldr     r1, [fp, CSIZE]
    ldr     r2, [fp,COUNTER]
    cmp     r2, r1                  @compare if x is < childrenSize                  
    bge     end_loop
    add     r0, r0, r2              @get the address of the children[x]
    bl      getFileCount            @recursive call
    ldr     r1, [fp, COUNT]         
    add     r0, r0, r1              @count+= getFileCount(&(fi->children[x])
    str     r0, [fp, COUNT]
    
    ldr     r2, [fp,COUNTER]
    add     r2, r2, 1               @x++
    str     r2, [fp, COUNTER]
    ldr     r1, [fp, CSIZE]         @see if continue loop if x < csize
    cmp     r2, r1
    blt     for_loop
     
end_loop:
    ldr    r0, [fp, COUNT]
    add    r0, r0, 1               @return count +1    

end: 
    sub sp, fp, FP_OFFSET

    Restore caller's registers
    pop {fp, pc}