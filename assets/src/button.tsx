import * as React from "react"
import BootstrapButton from "react-bootstrap/Button"
import { ButtonProps } from "react-bootstrap/Button"

const Button = (props: ButtonProps) => {
  return <BootstrapButton {...props} />
}

const PrimaryButton = ({
  filled = false,
  ...rest
}: ButtonProps & { filled?: boolean }) => {
  return (
    <BootstrapButton {...rest} variant={`${filled ? "" : "outline-"}primary`} />
  )
}

const SecondaryButton = ({
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

const LinkButton = (props: ButtonProps) => {
  return <BootstrapButton {...props} variant="link" />
}

export { Button, PrimaryButton, SecondaryButton, LinkButton }
