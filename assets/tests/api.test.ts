import { apiGet } from "../src/api"

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

  test("returns parsed data", done => {
    mockFetch(200, { data: "raw" })

    const parse = jest.fn(() => "parsed")

    apiGet({
      url: "/",
      parser: parse,
    }).then(parsed => {
      expect(parse).toHaveBeenCalledWith({ data: "raw" })
      expect(parsed).toEqual("parsed")
      done()
    })
  })

  test("reloads the page if the response status is a redirect (3xx)", done => {
    mockFetch(302, { data: null })

    apiGet({
      url: "/",
      parser: () => null,
    }).catch(() => {
      expect(reloadSpy).toHaveBeenCalled()
      done()
    })
  })

  test("reloads the page if the response status is forbidden (403)", done => {
    mockFetch(403, { data: null })

    apiGet({
      url: "/",
      parser: () => null,
    }).catch(() => {
      expect(reloadSpy).toHaveBeenCalled()
      done()
    })
  })

  test("returns a default for any other response", done => {
    mockFetch(500, { data: null })

    apiGet({
      url: "/",
      parser: () => null,
      defaultResult: "default",
    }).then(result => {
      expect(result).toEqual("default")
      done()
    })
  })

  test("throws an error for any other response status if there's no default", done => {
    mockFetch(500, { data: null })

    apiGet({
      url: "/",
      parser: () => null,
    })
      .then(() => {
        done("fetchRoutes did not throw an error")
      })
      .catch(error => {
        expect(error).toBeDefined()
        done()
      })
  })
})
