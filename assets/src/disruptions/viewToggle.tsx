import queryString from "query-string"

import { DisruptionView } from "../models/disruption"

const useDisruptionViewParam = (): DisruptionView => {
  const { v } = queryString.parse(window.location.search)
  switch (v) {
    case "draft": {
      return DisruptionView.Draft
    }
    case "ready": {
      return DisruptionView.Ready
    }
    default: {
      return DisruptionView.Published
    }
  }
}

export { useDisruptionViewParam }
