import { JsonApiResourceData, JsonApiResource } from "./jsonApiResource"

abstract class JsonApiResourceObject {
  abstract toJsonApiData(): JsonApiResourceData
  abstract toJsonApi(): JsonApiResource
}

export default JsonApiResourceObject
