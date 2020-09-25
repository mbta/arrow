import * as React from "react"

const Checkbox = ({
  containerClassName,
  inputClassName,
  labelClassName,
  ...props
}: Omit<
  React.DetailedHTMLProps<
    React.InputHTMLAttributes<HTMLInputElement>,
    HTMLInputElement
  >,
  "className" | "type"
> & {
  id: string
  containerClassName?: string
  inputClassName?: string
  labelClassName?: string
}) => {
  return (
    <div className={"m-checkbox " + containerClassName}>
      <input type="checkbox" className={inputClassName} {...props} />
      <label className={labelClassName} htmlFor={props.id} />
    </div>
  )
}

export default Checkbox
