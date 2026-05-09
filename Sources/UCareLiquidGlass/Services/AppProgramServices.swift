import Foundation

/// Boundary for swapping local heuristics → remote AI later (spec §11).
protocol ProgramGenerating {
    func makeProgramSteps(for focuses: Set<UCareFocus>) -> [ProgramStep]
}

struct LocalProgramGenerator: ProgramGenerating {
    func makeProgramSteps(for focuses: Set<UCareFocus>) -> [ProgramStep] {
        ProgramBuilder.buildSteps(for: focuses)
    }
}

/// Swap `generator` for a remote-backed type (e.g. Supabase + model API) when the backend ships; `ProgramGenerating` stays the seam.
enum AppProgramServices {
    static var generator: ProgramGenerating = LocalProgramGenerator()
}
