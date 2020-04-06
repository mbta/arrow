interface Result<T, E> {
  ok?: T
  error?: E
}

const redirectIfUnauthorized = (status: number) => {
  if (Math.floor(status / 100) === 3 || status === 403) {
    // If the API sends us a redirect or forbidden, the user needs to
    // re-authenticate. Reload to go through the auth flow again.
    window.location.reload(true)
  }
}

const checkResponseStatus = (response: Response) => {
  if (response.status === 200) {
    return response
  }

  redirectIfUnauthorized(response.status)
  throw new Error(`Response error: ${response.status}`)
}

const apiPost = async <T, E>({
  url,
  json,
  successParser,
  errorParser,
}: {
  url: string
  json: any
  successParser: (json: any) => T
  errorParser: (json: any) => E
}): Promise<Result<T, E>> => {
  const response = await fetch(url, {
    method: "POST",
    credentials: "include",
    headers: { "Content-Type": "application/vnd.api+json" },
    body: json,
  })
  redirectIfUnauthorized(response.status)
  const responseData = await response.json()
  if (response.status === 201) {
    return { ok: successParser(responseData) }
  } else if (response.status === 400) {
    return { error: errorParser(responseData) }
  }

  return Promise.reject("fetch/parse error")
}

const apiGet = <T>({
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

export { apiGet, apiPost }
