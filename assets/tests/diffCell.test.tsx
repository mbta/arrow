import * as React from "react"
import { render, screen } from "@testing-library/react"
import { DiffCell, DiffCellProps } from "../src/diffCell"

describe("DiffCell", () => {
  const date1 = new Date()
  const date2 = new Date()
  test.each([
    [{ baseValue: date1, currentValue: date1 }, false],
    [{ baseValue: [date1], currentValue: [date1] }, false],
    [{ baseValue: null, currentValue: "2" }, true],
    [{ baseValue: "1", currentValue: 2 }, true],
    [{ baseValue: [date1], currentValue: [] }, true],
    [{ baseValue: date1, currentValue: date2 }, true],
    [{ currentValue: "1" }, true],
    [
      {
        currentValue: 1,
        baseValue: 2,
        element: "div" as DiffCellProps["element"],
      },
      true,
    ],
  ])(
    "adds className text-muted to specified wrapper element if base value exists and is not strictly equal to current value",
    (props: Partial<DiffCellProps<any>>, isDiff: boolean) => {
      const combinedProps = {
        ...{
          element: "td",
          currentValue: 1,
        },
        ...props,
      } as DiffCellProps
      if (combinedProps.element === "td") {
        render(
          <table>
            <tbody>
              <tr>
                <DiffCell {...combinedProps}>value</DiffCell>
              </tr>
            </tbody>
          </table>
        )
      } else {
        render(<DiffCell {...combinedProps}>value</DiffCell>)
      }
      const element = screen.queryByText("value") as HTMLElement
      expect(element.tagName.toLowerCase()).toEqual(combinedProps.element)
      expect(element.classList.contains("text-muted")).not.toEqual(isDiff)
    }
  )
})
