import React from "react"
import Modal from "react-bootstrap/Modal"
import { PrimaryButton, SecondaryButton } from "./button"

interface ConfirmationModalProps {
  onClickConfirm: () => void
  confirmationText: string
  confirmationButtonText: string
  buttonIdentifier?: string
  Component: JSX.Element
}

const ConfirmationModal = ({
  confirmationText,
  confirmationButtonText,
  buttonIdentifier,
  onClickConfirm,
  Component,
}: ConfirmationModalProps) => {
  const [modalOpen, setModalOpen] = React.useState(false)
  return (
    <>
      <Modal show={modalOpen} className="m-confirmation-modal">
        <Modal.Body>
          <div className="my-3">
            <strong>Are you sure?</strong>
          </div>
          <div>{confirmationText}</div>
          <div className="d-flex my-3 w-100">
            <div className="w-50 mr-3">
              <SecondaryButton
                id={buttonIdentifier ? `${buttonIdentifier}-cancel` : "cancel"}
                className="w-100"
                onClick={() => setModalOpen(false)}
              >
                cancel
              </SecondaryButton>
            </div>
            <div className="w-50 ml-3">
              <PrimaryButton
                id={
                  buttonIdentifier ? `${buttonIdentifier}-confirm` : "confirm"
                }
                className="w-100"
                onClick={() => {
                  onClickConfirm()
                  setModalOpen(false)
                }}
              >
                {confirmationButtonText}
              </PrimaryButton>
            </div>
          </div>
        </Modal.Body>
      </Modal>
      {React.cloneElement(Component, { onClick: () => setModalOpen(true) })}
    </>
  )
}

export { ConfirmationModal }
