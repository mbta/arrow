import React from "react"
import Navbar from "react-bootstrap/Navbar"

const Header = () => (
  <Navbar bg="light">
    <Navbar.Brand>
      <span className="header-arrow">
        <img src="images/logo.svg" width="34" height="34" />
        <span className="header-arrow-text">ARROW</span>
      </span>
    </Navbar.Brand>
    <Navbar.Collapse className="justify-content-end">
      <Navbar.Text>
        <span className="header-long-name">
          Adjustments to the Regular Right of Way
        </span>
      </Navbar.Text>
    </Navbar.Collapse>
  </Navbar>
)

export default Header
