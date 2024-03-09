# CSS 422, Implemented by the 422Group
__Programmers:__ Andrew Lim, Kayden Grant, Rod Hoda <br />
__Program:__ Thumb-2 Implementation Work of Memory/Time-Related C Standard Library Functions <br />
__Quarter:__ Winter 2024, UW Bothell <br />
__Faculty:__ Dr. Ahmed Awad <br />

## Objective 
You’ll understand the following concepts at the ARM assembly language level through this final project 
that implements memory/time-related C standard library functions in Thumb-2. <br />
• CPU operating modes: user and supervisor modes <br />
• System-call and interrupt handling procedures <br />
• C to assembler argument passing (APCS: ARM Procedure Call Standard) <br />
• Stack operations to implement recursions at the assembly language level <br />
• Buddy memory allocation <br />

## Project Overview 
Using the Thumb-2 assembly language, you will implement several functions of the C standard library that 
will be invoked from a C program named driver.c. See Table 1. These functions must be code in the Thumb
2 assembly language. Some of them can be implemented in stdlib.s running in the unprivileged thread mode 
(=user mode), whereas the others need to be implemented as supervisor calls, (i.e., in the handler mode = 
supervisor mode). For more details, log in one of the CSS Linux servers and type from the Linux shell: 
where function is either bezro, strncpy, malloc, free, signal, or alarm

## Program Flow Diagram
![ProgramFlowDiagram](https://github.com/andrewlim0619/CSS422_Thumb2_Final_Project/blob/main/Support_Files/CSS%20422.png?raw=true)
