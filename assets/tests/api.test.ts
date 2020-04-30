import { apiGet, apiSend } from "../src/api"

declare global {
  interface Window {
    fetch: (uri: string) => Promise<any>
  }
}

const mockFetch = (status: number, json: any): void => {
  window.fetch = () =>
    Promise.resolve({
      json: () => json,
      status,
    } as Response)
}

const mockFetchFailure = () => {
  window.fetch = () => Promise.reject("network failure")
}

describe("apiSend", () => {
  test("parses successful create", (done) => {
    mockFetch(201, { data: "success" })
    const successParse = jest.fn(() => "success")
    apiSend({
      url: "/",
      method: "POST",
      json: "{}",
      successParser: successParse,
      errorParser: () => "error",
    }).then((parsed) => {
      expect(successParse).toHaveBeenCalledWith({ data: "success" })
      expect(parsed).toEqual({ ok: "success" })
      done()
    })
  })

  test("parses successful update", (done) => {
    mockFetch(200, { data: "success" })
    const successParse = jest.fn(() => "success")
    apiSend({
      url: "/",
      method: "PATCH",
      json: "{}",
      successParser: successParse,
      errorParser: () => "error",
    }).then((parsed) => {
      expect(successParse).toHaveBeenCalledWith({ data: "success" })
      expect(parsed).toEqual({ ok: "success" })
      done()
    })
  })

  test("parses error response", (done) => {
    mockFetch(400, { data: "error" })
    const errorParse = jest.fn(() => "error")
    apiSend({
      url: "/",
      method: "POST",
      json: "{}",
      successParser: () => "success",
      errorParser: errorParse,
    }).then((parsed) => {
      expect(errorParse).toHaveBeenCalledWith({ data: "error" })
      expect(parsed).toEqual({ error: "error" })
      done()
    })
  })

  test("promise reject if there are errors", (done) => {
    mockFetchFailure()

    apiSend({
      url: "/",
      method: "POST",
      json: "{}",
      successParser: () => "success",
      errorParser: () => "error",
    }).catch((err) => {
      expect(err).toEqual("network failure")
      done()
    })
  })

  test("promise reject if unexpected error code", (done) => {
    mockFetch(500, { data: "error" })
    apiSend({
      url: "/",
      method: "POST",
      json: "{}",
      successParser: () => "success",
      errorParser: () => "error",
    }).catch((err) => {
      expect(err).toEqual("fetch/parse error")
      done()
    })
  })
})

describe("apiGet", () => {
  let reloadSpy: jest.SpyInstance

  beforeEach(() => {
    // Dirty: setting window.location as writable so we can spy on reload function.
    // Doing this once here to avoid it in all other tests.
    Object.defineProperty(window, "location", {
      writable: true,
      value: { reload: jest.fn() },
    })

    reloadSpy = jest.spyOn(window.location, "reload")
    reloadSpy.mockImplementation(() => ({}))
  })

  afterEach(() => {
    reloadSpy.mockRestore()
  })

  test("returns parsed data", (done) => {
    mockFetch(200, { data: "raw" })

    const parse = jest.fn(() => "parsed")

    apiGet({
      url: "/",
      parser: parse,
    }).then((parsed) => {
      expect(parse).toHaveBeenCalledWith({ data: "raw" })
      expect(parsed).toEqual("parsed")
      done()
    })
  })

  test("reloads the page if the response status is a redirect (3xx)", (done) => {
    mockFetch(302, { data: null })

    apiGet({
      url: "/",
      parser: () => null,
    }).catch(() => {
      expect(reloadSpy).toHaveBeenCalled()
      done()
    })
  })

  test("reloads the page if the response status is forbidden (403)", (done) => {
    mockFetch(403, { data: null })

    apiGet({
      url: "/",
      parser: () => null,
    }).catch(() => {
      expect(reloadSpy).toHaveBeenCalled()
      done()
    })
  })

  test("returns a default for any other response", (done) => {
    mockFetch(500, { data: null })

    apiGet({
      url: "/",
      parser: () => null,
      defaultResult: "default",
    }).then((result) => {
      expect(result).toEqual("default")
      done()
    })
  })

  test("throws an error for any other response status if there's no default", (done) => {
    mockFetch(500, { data: null })

    apiGet({
      url: "/",
      parser: () => null,
    })
      .then(() => {
        done("fetchRoutes did not throw an error")
      })
      .catch((error) => {
        expect(error).toBeDefined()
        done()
      })
  })
})
