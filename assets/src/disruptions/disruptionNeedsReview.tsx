import * as React from "react"
import { DisruptionListContainer } from "./disruptionListContainer"
import { Page } from "../page"

const DisruptionNeedsReview = () => {
  return (
    <Page includeHomeLink={false}>
      <DisruptionListContainer>Needs Review Goes Here</DisruptionListContainer>
    </Page>
  )
}

export { DisruptionNeedsReview }
