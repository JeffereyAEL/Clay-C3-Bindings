module gymcommit::gc::etsp;

import clay;
import gymcommit::gc;
import std::io;

bool isFilterOptionHovered @private = false;
bool isFilterButtonHovered @private = false;

ExerciseTag currentFilterTag = ExerciseTag.NONE;

ClayVector2 prevExerciseListContainerScrollPosition;

fn void handleTagFilterOption(ElementId elementId, PointerData pointerData, iptr args)
{
    if (pointerData.state == PointerState.RELEASED_THIS_FRAME)
    {
        currentFilterTag = (ExerciseTag)(ushort)args;
        isFilterOptionHovered = false;
        isFilterButtonHovered = false;
    }
}   

fn void handleBackButton(ElementId elementId, PointerData pointerData, iptr args)
{
    if (pointerData.state == PointerState.RELEASED_THIS_FRAME)
    {
        gc::currentPage = &wp::page;
    }
}

fn void handleExerciseTypeSelection(ElementId elementId, PointerData pointerData, iptr args)
{
    ScrollContainerData data = clay::getScrollContainerData(clay::getElementId("ExerciseListContainer"));
    if (pointerData.state == PointerState.PRESSED_THIS_FRAME) {
        prevExerciseListContainerScrollPosition = *data.scrollPosition;
    } else {
        bool same_pos = prevExerciseListContainerScrollPosition.x == data.scrollPosition.x && prevExerciseListContainerScrollPosition.y == data.scrollPosition.y;
        if (pointerData.state == PointerState.RELEASED_THIS_FRAME && same_pos && args > 0)
        {
            ExerciseType type = (ExerciseType)(ushort)args;
            wp::exercises.append({ .type = type });
            gc::currentPage = &wp::page;
        }
    }
}

fn void filterOptionButton(bool isCurrentFilter, ExerciseTag exerciseTag)
{
    @clay(
        clay::layout({
            .sizing = { 
                .width = clay::sizingGrow(),
                .height = clay::sizingFixed(35) 
            },
            .childAlignment = {
                .x = AlignX.RIGHT,
                .y = AlignY.CENTER
            },
            .padding = clay::padding(5, 5)
        }),
        clay::@bodyIf(
            clay::hovered() || isCurrentFilter, 
            clay::rectangle({
                .color = isCurrentFilter ? gc::ORANGE_FIRE : gc::GRAY_LIGHT,
                .cornerRadius = clay::cornerRadiusUni(8)
            })
        ),
    ){
        clay::onHover(&handleTagFilterOption, (iptr)(ushort)exerciseTag);
        clay::text(
            exerciseTag == ExerciseTag.NONE ? "Off" : exerciseTag.name,
            clay::textConfig({
                .textColor = (isCurrentFilter || clay::hovered()) ? gc::BLACK : gc::BEIGE,
                .fontSize = 24
            })
        );
    };
}

fn void page()
{
    @clay(
        clay::id("HeaderBar"),
        clay::layout({
            .sizing = {
                .width = clay::sizingGrow(),
                .height = clay::sizingFit()
            },
            .layoutDirection = LayoutDirection.LEFT_TO_RIGHT
        }),
    ) {
        @clay(
            clay::id("PusherFilterButton"),
            clay::layout({
                .sizing = { .width = clay::sizingGrow() }
            }),
        ) {};
        // FILTER BUTTON
        @clay(
            clay::id("FilterButton"),
            clay::rectangle({
                .color = clay::hovered() ? gc::ORANGE_FIRE : gc::PURPLE,
                .cornerRadius = clay::cornerRadiusUni(8)
            }),
            clay::layout({
                .sizing = {
                    .width = clay::sizingFit(),
                    .height = clay::sizingGrow()
                },
                .padding = clay::paddingUni(8)
            }),
        ) {
            // FILTER BUTTON OPTIONS POPUP
            if (isFilterButtonHovered || isFilterOptionHovered)
            {
                @clay(
                    clay::id("FilterButtonOptionsPopup"),
                    clay::floating({
                        .attachment = {
                            .parent = AttachPoint.RIGHT_BOTTOM
                        },
                        .offset = { -120, 0 }
                    }),
                    clay::rectangle({
                        .color = gc::PURPLE,
                        .cornerRadius = clay::cornerRadiusUni(8)
                    }),
                    clay::layout({
                        .sizing = {
                            .width = clay::sizingFixed(120),
                            .height = clay::sizingFit()
                        },
                        .layoutDirection = LayoutDirection.TOP_TO_BOTTOM,
                        .childGap = 3,
                        .padding = clay::padding(5, 5)
                    }),
                ) {

                    bool is_current_filter;
                    isFilterOptionHovered = clay::hovered();
                    foreach(ExerciseTag tag : ExerciseTag.values)
                    {
                        is_current_filter = currentFilterTag == tag;
                        filterOptionButton(is_current_filter, tag);
                    }
                };
            }   
            isFilterButtonHovered = clay::hovered();
            // FILTER BUTTON TEXT
            String filter_button_string = "Filter: ".tconcat(currentFilterTag == ExerciseTag.NONE ? "Off" : currentFilterTag.name);
            clay::text(
                filter_button_string,
                clay::textConfig({
                    .fontId = gc::FONT_ID_BODY_16,
                    .textColor = clay::hovered() ? gc::BLACK : gc::BEIGE,
                    .fontSize = 24,
                    .wrapMode = WrapMode.NONE
                }),
            );
        };
    };

    // EXERCISE LIST CONTAINER
    @clay(
        clay::id("ExerciseListContainer"),
        clay::scroll({ .vertical = true }),
        clay::layout({ 
            .layoutDirection = LayoutDirection.TOP_TO_BOTTOM,
            .sizing = {
                .width = clay::sizingGrow(),
                .height = clay::sizingGrow()
            },
            .padding = clay::padding(10, 16),
            .childGap = 8
        }),
    ) {
        clay::onHover(&handleExerciseTypeSelection, -1);
        foreach (ExerciseType type : ExerciseType.values)
        {   
            if (currentFilterTag != ExerciseTag.NONE && type.tag != currentFilterTag) continue;
            if (type == ExerciseType.NONE) continue;
            @clay(
                clay::rectangle({
                    .color = clay::hovered() ? gc::GRAY_LIGHT : gc::GRAY,
                    .cornerRadius = clay::cornerRadiusUni(8),
                }),
                clay::layout({
                    .sizing = { clay::sizingGrow(), clay::sizingFit() },
                    .childAlignment = widgets::alignmentButton(),
                    .layoutDirection = LayoutDirection.LEFT_TO_RIGHT,
                    .padding = clay::padding(16, 8),
                }),
            ) {
                clay::onHover(&handleExerciseTypeSelection, (iptr)(ushort)type);
                clay::text(
                    type.name,
                    clay::textConfig({
                        .fontId = gc::FONT_ID_BODY_16,
                        .textColor = clay::hovered() ? gc::BLACK : gc::BEIGE,
                        .fontSize = 24,
                }));
                @clay(clay::layout({ .sizing = { .width = clay::sizingGrow() } })) {};
                clay::text(
                    type.tag.name,
                    clay::textConfig({
                        .fontId = gc::FONT_ID_BODY_16,
                        .textColor = clay::hovered() ? gc::BLACK : gc::BEIGE,
                        .fontSize = 24,
                }));
            };
        }
    };

    widgets::floatingButton(
        "Back", 
        &handleBackButton,
        { 8, -8 },
        { 
            .element = AttachPoint.LEFT_BOTTOM, 
            .parent = AttachPoint.LEFT_BOTTOM 
    });
}