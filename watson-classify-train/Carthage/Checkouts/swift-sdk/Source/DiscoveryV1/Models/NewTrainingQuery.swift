/**
 * Copyright IBM Corporation 2018
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 **/

import Foundation

/** NewTrainingQuery. */
internal struct NewTrainingQuery: Codable, Equatable {

    public var naturalLanguageQuery: String?

    public var filter: String?

    public var examples: [TrainingExample]?

    // Map each property name to the key that shall be used for encoding/decoding.
    private enum CodingKeys: String, CodingKey {
        case naturalLanguageQuery = "natural_language_query"
        case filter = "filter"
        case examples = "examples"
    }

    /**
     Initialize a `NewTrainingQuery` with member variables.

     - parameter naturalLanguageQuery:
     - parameter filter:
     - parameter examples:

     - returns: An initialized `NewTrainingQuery`.
    */
    public init(
        naturalLanguageQuery: String? = nil,
        filter: String? = nil,
        examples: [TrainingExample]? = nil
    )
    {
        self.naturalLanguageQuery = naturalLanguageQuery
        self.filter = filter
        self.examples = examples
    }

}
