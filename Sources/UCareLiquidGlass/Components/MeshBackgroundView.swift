import SwiftUI
import UIKit

struct MeshBackgroundView: View {
    @EnvironmentObject private var parallax: ParallaxMotion
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private static var wallpaperUIImage: UIImage? {
        let bundle = Bundle.main
        if let img = UIImage(named: "backdrop_wallpaper", in: bundle, compatibleWith: nil) { return img }
        if let img = UIImage(named: "backdrop_wallpaper") { return img }
        if let url = bundle.url(forResource: "backdrop_wallpaper", withExtension: "png") {
            return UIImage(contentsOfFile: url.path)
        }
        return nil
    }

    private static var hasWallpaperAsset: Bool { wallpaperUIImage != nil }

    var body: some View {
        ZStack {
            wallpaperBase
                .offset(
                    x: reduceMotion ? 0 : CGFloat(parallax.roll * 6),
                    y: reduceMotion ? 0 : CGFloat(parallax.pitch * 5)
                )

            TimelineView(.animation(minimumInterval: reduceMotion ? 1.0 / 10.0 : 1.0 / 30.0, paused: false)) { timeline in
                let t = timeline.date.timeIntervalSinceReferenceDate
                meshOverlays(at: t)
            }
        }
        .ignoresSafeArea()
    }

    @ViewBuilder
    private var wallpaperBase: some View {
        if let ui = Self.wallpaperUIImage {
            Image(uiImage: ui)
                .resizable()
                .scaledToFill()
                .frame(minWidth: 0, minHeight: 0)
                .scaleEffect(1.12)
                .blur(radius: reduceMotion ? 36 : 58)
                .saturation(0)
                .overlay {
                    // Dark neutral scrim — premium B&W read (no color cast).
                    LinearGradient(
                        colors: [
                            Color.black.opacity(0.34),
                            Color.black.opacity(0.24),
                            Color.black.opacity(0.32),
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                }
        } else {
            ProceduralLiquidBackdropView()
                .blur(radius: reduceMotion ? 28 : 42)
        }
    }

    private func meshOverlays(at t: TimeInterval) -> some View {
        let shiftX = reduceMotion ? 0 : CGFloat(parallax.roll * 8)
        let shiftY = reduceMotion ? 0 : CGFloat(parallax.pitch * 8)
        let slow = reduceMotion ? 0 : t * 0.04
        let wobble = sin(slow)
        let layerOpacity = Self.hasWallpaperAsset ? 0.28 : 0.85

        return ZStack {
            // Monochrome mesh — no sage / terracotta / yellow tint on the backdrop.
            RadialGradient(
                colors: [
                    Color(white: 0.88).opacity((0.11 + 0.035 * wobble) * layerOpacity),
                    .clear,
                ],
                center: UnitPoint(x: 0.18 + shiftX / 240, y: 0.22 + CGFloat(sin(slow * 0.6)) * 0.04),
                startRadius: 20,
                endRadius: 420
            )
            .blendMode(.softLight)

            RadialGradient(
                colors: [
                    Color.white.opacity((0.09 + 0.025 * sin(slow * 0.85)) * layerOpacity),
                    .clear,
                ],
                center: UnitPoint(x: 0.88 + CGFloat(cos(slow * 0.5)) * 0.05, y: 0.78 + shiftY / 300),
                startRadius: 28,
                endRadius: 460
            )
            .blendMode(.plusLighter)

            RadialGradient(
                colors: [
                    Color.white.opacity(0.065 * layerOpacity),
                    .clear,
                ],
                center: UnitPoint(x: 0.55 + shiftX / 280, y: 0.42 + 0.03 * cos(slow * 0.45)),
                startRadius: 40,
                endRadius: 520
            )
            .blendMode(.softLight)

            RadialGradient(
                colors: [
                    Color.white.opacity((0.035 + 0.018 * sin(slow * 0.55)) * layerOpacity),
                    .clear,
                ],
                center: UnitPoint(x: 0.72 + shiftX / 320, y: 0.92 + shiftY / 400),
                startRadius: 10,
                endRadius: 220
            )
            .blendMode(.plusLighter)
        }
    }
}

/// Fallback when `backdrop_wallpaper.png` is absent — reads as liquid metal, not flat black.
private struct ProceduralLiquidBackdropView: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        Group {
            if reduceMotion {
                staticLiquid
            } else {
                TimelineView(.animation(minimumInterval: 1.0 / 20.0, paused: false)) { timeline in
                    let t = timeline.date.timeIntervalSinceReferenceDate
                    animatedLiquid(at: t)
                }
            }
        }
    }

    private var staticLiquid: some View {
        animatedLiquid(at: 0)
    }

    private func animatedLiquid(at t: TimeInterval) -> some View {
        let wobble = sin(t * 0.15)
        let drift = cos(t * 0.11)
        return ZStack {
            LinearGradient(
                colors: [
                    Color(hex: 0x121418),
                    Color(hex: 0x0A0B0E),
                    Color(hex: 0x101116),
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            RadialGradient(
                colors: [
                    Color(white: 0.22).opacity(0.48),
                    Color(white: 0.08).opacity(0.12),
                    .clear,
                ],
                center: UnitPoint(x: 0.22 + drift * 0.06, y: 0.28 + wobble * 0.05),
                startRadius: 20,
                endRadius: 520
            )
            .blendMode(.screen)

            RadialGradient(
                colors: [
                    Color.white.opacity(0.13),
                    Color(white: 0.5).opacity(0.06),
                    .clear,
                ],
                center: UnitPoint(x: 0.88 + wobble * 0.04, y: 0.72 + drift * 0.05),
                startRadius: 10,
                endRadius: 480
            )
            .blendMode(.plusLighter)

            RadialGradient(
                colors: [
                    Color.white.opacity(0.1),
                    Color.white.opacity(0.05),
                    .clear,
                ],
                center: UnitPoint(x: 0.52 + drift * 0.08, y: 0.18 + wobble * 0.04),
                startRadius: 4,
                endRadius: 320
            )
            .blendMode(.softLight)

            LinearGradient(
                colors: [
                    Color.white.opacity(0.06),
                    .clear,
                    Color.white.opacity(0.035),
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .blendMode(.overlay)
        }
    }
}
