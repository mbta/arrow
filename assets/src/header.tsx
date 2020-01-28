import React from "react"
import Navbar from "react-bootstrap/Navbar"

interface HeaderProps {
  includeHomeLink: boolean
}

const defaultProps = {
  includeHomeLink: true,
}

const Header = ({ includeHomeLink }: HeaderProps) => (
  <div>
    <Navbar bg="light">
      <Navbar.Brand>
        <span className="m-header__arrow">
          <img src="/images/logo.svg" width="34" height="34" />
          <span className="m-header__arrow-text">ARROW</span>
        </span>
      </Navbar.Brand>
      <Navbar.Collapse className="justify-content-end">
        <Navbar.Text>
          <span className="m-header__long-name">
            Adjustments to the Regular Right of Way
          </span>
        </Navbar.Text>
      </Navbar.Collapse>
    </Navbar>
    {includeHomeLink && <a href="/">&lt; back to home</a>}
    <hr />
  </div>
)

Header.defaultProps = defaultProps

export default Header
