import * as React from "react"
import Header from "./header"

interface PageProps {
  children: React.ReactNode
  includeHomeLink?: boolean
}

const Page = ({ children, includeHomeLink }: PageProps) => {
  return (
    <div>
      <Header includeHomeLink={includeHomeLink} />
      {children}
    </div>
  )
}

export { Page }
