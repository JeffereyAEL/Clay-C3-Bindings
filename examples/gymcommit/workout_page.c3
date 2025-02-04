module gymcommit::gc::wp;

import clay;
import gymcommit::gc;

fn void handleAddExerciseButton(ElementId elementId, PointerData pointerData, iptr args)
{
    if (pointerData.state == PointerState.RELEASED_THIS_FRAME)
    {
        gc::currentPage = &etsp::page;
    }
}

ExerciseInstanceArray exercises; // IIZ safe

fn void handleAddSetButton(ElementId elementId, PointerData pointerData, iptr args)
{
    if (pointerData.state == PointerState.RELEASED_THIS_FRAME)
    {
        (&exercises[(uint)args]).sets.append({});
    }
}

fn void page()
{
    @clay(
        clay::id("ExerciseInstanceList"),
        clay::layout({ 
            .sizing = { clay::sizingGrow(), clay::sizingGrow() },
            .layoutDirection = LayoutDirection.TOP_TO_BOTTOM,
            .childGap = 8,
        }),
        clay::scroll({ .vertical = true }),
    ) {
        foreach(uint index, ExerciseInstance instance : exercises)
        {
            @clay(
                clay::idLocal(instance.type.name, index),
                clay::rectangle({
                    .color = gc::GRAY,
                    .cornerRadius = clay::cornerRadiusUni(8),
                }),
                clay::layout({
                    .sizing = { .width = clay::sizingGrow()},
                    // .childAlignment = widgets::alignmentButton(),
                    .padding = clay::paddingUni(8),
                    .layoutDirection = LayoutDirection.TOP_TO_BOTTOM,
                }),
                widgets::panner({ .left = {true} }),
            ) {
                @clay(
                    clay::idLocal("ExerciseInstanceHeader", index),
                    clay::layout({ 
                        .layoutDirection = LayoutDirection.LEFT_TO_RIGHT,
                        .sizing = { .width = clay::sizingGrow() },
                    }),
                ) {
                    clay::text(
                        instance.type.name,
                        clay::textConfig({
                            .fontId = gc::FONT_ID_BODY_16,
                            .textColor = gc::BEIGE,
                            .fontSize = 24,
                    }));
                    @clay(clay::layout({ .sizing = { .width = clay::sizingGrow() }})) {};
                    clay::text(
                        instance.type.tag.name,
                        clay::textConfig({
                            .fontId = gc::FONT_ID_BODY_16,
                            .textColor = gc::BEIGE,
                            .fontSize = 24,
                    }));
                };
                @clay(
                    clay::idLocal("ExerciseInstanceBody", index),
                    clay::layout({ 
                        .layoutDirection = LayoutDirection.LEFT_TO_RIGHT,
                        .childGap = 8,
                    }),
                ) {
                    @clay(
                        clay::layout({
                            .layoutDirection = LayoutDirection.TOP_TO_BOTTOM,
                            .childAlignment = { .x = AlignX.RIGHT },
                            .sizing = { .height = clay::sizingGrow() },
                            .padding = clay::paddingUni(8),
                        })
                    ) {
                        clay::text(
                            "weight:",
                            clay::textConfig({
                                .fontId = gc::FONT_ID_BODY_16,
                                .textColor = gc::BEIGE,
                                .fontSize = 18,
                        }));
                        @clay( clay::layout({ .sizing = { .height = clay::sizingGrow() }})) {};
                        clay::text(
                            "reps:",
                            clay::textConfig({
                                .fontId = gc::FONT_ID_BODY_16,
                                .textColor = gc::BEIGE,
                                .fontSize = 18,
                        }));
                    };
                    @clay(
                        clay::idLocal("ExerciseInstanceSetsList", index),
                        clay::layout({ 
                            .sizing = { .width = clay::sizingGrow() },
                            .childGap = 8
                        }),
                        clay::scroll({ .horizontal = true }),
                    ) {
                        foreach(ExerciseSet set : instance.sets)
                        {
                            @clay(
                                clay::layout({ 
                                    .sizing = { .width = clay::sizingFit(), .height = clay::sizingGrow() },
                                    .layoutDirection = LayoutDirection.TOP_TO_BOTTOM,
                                    .childAlignment = { .x = AlignX.CENTER },
                                    .padding = clay::paddingUni(8),
                                }),
                                clay::rectangle({ 
                                    .color = gc::GRAY_DARK,
                                    .cornerRadius = clay::cornerRadiusUni(8)
                                }),
                            ) {
                                clay::text(
                                    "0", // set.statisticA.to_str(),
                                    clay::textConfig({
                                        .fontId = gc::FONT_ID_BODY_16,
                                        .textColor = gc::BEIGE,
                                        .fontSize = 18,
                                }));
                                @clay( clay::layout({ .sizing = { .height = clay::sizingGrow() }})) {};
                                clay::text(
                                    "0", // set.statisticB.to_str(),
                                    clay::textConfig({
                                        .fontId = gc::FONT_ID_BODY_16,
                                        .textColor = gc::BEIGE,
                                        .fontSize = 18,
                                }));
                            };
                        }
                        @clay(
                            clay::idLocal("AddSetButton", index),
                            clay::rectangle({ 
                                .color = clay::hovered() ? gc::ORANGE_FIRE : gc::PURPLE,
                                .cornerRadius = clay::cornerRadiusUni(8)
                            }),
                            clay::layout({ 
                                .layoutDirection = LayoutDirection.LEFT_TO_RIGHT,
                                .sizing = { .height = clay::sizingGrow() },
                                .padding = clay::paddingUni(8),
                            })
                        ) {
                            clay::onHover(&handleAddSetButton, (iptr)index);
                            clay::text(
                                "+",
                                clay::textConfig({
                                    .fontId = gc::FONT_ID_BODY_16,
                                    .textColor = clay::hovered() ? gc::BLACK : gc::BEIGE,
                                    .fontSize = 47,
                            }));
                        };
                    };
                };
            };
        }
    };

    widgets::floatingButton(
        "Add Exercise",
        &handleAddExerciseButton,
        { -8, -8 },
        { 
            .element = AttachPoint.RIGHT_BOTTOM, 
            .parent = AttachPoint.RIGHT_BOTTOM 
    });
}