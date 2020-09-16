import * as React from "react"
import BootstrapButton from "react-bootstrap/Button"
import { ButtonProps } from "react-bootstrap/Button"

export const Button = (props: ButtonProps) => {
  return <BootstrapButton {...props} />
}

export const PrimaryButton = ({
  filled = false,
  ...rest
}: ButtonProps & { filled?: boolean }) => {
  return (
    <BootstrapButton {...rest} variant={`${filled ? "" : "outline-"}primary`} />
  )
}

export const SecondaryButton = ({
  filled = false,
  ...rest
}: ButtonProps & { filled?: boolean }) => {
  return (
    <BootstrapButton
      {...rest}
      variant={`${filled ? "" : "outline-"}secondary`}
    />
  )
}

export const LinkButton = (props: ButtonProps) => {
  return <BootstrapButton {...props} variant="link" />
}
