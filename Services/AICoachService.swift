import Foundation

class AICoachService {

    func generateDebrief(for race: Race) async throws -> AIDebrief {
        let prompt = buildPrompt(for: race)

        let body: [String: Any] = [
            "model": "claude-opus-4-5",
            "max_tokens": 1024,
            "messages": [["role": "user", "content": prompt]]
        ]

        var request = URLRequest(url: URL(string: "https://api.anthropic.com/v1/messages")!)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("2023-06-01", forHTTPHeaderField: "anthropic-version")
        request.setValue(APIConfig.anthropicKey, forHTTPHeaderField: "x-api-key")
        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (data, _) = try await URLSession.shared.data(for: request)
        let response = try JSONDecoder().decode(AnthropicResponse.self, from: data)
        let text = response.content.first?.text ?? ""

        return parseDebrief(text: text, raceId: race.id)
    }

    private func buildPrompt(for race: Race) -> String {
        let duration = race.duration.map { formatDuration($0) } ?? "unknown"
        let laps = race.laps.compactMap(\.duration).map { formatDuration($0) }.joined(separator: ", ")

        return """
        You are an expert sailing coach analysing a dinghy race. Be concise, specific, and encouraging.

        Race: \(race.name)
        Boat: \(race.boat.boatClass.rawValue)
        Duration: \(duration)
        Max Speed: \(String(format: "%.1f", race.maxSpeed)) knots
        Avg Speed: \(String(format: "%.1f", race.avgSpeed)) knots
        Tacks: \(race.tackCount)
        Jibes: \(race.jibeCount)
        Laps: \(race.laps.count) — times: \(laps.isEmpty ? "not recorded" : laps)

        Respond in this exact JSON format:
        {
          "summary": "2-3 sentence overall summary",
          "insights": [
            {"category": "Speed|Manoeuvres|Tactics|Consistency|Lap Times", "title": "short title", "detail": "one sentence", "sentiment": "positive|neutral|negative"}
          ],
          "recommendations": ["actionable tip 1", "actionable tip 2", "actionable tip 3"]
        }
        """
    }

    private func parseDebrief(text: String, raceId: UUID) -> AIDebrief {
        guard let data = text.data(using: .utf8),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            return fallbackDebrief(raceId: raceId)
        }

        let summary = json["summary"] as? String ?? ""
        let recs = json["recommendations"] as? [String] ?? []
        let rawInsights = json["insights"] as? [[String: String]] ?? []

        let insights = rawInsights.map { i in
            AIDebrief.Insight(
                category: AIDebrief.InsightCategory(rawValue: i["category"] ?? "") ?? .speed,
                title: i["title"] ?? "",
                detail: i["detail"] ?? "",
                sentiment: AIDebrief.Sentiment(rawValue: i["sentiment"] ?? "") ?? .neutral
            )
        }

        return AIDebrief(raceId: raceId, summary: summary, insights: insights, recommendations: recs)
    }

    private func fallbackDebrief(raceId: UUID) -> AIDebrief {
        AIDebrief(raceId: raceId,
                  summary: "Race data recorded. Connect to the internet to generate your AI debrief.",
                  insights: [], recommendations: [])
    }

    private func formatDuration(_ t: TimeInterval) -> String {
        let m = Int(t) / 60; let s = Int(t) % 60
        return String(format: "%02d:%02d", m, s)
    }
}

private struct AnthropicResponse: Decodable {
    let content: [ContentBlock]
    struct ContentBlock: Decodable {
        let type: String
        let text: String?
    }
}

enum APIConfig {
    static var anthropicKey: String {
        guard let path = Bundle.main.path(forResource: "Config", ofType: "plist"),
              let dict = NSDictionary(contentsOfFile: path),
              let key = dict["AnthropicAPIKey"] as? String else { return "" }
        return key
    }
}
