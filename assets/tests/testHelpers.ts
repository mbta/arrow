import { fireEvent } from "@testing-library/react"

/**
 * Get the value of a hidden input with a given name. Assumes `jsdom` and looks
 * for the input in the whole document.
 */
const hiddenInputValue = (name: string) => {
  const input = document.querySelector(`input[type=hidden][name="${name}"]`)
  if (!input) throw new Error(`no hidden input found with name "${name}"`)
  return (input as HTMLInputElement).value
}

/**
 * Pick a date from a `react-datepicker` input. Currently this just fires a
 * change event directly, since attempting to interact with the input normally
 * (either by clicking it or typing into it) throws an error within the library
 * when it attempts to open the calendar popup.
 */
const pickDate = (input: HTMLElement, value: string) => {
  fireEvent.change(input, { target: { value } })
}

export { hiddenInputValue, pickDate }
