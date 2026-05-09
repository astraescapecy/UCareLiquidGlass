import Foundation

/// Builds today's protocol from selected `UCareFocus` values (local heuristic until AI backend ships).
enum ProgramBuilder {
    private struct Template {
        let id: String
        let title: String
        let details: String
        let segment: DaySegment
        let icon: String
        let estimatedSeconds: Int?
        let scienceBlurb: String
        /// Step is included if user selected any of these. Empty = always include (core habit).
        let anyOf: Set<UCareFocus>
    }

    private static let templates: [Template] = [
        Template(
            id: "core_water_am",
            title: "Drink 500ml water before caffeine",
            details: "Plain water first; caffeine second if you want it.",
            segment: .morning,
            icon: "drop.fill",
            estimatedSeconds: nil,
            scienceBlurb: "Rehydration after sleep supports saliva, skin turgor, and energy — simple, high leverage.",
            anyOf: []
        ),
        Template(
            id: "core_winddown_pm",
            title: "Digital wind-down",
            details: "No doom-scroll in the last 30 minutes before lights-out.",
            segment: .evening,
            icon: "moon.stars.fill",
            estimatedSeconds: nil,
            scienceBlurb: "Evening light and stimulation affect melatonin timing; a softer landing helps sleep onset.",
            anyOf: []
        ),
        Template(
            id: "tongue_scrape_am",
            title: "Tongue scrape",
            details: "Gentle strokes from back to front; rinse the scraper.",
            segment: .morning,
            icon: "mouth",
            estimatedSeconds: 15,
            scienceBlurb: "Tongue coating harbors volatile compounds linked to mouth odor — scraping reduces bacterial load (mechanical, not a cure-all).",
            anyOf: [.fresherBreathOralHealth, .tasteBetterIntimateOral, .smellBetterNaturally]
        ),
        Template(
            id: "cold_face_plunge",
            title: "Cold water face plunge",
            details: "Splash cool water on clean skin for 30 seconds; pat dry.",
            segment: .morning,
            icon: "snowflake",
            estimatedSeconds: 30,
            scienceBlurb: "Brief cold exposure can increase alertness and transiently affect superficial circulation (sensation and puffiness).",
            anyOf: [.betterSkinClearAcne, .moreConfidenceBody, .glowUpBeforeDate]
        ),
        Template(
            id: "pineapple_midday",
            title: "Eat one cup of pineapple",
            details: "Fresh or frozen thawed; with food if your stomach is sensitive.",
            segment: .midday,
            icon: "leaf.circle",
            estimatedSeconds: nil,
            scienceBlurb: "Pineapple contains bromelain (enzyme). Evidence for “taste” claims is limited — it’s a sensible whole-food habit, not magic.",
            anyOf: [.tasteBetterIntimateOral, .smellBetterNaturally, .betterGutLessBloat]
        ),
        Template(
            id: "sun_skin_5min",
            title: "5 minutes of sun on skin",
            details: "Arms or face, sensible UV; skip if your derm advised otherwise.",
            segment: .midday,
            icon: "sun.max.fill",
            estimatedSeconds: 300,
            scienceBlurb: "UVB helps vitamin D synthesis; brief exposure is a pragmatic nudge — use sunscreen if you’ll be out longer.",
            anyOf: [.betterSkinClearAcne, .sleepBetter, .moreConfidenceBody]
        ),
        Template(
            id: "hydration_checkin",
            title: "Hydration check-in",
            details: "Finish your bottle once; note how you feel (energy, mouth feel).",
            segment: .midday,
            icon: "drop.circle",
            estimatedSeconds: nil,
            scienceBlurb: "Even mild dehydration can worsen dry mouth and dull skin appearance.",
            anyOf: [.drinkMoreWaterHydration, .fresherBreathOralHealth]
        ),
        Template(
            id: "double_cleanse_pm",
            title: "Double-cleanse skincare",
            details: "Oil or balm first, then gentle cleanser; 4 minutes total.",
            segment: .evening,
            icon: "bubbles.and.sparkles",
            estimatedSeconds: 240,
            scienceBlurb: "First pass removes sunscreen/sebum; second pass cleans skin without aggressive scrubbing.",
            anyOf: [.betterSkinClearAcne, .glowUpBeforeDate]
        ),
        Template(
            id: "scalp_rosemary",
            title: "Scalp massage with rosemary oil",
            details: "Dilute a few drops in carrier oil; massage in gentle circles.",
            segment: .evening,
            icon: "hand.point.up.left.and.text",
            estimatedSeconds: 120,
            scienceBlurb: "Some trials suggest rosemary oil may support hair density comparable to minoxidil for androgenetic alopecia — results vary; patch test first.",
            anyOf: [.healthierHair]
        ),
        Template(
            id: "dry_brush",
            title: "Dry brushing — body",
            details: "Light strokes toward the heart; don’t abrade sensitive skin.",
            segment: .evening,
            icon: "hand.raised.fill",
            estimatedSeconds: 90,
            scienceBlurb: "Mostly exfoliation + circulation sensation; keep pressure gentle to avoid barrier damage.",
            anyOf: [.moreConfidenceBody, .betterSkinClearAcne, .glowUpBeforeDate]
        ),
        Template(
            id: "floss_tongue_bed",
            title: "Floss + tongue scrape",
            details: "Floss contacts; finish with a quick tongue pass.",
            segment: .beforeBed,
            icon: "mouth",
            estimatedSeconds: 120,
            scienceBlurb: "Plaque between teeth contributes to odor-producing bacteria; nightly removal is high leverage.",
            anyOf: [.fresherBreathOralHealth, .tasteBetterIntimateOral]
        ),
        Template(
            id: "magnesium_zinc_optional",
            title: "Magnesium glycinate (optional)",
            details: "Only if you opted in and it fits your clinician’s advice.",
            segment: .beforeBed,
            icon: "pills.fill",
            estimatedSeconds: nil,
            scienceBlurb: "Magnesium is commonly used for sleep support; evidence quality varies — not medical advice.",
            anyOf: [.sleepBetter, .sexualWellnessBed]
        ),
        Template(
            id: "lights_down_reminder",
            title: "Lights-down 30 minutes before sleep",
            details: "Dim screens; swap to reading, stretch, or breathwork.",
            segment: .beforeBed,
            icon: "lightbulb.slash.fill",
            estimatedSeconds: nil,
            scienceBlurb: "Bright light at night delays melatonin onset; dimming supports sleep pressure.",
            anyOf: [.sleepBetter]
        ),
        Template(
            id: "fiber_meal",
            title: "One fiber-forward meal",
            details: "Beans, oats, veg, or fruit — pick what you’ll actually eat.",
            segment: .midday,
            icon: "carrot.fill",
            estimatedSeconds: nil,
            scienceBlurb: "Fiber supports regular bowel habits and microbiome diversity — relevant to bloating and odor.",
            anyOf: [.betterGutLessBloat, .smellBetterNaturally]
        ),
        Template(
            id: "posture_reset",
            title: "2-minute posture reset",
            details: "Wall angels or thoracic extension; slow breathing.",
            segment: .midday,
            icon: "figure.stand",
            estimatedSeconds: 120,
            scienceBlurb: "Short movement breaks reduce stiffness cues that read as low confidence.",
            anyOf: [.moreConfidenceBody, .glowUpBeforeDate]
        ),
        Template(
            id: "intimate_confidence_note",
            title: "Intimate confidence check-in",
            details: "Private note: one thing that felt good today (no pressure to share).",
            segment: .evening,
            icon: "heart.text.square",
            estimatedSeconds: nil,
            scienceBlurb: "Self-efficacy tracks with consistent micro-wins; this is behavioral, not clinical treatment.",
            anyOf: [.sexualWellnessBed, .moreConfidenceBody, .tasteBetterIntimateOral]
        ),
    ]

    static func buildSteps(for focuses: Set<UCareFocus>) -> [ProgramStep] {
        let core: Set<UCareFocus> = focuses.isEmpty ? [.moreConfidenceBody] : focuses
        var picked: [ProgramStep] = []
        for t in templates {
            if t.anyOf.isEmpty || !t.anyOf.isDisjoint(with: core) {
                picked.append(
                    ProgramStep(
                        id: t.id,
                        title: t.title,
                        details: t.details,
                        segment: t.segment,
                        iconSystemName: t.icon,
                        estimatedSeconds: t.estimatedSeconds,
                        scienceBlurb: t.scienceBlurb
                    )
                )
            }
        }
        let order: [DaySegment] = [.morning, .midday, .evening, .beforeBed]
        picked.sort { a, b in
            let ia = order.firstIndex(of: a.segment) ?? 0
            let ib = order.firstIndex(of: b.segment) ?? 0
            if ia != ib { return ia < ib }
            return a.title < b.title
        }
        return Array(picked.prefix(10))
    }
}
