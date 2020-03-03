import { createBrowserHistory } from "history"
import { mount } from "enzyme"
import * as React from "react"
import { Redirect } from "react-router"
import { BrowserRouter } from "react-router-dom"
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

  test("save link previews disruption", () => {
    const history = createBrowserHistory()
    const wrapper = mount(
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
    )

    wrapper
      .find("#save-changes-button")
      .find("button")
      .simulate("click")

    expect(wrapper.exists("DisruptionPreview")).toBe(true)
  })

  test("cancel link redirects back to view page", () => {
    const history = createBrowserHistory()
    const wrapper = mount(
      <BrowserRouter>
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
      </BrowserRouter>
    )

    wrapper
      .find("#cancel-button")
      .find("button")
      .simulate("click")

    expect(wrapper.exists(Redirect)).toBe(true)
  })
})
