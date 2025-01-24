# Clay-C3-Bindings
C3 Bindings for [Clay](https://github.com/nicbarker/clay.git), a UI layout library written in C

This project is stable in functionality, not in API. I haven't fully settled on standardizing the names of enums/inline getters and C3's dictated naming conventions only make me more likely to fiddle with them till I am happy.
I also had to rewrite the lovely work of of the contributors who made the (semi?)official clay-raylib-bindings. I was frustrated and not finding the raylibmath vendor library and just hastelly rewrote the entire file into a .c3 file because trying to render *any* text crashed the application.

## TODO:
- cleanup the ClayIterator Methods
- fully implement debugging with C3's optionals? Since I try not to return from ClayIterator chains this may not be possible/useful
- refactor ClayIterator flag checking and tracking,
    I should wrap them in their related Clay C method calls, and not by-hand ever time they're needed within the ClayIterator methods

## DONE:
### - `ClayIterator *` Method System
Traditional Clay C Macro System

```cpp
/* FILTER BUTTON */
CLAY(
    CLAY_ID("FilterButton"),
    CLAY_RECTANGLE({
        .color = Clay_Hovered() ?  
            FIRE_ORANGE : 
            (Clay_Color){80, 25, 200, 255},
        .cornerRadius = 8,
    }),
    CLAY_LAYOUT({
        .sizing = {
            .width = CLAY_SIZING_FIT(),
            .height = CLAY_SIZING_GROW()
        },
        // .childAlignment = CLAY_ALIGNMENT_TEXT,
        .padding = 10
    }) 
) { // ...
```

My attempt at mimicing those macros with some backend magic
```cpp
/* FILTER BUTTON */
clay::clay()
    .id("FilterButton")
    .rectangle({
        .color = clay::hovered() ? FIRE_ORANGE : {80, 25, 200, 255},
        .cornerRadius = clay::cornerRadius(8)
    })
    .layout({
        .sizing = {
            .width = clay::sizingFit(),
            .height = clay::sizingGrow()
        },
        .padding = clay::paddingUni(8)
    })
.children();
    // FILTER BUTTON OPTIONS POPUP
    if (isFilterButtonHovered || isFilterOptionHovered)
    { // ...
```

C3 has a powerful macro system, but it's very confined to scoped `macro`s. So to try and keep mostly the same syntax I created an iterator system that takes advatage of C3's type assoicated methods

![image](https://github.com/user-attachments/assets/103aa02c-acee-448b-996a-e13f7b8f078b)

[C3-language Documentation Here](https://c3-lang.org/language-fundamentals/functions/#methods)
### - Completed itegrating all element config C-Macros into C3 ClayIterator methods/functions and most others
    - CLAY_LAYOUT, CLAY_RECTANGLE, CLAY_TEXT, CLAY_FLOATING, etc...
    - *most* of the helper macros; CLAY_ID, CLAY_SIZING_GROW/FIT/FIXED/PERCENT
    - interop C3 structs for the vast majority (if not all) structs defined within Clay
### - Some debug tools, set `const bool clay::DEBUG_PRINT_HIERARCHY` to true to compile the iterator with hierarchy print statements
## RESOURCES:
### - [Clay](https://github.com/nicbarker/clay.git) (C-Layout Library)
### - [C3](https://github.com/c3lang/c3c.git) (A C-a-like, that aims to bring modern language QA features and a revamped Macro system to C)
### - [Raylib](https://github.com/raysan5/raylib.git) (C Videogame and Graphical API)
### - [Lexend](https://github.com/googlefonts/lexend.git) (Accessible/ Dyslexic Friendly Font)

