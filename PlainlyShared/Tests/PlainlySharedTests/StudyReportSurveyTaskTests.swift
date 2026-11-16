//
// This source file is part of the Plainly iOS open-source project
//
// SPDX-FileCopyrightText: 2026 Stanford University
//
// SPDX-License-Identifier: MIT
//

import Foundation
import GroveQuestionnaire
import PlainlyShared
import Testing


struct StudyReportSurveyTaskTests {
    /// A skipped task's questions are unanswered on purpose, which the report has to tell apart from a lost answer.
    @Test
    func reportsWhetherATaskWasSkipped() throws {
        let date = Date(timeIntervalSince1970: 1_000)
        let question = StudyReport.TimelineEvent.SurveyQuestion(
            questionText: "How effective was the app?",
            answer: Questionnaire.Task.legacyUnansweredValue,
            isOptional: false
        )
        let events = [false, true].enumerated().map { index, skipped in
            StudyReport.TimelineEvent.surveyTask(.init(
                taskId: "\(index)",
                startedAt: date,
                completedAt: date,
                duration: 0,
                questions: [question],
                skipped: skipped
            ))
        }

        let data = try JSONEncoder().encode(events)
        let encoded = try #require(JSONSerialization.jsonObject(with: data) as? [[String: Any]])
        let tasks = encoded.compactMap { $0["data"] as? [String: Any] }

        #expect(tasks.compactMap { $0["skipped"] as? Bool } == [false, true])
    }
}
