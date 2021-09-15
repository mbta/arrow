import React, { DetailedHTMLProps, InputHTMLAttributes } from "react"

const Checkbox = ({
  containerClassName,
  inputClassName,
  labelClassName,
  labelText,
  ...props
}: Omit<
  DetailedHTMLProps<InputHTMLAttributes<HTMLInputElement>, HTMLInputElement>,
  "className" | "type"
> & {
  id: string
  containerClassName?: string
  inputClassName?: string
  labelClassName?: string
  labelText?: string
}) => {
  return (
    <div className={"m-checkbox " + containerClassName}>
      <input type="checkbox" className={inputClassName} {...props} />
      <label className={labelClassName} htmlFor={props.id}>
        <div className="m-checkbox__image" />
        {labelText}
      </label>
    </div>
  )
}

export default Checkbox
