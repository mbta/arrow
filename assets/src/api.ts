const checkResponseStatus = (response: Response) => {
  if (response.status === 200) {
    return response
  }

  if (Math.floor(response.status / 100) === 3 || response.status === 403) {
    // If the API sends us a redirect or forbidden, the user needs to
    // re-authenticate. Reload to go through the auth flow again.
    window.location.reload(true)
  }

  throw new Error(`Response error: ${response.status}`)
}

const apiCall = <T>({
  url,
  parser,
  defaultResult,
}: {
  url: string
  parser: (json: any) => T
  defaultResult?: T
}): Promise<T> =>
  window
    .fetch(url)
    .then(checkResponseStatus)
    .then((response: Response) => response.json())
    .then((json: any) => parser(json))
    .catch(error => {
      if (typeof defaultResult === "undefined") {
        throw error
      } else {
        return defaultResult
      }
    })

export { apiCall }
