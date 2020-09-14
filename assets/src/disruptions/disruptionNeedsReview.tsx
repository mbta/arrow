import * as React from "react"
import { DisruptionListContainer } from "./disruptionListContainer"
import { Page } from "../page"
import { apiGet } from "../api"
import { JsonApiResponse, toModelObject } from "../jsonApi"
import DisruptionDiff from "../models/disruptionDiff"
import { formatDisruptionDate } from "./disruptions"

const DisruptionNeedsReview = () => {
  const [disruptionDiffs, setDisruptionDiffs] = React.useState<
    DisruptionDiff[] | "error"
  >([])

  React.useEffect(() => {
    apiGet<JsonApiResponse>({
      url: "/api/disruption_diffs",
      parser: toModelObject,
      defaultResult: "error",
    }).then((result: JsonApiResponse) => {
      if (
        Array.isArray(result) &&
        result.every((res) => res instanceof DisruptionDiff)
      ) {
        setDisruptionDiffs(result as DisruptionDiff[])
      } else {
        setDisruptionDiffs("error")
      }
    })
  }, [])

  return (
    <Page includeHomeLink={false}>
      <DisruptionListContainer>
        {disruptionDiffs === "error" ? (
          <div>Something went wrong</div>
        ) : (
          <div>
            <DisruptionNeedsReviewView disruptionDiffs={disruptionDiffs} />
          </div>
        )}
      </DisruptionListContainer>
    </Page>
  )
}

interface DisruptionNeedsReviewViewProps {
  disruptionDiffs: DisruptionDiff[]
}

const DisruptionNeedsReviewView = ({
  disruptionDiffs,
}: DisruptionNeedsReviewViewProps): JSX.Element => {
  return (
    <div>
      {disruptionDiffs.map((disruptionDiff) => (
        <div
          className="m-disruption-diffs__disruption_container"
          key={disruptionDiff.id}
        >
          <div className="m-disruption-diffs__disruption">
            <div className="m-disruption-diffs__adjustments">
              {disruptionDiff.disruptionRevision.adjustments.map(
                (a) => a.sourceLabel
              )}
            </div>
            <div className="m-disruption-diffs__date_range">
              {disruptionDiff.disruptionRevision.startDate &&
                formatDisruptionDate(
                  disruptionDiff.disruptionRevision.startDate
                )}{" "}
              -{" "}
              {disruptionDiff.disruptionRevision.endDate &&
                formatDisruptionDate(disruptionDiff.disruptionRevision.endDate)}
            </div>
          </div>
          {disruptionDiff.isCreated && (
            <div className="m-disruption-diffs__newly_created">
              Newly created
            </div>
          )}
          {disruptionDiff.diffs.length > 0 && (
            <div>
              <div className="m-disruption-diffs__diff_container">
                {disruptionDiff.diffs.map((diff, n) => (
                  <div key={n}>
                    Changeset {n}:
                    <ul className="m-disruption-diffs__diff_list">
                      {diff.map((item, i) => (
                        <li key={i}>{item}</li>
                      ))}
                    </ul>
                  </div>
                ))}
              </div>
            </div>
          )}
        </div>
      ))}
    </div>
  )
}

export { DisruptionNeedsReview }
