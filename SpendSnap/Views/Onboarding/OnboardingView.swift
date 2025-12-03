//
//  OnboardingView.swift
//  SpendSnap
//
//  Created by Codex on 04/06/2025.
//

import SwiftUI
import SwiftData

private struct OnboardingPage: Identifiable {
    let id = UUID()
    let title: String
    let subtitle: String
    let imageName: String
}

struct OnboardingView: View {
    @Bindable var settings: Settings
    @Environment(\.modelContext) private var modelContext
    
    @State private var pageIndex: Int = 0
    @State private var pulse: Bool = false
    @State private var showTitle: Bool = false
    @State private var showSubtitle: Bool = false
    @State private var showImage: Bool = false
    @State private var showCTA: Bool = false
    
    private let pages: [OnboardingPage] = [
        .init(
            title: "Hard to keep track?",
            subtitle: "Receipts, cards, and cash scattered across the month.",
            imageName: "problem1"
        ),
        .init(
            title: "Budgets slip away",
            subtitle: "Spikes mid-month and surprise expenses ruin the plan.",
            imageName: "problem2"
        ),
        .init(
            title: "Card dues sneak up",
            subtitle: "Different cycles and due dates make payments easy to miss.",
            imageName: "problem3"
        ),
        .init(
            title: "Meet SpendWise",
            subtitle: "Budget by category, track weekly pace, and never miss a card due date.",
            imageName: "solution"
        )
    ]
    
    private var isLastPage: Bool {
        pageIndex == pages.count - 1
    }
    
    var body: some View {
        VStack(spacing: 24) {
            TabView(selection: $pageIndex) {
                ForEach(Array(pages.enumerated()), id: \.offset) { idx, page in
                    pageView(page)
                        .padding(.horizontal)
                        .tag(idx)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .always))
            
            actionButtons
                .padding(.horizontal)
                .padding(.bottom, 12)
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true)) {
                pulse.toggle()
            }
            startPageAnimation()
        }
        .onChange(of: pageIndex) { 
            startPageAnimation()
        }
    }
    
    private func pageView(_ page: OnboardingPage) -> some View {
        return VStack(spacing: 18) {
            VStack(spacing: 10) {
                Text(page.title)
                    .font(.system(size: 24, weight: .semibold))
                    .multilineTextAlignment(.center)
                    .opacity(showTitle ? 1 : 0)
                    .offset(y: showTitle ? 0 : -24)
                Text(page.subtitle)
                    .font(.system(size: 16, weight: .regular))
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .opacity(showSubtitle ? 1 : 0)
                    .offset(x: showSubtitle ? 0 : -28)
            }
            .padding(.horizontal)
            
            Image(page.imageName)
                .resizable()
                .scaledToFit()
                .frame(maxWidth: .infinity)
                .clipShape(
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                )
                .opacity(showImage ? 1 : 0)
                .offset(x: showImage ? 0 : 28)
        }
    }
    
    private var actionButtons: some View {
        VStack(spacing: 12) {
            Button {
                if isLastPage {
                    completeOnboarding()
                } else {
                    withAnimation { pageIndex += 1 }
                }
            } label: {
                Text(isLastPage ? "Get started" : "Next")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.primary, in: RoundedRectangle(cornerRadius: 14))
                    .foregroundStyle(.white)
                    .scaleEffect(pulse ? 1.02 : 0.98)
                    .opacity(showCTA ? 1 : 0)
                    .offset(y: showCTA ? 0 : 26)
            }
            
        }
    }
    
    private func completeOnboarding() {
        settings.onboardingComplete = true
        try? modelContext.save()
    }
    
    private func resetStages() {
        showTitle = false
        showSubtitle = false
        showImage = false
        showCTA = false
    }
    
    @State private var animationTask: Task<Void, Never>?

    private func startPageAnimation() {
        animationTask?.cancel()
        resetStages()

        animationTask = Task { @MainActor in
            try? await Task.sleep(for: .milliseconds(100))
            withAnimation(.easeOut(duration: 0.55)) { showTitle = true }

            try? await Task.sleep(for: .milliseconds(160))
            withAnimation(.easeOut(duration: 0.55)) { showSubtitle = true }

            try? await Task.sleep(for: .milliseconds(180))
            withAnimation(.easeOut(duration: 0.55)) { showImage = true }

            try? await Task.sleep(for: .milliseconds(180))
            withAnimation(.easeOut(duration: 0.55)) { showCTA = true }
        }
    }

}

#Preview {
    let container = try! ModelContainer(for: Settings.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true))
    let settings = Settings()
    return OnboardingView(settings: settings)
        .modelContainer(container)
}
