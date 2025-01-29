# Clay-C3-Bindings
C3 Bindings for [Clay](https://github.com/nicbarker/clay.git), a UI layout library written in C

## TODO:
- Find out how to build a static-lib with additional C sources

## DONE:
### - C3 macros
Traditional Clay C Macro System

```cpp
/* FILTER BUTTON */
CLAY(
    CLAY_ID("FilterButton"),
    Clay_Hovered() ? CLAY_RECTANGLE({
        .color = Clay_Hovered() ? FIRE_ORANGE : (Clay_Color){80, 25, 200, 255},
        .cornerRadius = 8,
    }) : 0,
    CLAY_LAYOUT({
        .sizing = {
            .width = CLAY_SIZING_FIT(),
            .height = CLAY_SIZING_GROW()
        },
        .padding = 10
    }) 
) {
    // define children...
}
```

Clay C3 Macro System
```cpp
/* FILTER BUTTON */
clay::clay(
    clay::id("FilterButton"),
    clay::@bodyIf(clay::hovered(), clay::rectangle({
            .color = clay::hovered() ? FIRE_ORANGE : {80, 25, 200, 255},
            .cornerRadius = clay::cornerRadiusUni(8)
        })
    ),
    clay::layout({
        .sizing = {
            .width = clay::sizingFit(),
            .height = clay::sizingGrow()
        },
        .padding = clay::paddingUni(8)
    })
){
    // define children...
};
```

## RESOURCES:
### - [Clay](https://github.com/nicbarker/clay.git) (C-Layout Library)
### - [C3](https://github.com/c3lang/c3c.git) (A C-a-like, that aims to bring modern language QA features and a revamped Macro system to C)
### - [Raylib](https://github.com/raysan5/raylib.git) (C Videogame and Graphical API)
### - [Lexend](https://github.com/googlefonts/lexend.git) (Accessible/ Dyslexic Friendly Font)

