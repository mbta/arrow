import { createBrowserHistory } from "history"
import * as React from "react"
import * as renderer from "react-test-renderer"

import EditDisruption from "../../src/disruptions/editDisruption"
import Header from "../../src/header"

describe("NewDisruption", () => {
  test("header include link to homepage", () => {
    const history = createBrowserHistory()
    const testInstance = renderer.create(
      <EditDisruption
        match={{
          params: { id: "foo" },
          isExact: true,
          path: "/disruptions/foo/edit",
          url: "https://localhost/disruptions/foo/edit",
        }}
        history={history}
        location={{
          pathname: "/disruptions/foo/edit",
          search: "",
          state: {},
          hash: "",
        }}
      />
    ).root

    expect(testInstance.findByType(Header).props.includeHomeLink).toBe(true)
  })
})
