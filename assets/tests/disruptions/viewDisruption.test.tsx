import { createBrowserHistory } from "history"
import { mount } from "enzyme"
import * as React from "react"
import { Redirect } from "react-router"
import { BrowserRouter } from "react-router-dom"

import ViewDisruption from "../../src/disruptions/viewDisruption"

describe("ViewDisruption", () => {
  test("edit link redirects to edit page", () => {
    const history = createBrowserHistory()
    const wrapper = mount(
      <BrowserRouter>
        <ViewDisruption
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
      </BrowserRouter>
    )

    wrapper
      .find("#edit-disruption-button")
      .find("button")
      .simulate("click")

    expect(wrapper.exists(Redirect)).toBe(true)
  })
})
