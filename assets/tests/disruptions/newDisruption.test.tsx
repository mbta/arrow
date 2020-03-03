import { mount } from "enzyme"
import * as React from "react"
import * as renderer from "react-test-renderer"

import { NewDisruption } from "../../src/disruptions/newDisruption"
import Header from "../../src/header"

describe("NewDisruption", () => {
  test("header include link to homepage", () => {
    const testInstance = renderer.create(<NewDisruption />).root

    expect(testInstance.findByType(Header).props.includeHomeLink).toBe(true)
  })

  test("selecting a mode filters the available adjustments", () => {
    const wrapper = mount(<NewDisruption />)

    wrapper.find("#mode-commuter-rail.form-check-input").simulate("change")

    let adjustmentOptions = wrapper.find("#adjustment-select-0").find("option")

    expect(adjustmentOptions.length).toBe(2)
    expect(
      adjustmentOptions.findWhere(
        n => n.text() === "Fairmount--Newmarket" && n.type() === "option"
      ).length
    ).toBe(1)
    expect(
      adjustmentOptions.findWhere(
        n => n.text() === "Broadway--Kendall/MIT" && n.type() === "option"
      ).length
    ).toBe(0)

    wrapper.find("#mode-subway.form-check-input").simulate("change")
    adjustmentOptions = wrapper.find("#adjustment-select-0").find("option")
    expect(
      adjustmentOptions.findWhere(
        n => n.text() === "Broadway--Kendall/MIT" && n.type() === "option"
      ).length
    ).toBe(1)
  })

  test("add another adjustment link not enabled by default", () => {
    const wrapper = mount(<NewDisruption />)

    expect(wrapper.exists("#add-another-adjustment-link")).toBe(false)
  })

  test("choosing one adjustment enabled link to choose another", () => {
    const wrapper = mount(<NewDisruption />)

    wrapper
      .find("#adjustment-select-0")
      .find("select")
      .simulate("change", { target: { value: "Kenmore--Newton Highlands" } })

    expect(wrapper.exists("#add-another-adjustment-link")).toBe(true)
  })

  test("ability to delete the only adjustment", () => {
    const wrapper = mount(<NewDisruption />)

    wrapper
      .find("#adjustment-select-0")
      .find("select")
      .simulate("change", { target: { value: "Kenmore--Newton Highlands" } })

    expect(wrapper.exists("#adjustment-delete-0")).toBe(true)

    wrapper.find("#adjustment-delete-0").simulate("click")

    expect(wrapper.find("#adjustment-select-0").exists("select")).toBe(false)
  })

  test("ability to delete an adjustment that isn't the only one", () => {
    const wrapper = mount(<NewDisruption />)

    wrapper
      .find("#adjustment-select-0")
      .find("select")
      .simulate("change", { target: { value: "Kenmore--Newton Highlands" } })

    wrapper.find("#add-another-adjustment-link").simulate("click")

    wrapper
      .find("#adjustment-select-1")
      .find("select")
      .simulate("change", { target: { value: "Broadway--Kendall/MIT" } })

    expect(wrapper.exists("#adjustment-delete-1")).toBe(true)

    wrapper.find("#adjustment-delete-1").simulate("click")

    expect(wrapper.find("#adjustment-select-1").exists("select")).toBe(false)

    expect(wrapper.exists("#add-another-adjustment-link")).toBe(true)
  })

  test("ability to update a chosen adjustment", () => {
    const wrapper = mount(<NewDisruption />)

    wrapper
      .find("#adjustment-select-0")
      .find("select")
      .simulate("change", { target: { value: "Safely ignores this event" } })

    wrapper
      .find("#adjustment-select-0")
      .find("select")
      .simulate("change", { target: { value: "Kenmore--Newton Highlands" } })

    wrapper
      .find("#adjustment-select-0")
      .find("select")
      .simulate("change", { target: { value: "Safely ignores this one, too" } })

    expect(
      wrapper
        .find("#adjustment-select-0")
        .first()
        .props().value
    ).toEqual("Kenmore--Newton Highlands")

    wrapper
      .find("#adjustment-select-0")
      .find("select")
      .simulate("change", { target: { value: "Broadway--Kendall/MIT" } })

    expect(
      wrapper
        .find("#adjustment-select-0")
        .first()
        .props().value
    ).toEqual("Broadway--Kendall/MIT")
  })

  test("preview disruption", () => {
    const wrapper = mount(<NewDisruption />)

    wrapper
      .find("#preview-disruption-button")
      .find("button")
      .simulate("click")

    expect(wrapper.exists("DisruptionPreview")).toBe(true)
  })

  test("can go back to edit from preview", () => {
    const wrapper = mount(<NewDisruption />)

    wrapper
      .find("#preview-disruption-button")
      .find("button")
      .simulate("click")

    wrapper
      .find("#back-to-edit-link")
      .find("a")
      .simulate("click")

    expect(wrapper.exists("NewDisruptionPreview")).toBe(false)
  })
})
